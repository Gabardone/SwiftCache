//
//  CacheChainTests.swift
//  SwiftCacheTests
//
//  Created by Óscar Morales Vivó on 4/11/23.
//

import SwiftCache
import XCTest

extension CacheChainTests {
    #if os(macOS)
    typealias XXImage = NSImage

    private static let sampleImage: NSImage = {
        let imageSize = CGSize(width: 256.0, height: 256.0)
        return NSImage(size: imageSize, flipped: false) { rect in
            NSColor.yellow.setFill()
            NSBezierPath.fill(rect)
            NSColor.blue.setFill()
            NSBezierPath(ovalIn: .init(
                x: imageSize.width / 8.0,
                y: imageSize.height / 8.0,
                width: imageSize.width / 4.0,
                height: imageSize.height / 4.0
            )
            ).fill()
            NSBezierPath(ovalIn: .init(
                x: (imageSize.width * 5.0) / 8.0,
                y: (imageSize.height * 5.0) / 8.0,
                width: imageSize.width / 4.0,
                height: imageSize.height / 4.0
            )
            ).fill()

            return true
        }
    }()

    private static let sampleImageData: Data = sampleImage.tiffRepresentation!
    #else
    typealias XXImage = UIImage

    private static let sampleImage: UIImage = {
        let imageSize = CGSize(width: 256.0, height: 256.0)
        UIGraphicsBeginImageContext(imageSize)
        defer {
            UIGraphicsEndImageContext()
        }

        let context = UIGraphicsGetCurrentContext()!
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

        return UIGraphicsGetImageFromCurrentImageContext()!
    }()

    private static let sampleImageData: Data = sampleImage.pngData()!
    #endif
}

final class CacheChainTests: XCTestCase {
    private static let badImageData = Data(count: 16)

    private static let dummyURL = URL(string: "https://zombo.com/")!

    private typealias MockImageStorage = ComposableStorage<XXImage, URL>

    private typealias MockNetworkStorage = ComposableStorage<Data, URL>

    private typealias MockLocalStorage = ComposableStorage<Data, String>

    private struct MockImageCache {
        var cache: any Cache<XXImage, URL>

        var inMemoryStorage: MockImageStorage

        var localStorage: MockLocalStorage

        var networkStorage: MockNetworkStorage
    }

    private struct ImageConversionError: Error {}

    /**
     We're using a mock of a three-level cache (in-memory/local file storage/network fetch).
     */
    private static func buildImageCache() -> MockImageCache {
        let networkStorage = MockNetworkStorage()
        let networkCache = BackstopStorageCache(storage: networkStorage)

        let localStorage = MockLocalStorage()
        let localCache = TemporaryStorageCache(next: networkCache, storage: localStorage, idConverter: { url in
            url.lastPathComponent
        })

        let inMemoryStorage = MockImageStorage()
        let inMemoryCache = TemporaryStorageCache(next: localCache, storage: inMemoryStorage) { data in
            if let image = XXImage(data: data) {
                return image
            } else {
                throw ImageConversionError()
            }
        }

        return .init(
            cache: inMemoryCache,
            inMemoryStorage: inMemoryStorage,
            localStorage: localStorage,
            networkStorage: networkStorage
        )
    }

    private func expectNoInMemory(imageCache: MockImageCache) -> XCTestExpectation {
        let inMemoryReadExpectation = expectation(description: "No in memory image found")
        imageCache.inMemoryStorage.storedValueForOverride = { url in
            XCTAssertEqual(url, Self.dummyURL)
            inMemoryReadExpectation.fulfill()
            return nil
        }
        return inMemoryReadExpectation
    }

    private func expectInMemoryWrite(imageCache: MockImageCache) -> XCTestExpectation {
        let inMemoryWriteExpectation = expectation(description: "Storing the image in memory")
        imageCache.inMemoryStorage.storeOverride = { image, url in
            inMemoryWriteExpectation.fulfill()

            // Check that it's the same image as usual.
            XCTAssertEqual(url, Self.dummyURL)
            XCTAssertEqual(image.size.width, Self.sampleImage.size.width)
            XCTAssertEqual(image.size.height, Self.sampleImage.size.height)
        }
        return inMemoryWriteExpectation
    }

    private func expectLocalRead(imageCache: MockImageCache, returning: Data? = nil) -> XCTestExpectation {
        let localReadExpectation = expectation(description: "Local data read")
        imageCache.localStorage.storedValueForOverride = { fileName in
            localReadExpectation.fulfill()
            XCTAssertEqual(fileName, Self.dummyURL.lastPathComponent)
            return returning
        }
        return localReadExpectation
    }

