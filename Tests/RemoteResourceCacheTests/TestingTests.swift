//
//  TestingTests.swift
//  
//
//  Created by Óscar Morales Vivó on 4/20/23.
//

import os
import XCTest

protocol TestResID {
    var inMemory: String { get }

    var localFile: String { get }

    var remoteURL: URL { get }
}

final class TestingTests: XCTestCase {
    private static let sampleImage: UIImage = {
        let imageSize = CGSize(width: 256.0, height: 256.0)
        let imageRenderer = UIGraphicsImageRenderer(size: imageSize)
        return imageRenderer.image { context in
            UIColor.yellow.setFill()
            context.fill(.init(origin: .zero, size: imageSize))
            UIColor.blue.setFill()
            UIBezierPath(ovalIn: .init(
                x: imageSize.width / 8.0,
                y: imageSize.height / 8.0,
                width: imageSize.width / 4.0,
                height: imageSize.height / 4.0
            )
            ).fill()
            UIBezierPath(ovalIn: .init(
                x: (imageSize.width * 5.0) / 8.0,
                y: (imageSize.height * 5.0) / 8.0,
                width: imageSize.width / 4.0,
                height: imageSize.height / 4.0
            )
            ).fill()
        }
    }()

    static let sampleImageData: Data = sampleImage.pngData()!

    func testChainedCache() async throws {
        struct TestResIDImpl: TestResID {
            let inMemory = "I like Pie"

            let localFile = "Potatoes!"

            let remoteURL = URL(string: "https://zombo.com")!
        }

        let remoteCache = RemoteFileCache<TestResID> { resourceID in
            resourceID.remoteURL
        }
        let localCache = LocalFileCache(next: remoteCache) { resourceID in
            resourceID.localFile
        }
        let inMemoryCache = InMemoryCache(next: localCache) { resourceID in
            resourceID.inMemory
        } processor: { resourceData in
            if let image = UIImage(data: resourceData) {
                return image
            } else {
                throw CacheFailed()
            }
        }

        let _ = try await inMemoryCache.fetchResourceWith(resourceID: TestResIDImpl())
    }
}

protocol Cache: Identifiable, Actor {
    associatedtype Resource

    associatedtype CacheID: Hashable

    associatedtype ResourceID

    func extractCacheIDFrom(resourceID: ResourceID) -> CacheID

    func cachedResourceWith(identifier: CacheID) async throws -> Resource?
}

protocol ChainableCache: Cache {
    associatedtype Next: Cache where Next.ResourceID == ResourceID

    var next: Next? { get }

    func processFromNext(cached: Next.Resource) throws -> Resource

    func store(resource: Resource, identifier: CacheID) async throws
}

let cacheLogger = Logger(subsystem: "RemoteResourceCache", category: "Cache")

struct CacheFailed: Error {

}

extension Cache {
    func fetchResourceWith(resourceID: ResourceID) async throws -> Resource {
        let identifier = extractCacheIDFrom(resourceID: resourceID)
        if let cached = try await cachedResourceWith(identifier: identifier) {
            return cached
        } else {
            throw CacheFailed()
        }
    }
}

extension ChainableCache {
    func cachedValue(identifier: CacheID) async throws -> Resource? {
        do {
            if let cached = try await cachedResourceWith(identifier: identifier) {
                return cached
            }
        } catch {
            // If fetching from cached threw, we can still try for a deeper cache but let's log first.
            cacheLogger.error("Error attempting to fetch cached resource from cache of type \(type(of: self)) with ID \(String(describing: self.id)). Error \(error.localizedDescription)")
        }

        return nil
    }

    func cacheStore(resource: Resource, identifier: CacheID) async {
        do {
            try await store(resource: resource, identifier: identifier)
        } catch {
            // Storage may fail but we still got the data.
            cacheLogger.error("Error attempting to store cached resource with id \(String(describing: identifier)) in cache of type \(type(of: self)) with ID \(String(describing: self.id)). Error \(error.localizedDescription)")
        }
    }
}

