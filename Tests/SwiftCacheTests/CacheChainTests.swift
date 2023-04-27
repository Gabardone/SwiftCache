//
//  CacheChainTests.swift
//  SwiftCacheTests
//
//  Created by Óscar Morales Vivó on 4/11/23.
//

#if canImport(UIKit)
import SwiftCache
import SwiftCacheTesting
import XCTest

final class CacheChainTests: XCTestCase {
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

    private static let sampleImageData: Data = sampleImage.pngData()!

    private static let badImageData = Data(count: 16)

    private static let dummyURL = URL(string: "https://zombo.com/")!

    private typealias MockImageStorage = MockStorage<UIImage, URL>

    private typealias MockNetworkStorage = MockStorage<Data, URL>

    private typealias MockLocalStorage = MockStorage<Data, String>

    private struct MockImageCache {
        var cache: any Cache<UIImage, URL>

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
            if let image = UIImage(data: data) {
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

    // If the data is found locally, we return it and don't do anything else weird.
    func testLocallyStoredImageDataHappyPath() async throws {
        let imageCache = Self.buildImageCache()
        let localReadExpectation = expectation(description: "Grabbing local data")
        imageCache.localStorage.storedValueForOverride = { fileName in
            localReadExpectation.fulfill()
            XCTAssertEqual(fileName, Self.dummyURL.lastPathComponent)
            return Self.sampleImageData
        }

        let inMemoryReadExpectation = expectation(description: "No in memory image found")
        imageCache.inMemoryStorage.storedValueForOverride = { url in
            XCTAssertEqual(url, Self.dummyURL)
            inMemoryReadExpectation.fulfill()
            return nil
        }

        let inMemoryWriteExpectation = expectation(description: "Storing the image in memory")
        imageCache.inMemoryStorage.storeOverride = { image, url in
            inMemoryWriteExpectation.fulfill()

            // Check that it's the same image as usual.
            XCTAssertEqual(image.cgImage?.width, Self.sampleImage.cgImage?.width)
            XCTAssertEqual(image.cgImage?.height, Self.sampleImage.cgImage?.height)
        }

        let image = try await imageCache.cache.cachedValueWith(identifier: Self.dummyURL)

        await fulfillment(of: [localReadExpectation, inMemoryReadExpectation, inMemoryWriteExpectation])

        // Looping image -> data -> image -> data doesn't usually result in equal data or equal images as some config
        // data gets lost, but at least we can check pixel size.
        XCTAssertEqual(image?.cgImage?.width, Self.sampleImage.cgImage?.width)
        XCTAssertEqual(image?.cgImage?.height, Self.sampleImage.cgImage?.height)
    }

    // If the data is not local, we get remote and store.
    func testRemotelyStoredImageDataHappyPath() async throws {
        let imageCache = Self.buildImageCache()
        let networkReadExpectation = expectation(description: "Returning network data")
        imageCache.networkStorage.storedValueForOverride = { url in
            networkReadExpectation.fulfill()
            XCTAssertEqual(url, Self.dummyURL)
            return Self.sampleImageData
        }

        let localReadExpectation = expectation(description: "No local data found")
        imageCache.localStorage.storedValueForOverride = { fileName in
            localReadExpectation.fulfill()
            XCTAssertEqual(fileName, Self.dummyURL.lastPathComponent)
            return nil
        }

        let localWriteExpectation = expectation(description: "Storing the image locally")
        imageCache.localStorage.storeOverride = { data, identifier in
            localWriteExpectation.fulfill()
            XCTAssertEqual(data, Self.sampleImageData)
        }

        let inMemoryReadExpectation = expectation(description: "No in memory image found")
        imageCache.inMemoryStorage.storedValueForOverride = { url in
            XCTAssertEqual(url, Self.dummyURL)
            inMemoryReadExpectation.fulfill()
            return nil
        }

        let inMemoryWriteExpectation = expectation(description: "Storing the image in memory")
        imageCache.inMemoryStorage.storeOverride = { image, url in
            inMemoryWriteExpectation.fulfill()

            // Check that it's the same image as usual.
            XCTAssertEqual(image.cgImage?.width, Self.sampleImage.cgImage?.width)
            XCTAssertEqual(image.cgImage?.height, Self.sampleImage.cgImage?.height)
        }

        let image = try await imageCache.cache.cachedValueWith(identifier: Self.dummyURL)

        await fulfillment(of: [networkReadExpectation, localReadExpectation, localWriteExpectation, inMemoryReadExpectation, inMemoryWriteExpectation])

        // Looping image -> data -> image -> data doesn't usually result in equal data or equal images as some config
        // data gets lost, but at least we can check pixel size.
        XCTAssertEqual(image?.cgImage?.width, Self.sampleImage.cgImage?.width)
        XCTAssertEqual(image?.cgImage?.height, Self.sampleImage.cgImage?.height)
    }

    // If the local data is bad we recover by grabbing remote again.
    func testLocalDataIsBad() async throws {
        let imageCache = Self.buildImageCache()
        let localReadExpectation = expectation(description: "No local data found")
        imageCache.localStorage.storedValueForOverride = { fileName in
            localReadExpectation.fulfill()
            XCTAssertEqual(fileName, Self.dummyURL.lastPathComponent)
            return Self.badImageData
        }

        let inMemoryReadExpectation = expectation(description: "No in memory image found")
        imageCache.inMemoryStorage.storedValueForOverride = { url in
            XCTAssertEqual(url, Self.dummyURL)
            inMemoryReadExpectation.fulfill()
            return nil
        }

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
        let networkExpectation = expectation(description: "Checking the network")
        imageCache.networkStorage.storedValueForOverride = { url in
            networkExpectation.fulfill()
            XCTAssertEqual(url, Self.dummyURL)
            return Self.badImageData
        }

        let localReadExpectation = expectation(description: "No local data found")
        imageCache.localStorage.storedValueForOverride = { fileName in
            localReadExpectation.fulfill()
            XCTAssertEqual(fileName, Self.dummyURL.lastPathComponent)
            return nil
        }

        let inMemoryReadExpectation = expectation(description: "No in memory image found")
        imageCache.inMemoryStorage.storedValueForOverride = { url in
            XCTAssertEqual(url, Self.dummyURL)
            inMemoryReadExpectation.fulfill()
            return nil
        }

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
        let networkExpectation = expectation(description: "Checking the network")
        networkExpectation.expectedFulfillmentCount = 2
        imageCache.networkStorage.storedValueForOverride = { url in
            networkExpectation.fulfill()
            XCTAssertEqual(url, Self.dummyURL)
            return Self.badImageData
        }

        let localReadExpectation = expectation(description: "No local data found")
        localReadExpectation.expectedFulfillmentCount = 2 // We're going to go through this twice.
        imageCache.localStorage.storedValueForOverride = { fileName in
            localReadExpectation.fulfill()
            XCTAssertEqual(fileName, Self.dummyURL.lastPathComponent)
            return nil
        }

        let inMemoryReadExpectation = expectation(description: "No in memory image found")
        inMemoryReadExpectation.expectedFulfillmentCount = 2 // We're going to go through this twice.
        imageCache.inMemoryStorage.storedValueForOverride = { url in
            XCTAssertEqual(url, Self.dummyURL)
            inMemoryReadExpectation.fulfill()
            return nil
        }

        do {
            _ = try await imageCache.cache.cachedValueWith(identifier: Self.dummyURL)
            XCTFail("Exception expected, didn't happen.")
        } catch {
            XCTAssertTrue(error is ImageConversionError)
        }

        imageCache.networkStorage.storedValueForOverride = { url in
            networkExpectation.fulfill()
            XCTAssertEqual(url, Self.dummyURL)
            return Self.sampleImageData
        }

        let localWriteExpectation = expectation(description: "Writing data to local storage")
        imageCache.localStorage.storeOverride = { data, fileName in
            localWriteExpectation.fulfill()
            XCTAssertEqual(data, Self.sampleImageData)
            XCTAssertEqual(fileName, Self.dummyURL.lastPathComponent)
        }

        let inMemoryWriteExpectation = expectation(description: "Storing image in memory")
        imageCache.inMemoryStorage.storeOverride = { image, url in
            inMemoryWriteExpectation.fulfill()
            XCTAssertEqual(image.cgImage?.width, Self.sampleImage.cgImage?.width)
            XCTAssertEqual(image.cgImage?.height, Self.sampleImage.cgImage?.height)
        }

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
        XCTAssertEqual(image?.cgImage?.width, Self.sampleImage.cgImage?.width)
        XCTAssertEqual(image?.cgImage?.height, Self.sampleImage.cgImage?.height)
    }

    // Tests that retrying works if local data is corrupted and we inivalidate it.
    func testLocalDataIsBadButCleanupAndRetryWorks() async throws {
        let imageCache = Self.buildImageCache()
        let localBadReadExpectation = expectation(description: "No local data found")
        imageCache.localStorage.storedValueForOverride = { fileName in
            localBadReadExpectation.fulfill()
            XCTAssertEqual(fileName, Self.dummyURL.lastPathComponent)
            return Self.badImageData
        }

        let inMemoryReadExpectation = expectation(description: "No in memory image found")
        inMemoryReadExpectation.expectedFulfillmentCount = 2 // We're going to go through this twice.
        imageCache.inMemoryStorage.storedValueForOverride = { url in
            XCTAssertEqual(url, Self.dummyURL)
            inMemoryReadExpectation.fulfill()
            return nil
        }

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

        let networkExpectation = expectation(description: "Checking the network")
        imageCache.networkStorage.storedValueForOverride = { url in
            networkExpectation.fulfill()
            XCTAssertEqual(url, Self.dummyURL)
            return Self.sampleImageData
        }

        let localGoodReadExpectation = expectation(description: "Reading no data after invalidation")
        imageCache.localStorage.storedValueForOverride = { fileName in
            localGoodReadExpectation.fulfill()
            XCTAssertEqual(fileName, Self.dummyURL.lastPathComponent)
            return nil
        }

        let localWriteExpectation = expectation(description: "Writing data to local storage")
        imageCache.localStorage.storeOverride = { data, fileName in
            localWriteExpectation.fulfill()
            XCTAssertEqual(data, Self.sampleImageData)
            XCTAssertEqual(fileName, Self.dummyURL.lastPathComponent)
        }

        let inMemoryWriteExpectation = expectation(description: "Storing image in memory")
        imageCache.inMemoryStorage.storeOverride = { image, url in
            inMemoryWriteExpectation.fulfill()
            XCTAssertEqual(image.cgImage?.width, Self.sampleImage.cgImage?.width)
            XCTAssertEqual(image.cgImage?.height, Self.sampleImage.cgImage?.height)
        }

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
        XCTAssertEqual(image?.cgImage?.width, Self.sampleImage.cgImage?.width)
        XCTAssertEqual(image?.cgImage?.height, Self.sampleImage.cgImage?.height)
    }
}

#endif