    private func expectLocalWrite(imageCache: MockImageCache) -> XCTestExpectation {
        let localWriteExpectation = expectation(description: "Storing the image locally")
        imageCache.localStorage.storeOverride = { data, fileName in
            localWriteExpectation.fulfill()
            XCTAssertEqual(fileName, Self.dummyURL.lastPathComponent)
            XCTAssertEqual(data, Self.sampleImageData)
        }
        return localWriteExpectation
    }

    private func expectNetworkRead(
        imageCache: MockImageCache,
        returning: Data?,
        existing: XCTestExpectation? = nil
    ) -> XCTestExpectation {
        let networkExpectation = existing ?? expectation(description: "Checking the network")
        imageCache.networkStorage.storedValueForOverride = { url in
            networkExpectation.fulfill()
            XCTAssertEqual(url, Self.dummyURL)
            return returning
        }
        return networkExpectation
    }

    // If no one has it, we quietly return nil.
    func testNilIsNil() async throws {
        let imageCache = Self.buildImageCache()
        let networkExpectation = expectNetworkRead(imageCache: imageCache, returning: nil)

        let localReadExpectation = expectLocalRead(imageCache: imageCache, returning: nil)

        let inMemoryReadExpectation = expectNoInMemory(imageCache: imageCache)

        let image = try await imageCache.cache.cachedValueWith(identifier: Self.dummyURL)

        await fulfillment(of: [localReadExpectation, inMemoryReadExpectation, networkExpectation])

        XCTAssertNil(image)
    }

    // If the data is found locally, we return it and don't do anything else weird.
    func testLocallyStoredImageDataHappyPath() async throws {
        let imageCache = Self.buildImageCache()
        let localReadExpectation = expectLocalRead(imageCache: imageCache, returning: Self.sampleImageData)

        let inMemoryReadExpectation = expectNoInMemory(imageCache: imageCache)

        let inMemoryWriteExpectation = expectInMemoryWrite(imageCache: imageCache)

        let image = try await imageCache.cache.cachedValueWith(identifier: Self.dummyURL)

        await fulfillment(of: [localReadExpectation, inMemoryReadExpectation, inMemoryWriteExpectation])

        // Looping image -> data -> image -> data doesn't usually result in equal data or equal images as some config
        // data gets lost, but at least we can check pixel size.
        XCTAssertEqual(image?.size.width, Self.sampleImage.size.width)
        XCTAssertEqual(image?.size.height, Self.sampleImage.size.height)
    }

    // If the data is not local, we get remote and store.
    func testRemotelyStoredImageDataHappyPath() async throws {
        let imageCache = Self.buildImageCache()

        let networkReadExpectation = expectNetworkRead(imageCache: imageCache, returning: Self.sampleImageData)

        let localReadExpectation = expectLocalRead(imageCache: imageCache)

        let localWriteExpectation = expectLocalWrite(imageCache: imageCache)

        let inMemoryReadExpectation = expectNoInMemory(imageCache: imageCache)

        let inMemoryWriteExpectation = expectInMemoryWrite(imageCache: imageCache)

        let image = try await imageCache.cache.cachedValueWith(identifier: Self.dummyURL)

        await fulfillment(of: [
            networkReadExpectation,
            localReadExpectation,
            localWriteExpectation,
            inMemoryReadExpectation,
            inMemoryWriteExpectation
        ])

        // Looping image -> data -> image -> data doesn't usually result in equal data or equal images as some config
        // data gets lost, but at least we can check pixel size.
        XCTAssertEqual(image?.size.width, Self.sampleImage.size.width)
        XCTAssertEqual(image?.size.height, Self.sampleImage.size.height)
    }

    // If the local data is bad we recover by grabbing remote again.
    func testLocalDataIsBad() async throws {
        let imageCache = Self.buildImageCache()

        let localReadExpectation = expectLocalRead(imageCache: imageCache, returning: Self.badImageData)

        let inMemoryReadExpectation = expectNoInMemory(imageCache: imageCache)

        do {
            _ = try await imageCache.cache.cachedValueWith(identifier: Self.dummyURL)
            XCTFail("Exception expected, didn't happen.")
        } catch is ImageConversionError {
        } catch {
            XCTFail("Unexpected exception of type \(type(of: error))")
        }

        await fulfillment(of: [localReadExpectation, inMemoryReadExpectation])
    }

    // If the remote data is bad we throw.
    func testRemoteDataIsBad() async throws {
        let imageCache = Self.buildImageCache()

        let networkExpectation = expectNetworkRead(imageCache: imageCache, returning: Self.badImageData)

        let localReadExpectation = expectLocalRead(imageCache: imageCache)

        let inMemoryReadExpectation = expectNoInMemory(imageCache: imageCache)

        do {
            _ = try await imageCache.cache.cachedValueWith(identifier: Self.dummyURL)
            XCTFail("Exception expected, didn't happen.")
        } catch {
            XCTAssertTrue(error is ImageConversionError)
        }

        await fulfillment(of: [localReadExpectation, inMemoryReadExpectation, networkExpectation])
    }