extension ChainableCache {
    func fetchResourceWith(resourceID: ResourceID) async throws -> Resource {
        let identifier = extractCacheIDFrom(resourceID: resourceID)
        if let cached = try await cachedValue(identifier: identifier) {
            return cached
        }

        if let next {
            let resource = try await processFromNext(cached: next.fetchResourceWith(resourceID: resourceID))
            await cacheStore(resource: resource, identifier: identifier)
            return resource
        } else {
            throw CacheFailed()
        }
    }
}

extension ChainableCache where Next: ChainableCache {
    func fetchResourceWith(resourceID: ResourceID) async throws -> Resource {
        let identifier = extractCacheIDFrom(resourceID: resourceID)
        if let cached = try await cachedValue(identifier: identifier) {
            return cached
        }

        if let next {
            let resource = try await processFromNext(cached: next.fetchResourceWith(resourceID: resourceID))
            await cacheStore(resource: resource, identifier: identifier)
            return resource
        } else {
            throw CacheFailed()
        }
    }
}

actor InMemoryCache<Resource: AnyObject, CacheID: Hashable, ResourceID, Next: Cache>: ChainableCache where Next.ResourceID == ResourceID {
    func extractCacheIDFrom(resourceID: ResourceID) -> CacheID {
        extractor(resourceID)
    }

    init(next: Next?, extractor: @escaping (ResourceID) -> CacheID, processor: @escaping (Next.Resource) throws -> Resource) {
        self.next = next
        self.extractor = extractor
        self.processor = processor
    }

    func processFromNext(cached: Next.Resource) throws -> Resource {
        try processor(cached)
    }

    func store(resource: Resource, identifier: CacheID) throws {
        dictionary[identifier] = resource
    }

    func cachedResourceWith(identifier: CacheID) async throws -> Resource? {
        return dictionary[identifier]
    }

    typealias Resource = Resource

    typealias CacheID = CacheID

    typealias Next = Next

    let next: Next?

    private let extractor: (ResourceID) -> CacheID

    private let processor: (Next.Resource) throws -> Resource

    private var dictionary = [CacheID: Resource]()
}

actor LocalFileCache<Next: Cache, ResourceID>: ChainableCache where Next.Resource == Data, Next.ResourceID == ResourceID {
    func extractCacheIDFrom(resourceID: ResourceID) -> String {
        extractor(resourceID)
    }

    init(next: Next?, extractor: @escaping (ResourceID) -> String) {
        self.next = next
        self.extractor = extractor
    }

    func processFromNext(cached: Next.Resource) -> Data {
        cached
    }

    func cachedResourceWith(identifier: String) async throws -> Data? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(identifier, isDirectory: false)
        do {
            return try Data(contentsOf: url)
        } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSFileReadNoSuchFileError {
            // Not finding the file is fine, we'll just return `nil`
            return nil
        }
    }

    func store(resource: Data, identifier: String) throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(identifier, isDirectory: false)
        try resource.write(to: url)
    }

    let next: Next?

    private let extractor: (ResourceID) -> CacheID

    typealias Resource = Data

    typealias CacheID = String

    typealias Next = Next
}

actor RemoteFileCache<ResourceID>: Cache {
    func extractCacheIDFrom(resourceID: ResourceID) -> URL {
        extractor(resourceID)
    }

    func cachedResourceWith(identifier: URL) async throws -> Data? {
        await Task {
            TestingTests.sampleImageData
        }.value
//        try await URLSession.shared.data(from: identifier).0
    }

    init(extractor: @escaping (ResourceID) -> URL) {
        self.extractor = extractor
    }

    func cachedResourceWith(identifier: String) async throws -> Data? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(identifier, isDirectory: false)
        return try Data(contentsOf: url)
    }

    private let extractor: (ResourceID) -> CacheID

    typealias Resource = Data

    typealias CacheID = URL
}