    // Tests that retrying works if source is good the second time (no crap left behind on error).
    func testRemoteDataIsBadButRetryWorks() async throws {
        let imageCache = Self.buildImageCache()
        let networkExpectation = expectNetworkRead(imageCache: imageCache, returning: Self.badImageData)
        networkExpectation.expectedFulfillmentCount = 2

        let localReadExpectation = expectLocalRead(imageCache: imageCache)
        localReadExpectation.expectedFulfillmentCount = 2 // We're going to go through this twice.

        let inMemoryReadExpectation = expectNoInMemory(imageCache: imageCache)
        inMemoryReadExpectation.expectedFulfillmentCount = 2 // We're going to go through this twice.

        do {
            _ = try await imageCache.cache.cachedValueWith(identifier: Self.dummyURL)
            XCTFail("Exception expected, didn't happen.")
        } catch {
            XCTAssertTrue(error is ImageConversionError)
        }

        _ = expectNetworkRead(imageCache: imageCache, returning: Self.sampleImageData, existing: networkExpectation)

        let localWriteExpectation = expectLocalWrite(imageCache: imageCache)

        let inMemoryWriteExpectation = expectInMemoryWrite(imageCache: imageCache)

        let image = try await imageCache.cache.cachedValueWith(identifier: Self.dummyURL)

        await fulfillment(
            of: [
                localReadExpectation,
                inMemoryReadExpectation,
                networkExpectation,
                localWriteExpectation,
                inMemoryWriteExpectation
            ],
            timeout: 1.0
        )

        // Looping image -> data -> image -> data doesn't usually result in equal data or equal images as some config
        // data gets lost, but at least we can check pixel size.
        XCTAssertEqual(image?.size.width, Self.sampleImage.size.width)
        XCTAssertEqual(image?.size.height, Self.sampleImage.size.height)
    }

    // Tests that retrying works if local data is corrupted and we inivalidate it.
    func testLocalDataIsBadButCleanupAndRetryWorks() async throws {
        let imageCache = Self.buildImageCache()
        let localBadReadExpectation = expectLocalRead(imageCache: imageCache, returning: Self.badImageData)

        let inMemoryReadExpectation = expectNoInMemory(imageCache: imageCache)
        inMemoryReadExpectation.expectedFulfillmentCount = 2 // We're going to go through this twice.

        do {
            _ = try await imageCache.cache.cachedValueWith(identifier: Self.dummyURL)
            XCTFail("Exception expected, didn't happen.")
        } catch {
            XCTAssertTrue(error is ImageConversionError)
        }

        await fulfillment(of: [localBadReadExpectation]) // inMemoryReadExpectation will get more fulfillment later.

        let inMemoryInvalidation = expectation(description: "Invalidating in memory storage")
        imageCache.inMemoryStorage.removeValueForOverride = { url in
            inMemoryInvalidation.fulfill()
            XCTAssertEqual(url, Self.dummyURL)
        }

        let localInvalidation = expectation(description: "Invalidating local storage")
        imageCache.localStorage.removeValueForOverride = { fileName in
            localInvalidation.fulfill()
            XCTAssertEqual(fileName, Self.dummyURL.lastPathComponent)
        }

        // Network invalidation shouldn't be called as it uses read-only storage.

        try await imageCache.cache.invalidateCachedValueFor(identifier: Self.dummyURL)

        await fulfillment(of: [inMemoryInvalidation, localInvalidation], timeout: 1.0)

        // XXXX

        let networkExpectation = expectNetworkRead(imageCache: imageCache, returning: Self.sampleImageData)

        let localGoodReadExpectation = expectLocalRead(imageCache: imageCache)

        let localWriteExpectation = expectLocalWrite(imageCache: imageCache)

        let inMemoryWriteExpectation = expectInMemoryWrite(imageCache: imageCache)

        let image = try await imageCache.cache.cachedValueWith(identifier: Self.dummyURL)

        await fulfillment(
            of: [
                localGoodReadExpectation,
                inMemoryReadExpectation,
                networkExpectation,
                localWriteExpectation,
                inMemoryWriteExpectation
            ],
            timeout: 1.0
        )

        // Looping image -> data -> image -> data doesn't usually result in equal data or equal images as some config
        // data gets lost, but at least we can check pixel size.
        XCTAssertEqual(image?.size.width, Self.sampleImage.size.width)
        XCTAssertEqual(image?.size.height, Self.sampleImage.size.height)
    }
}
