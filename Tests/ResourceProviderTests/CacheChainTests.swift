//
//  CacheChainTests.swift
//  SwiftCacheTests
//
//  Created by Óscar Morales Vivó on 4/11/23.
//

import ResourceProvider
import System
import XCTest

final class CacheChainTests: XCTestCase {
    private static let badImageData = Data(count: 16)

    private static let dummyURL = URL(string: "https://zombo.com/")!

    private struct ImageConversionError: Error {}

    /**
     We're using a mock of a three-level cache (in-memory/local file storage/network fetch).
     */
    private static func buildImageCache(
        preloadedWeakObjectStorage: WeakObjectStorage<URL, XXImage>? = nil,
        source: @escaping (URL) async throws -> Data = { _ in
            XCTFail("Unexpected call to network source.")
            return badImageData
        },
        localStorageFetch: @escaping (FilePath) -> Data? = { _ in
            XCTFail("Unexpected call to local storage fetch.")
            return nil
        },
        localStorageStore: @escaping (FilePath, Data) -> Void = { _, _ in
            XCTFail("Unexpected call to local storage store.")
        },
        inMemoryFetchValidation: @escaping (URL, XXImage?) -> Void = { _, _ in
            XCTFail("Unexpected call to in memory storage fetch.")
        },
        inMemoryStoreValidation: @escaping (URL, XXImage) -> Void = { _, _ in
            XCTFail("Unexpected call to local storage store.")
        }
    ) -> ThrowingAsyncResourceProvider<URL, XXImage> {
        ResourceProvider.source(source)
            .mapValue { data, _ in
                // We convert to image early so we validate that the data is good. We wouldn't want to store bad data.
                guard let image = XXImage(data: data) else {
                    throw ImageConversionError()
                }

                return (data, image)
            }
            .storage(TestStorage(valueForID: localStorageFetch, storeValueForID: localStorageStore)
                .mapID { url in
                    // You're usually going to need a `mapID` to use a `LocalFileDataStorage`
                    FilePath(url.lastPathComponent)
                }
                .mapValue { data, _ in
                    // We're only carrying the image for validation.
                    data
                } fromStorage: { data, _ in
                    // It's ok to convert again since if we're here it means we don't have it in memory.
                    XXImage(data: data).map { (data, $0) }
                }
            )
            .mapValue { imageAndData, _ in
                // We no longer need the data after this.
                let (_, image) = imageAndData
                return image
            }
            .storage((preloadedWeakObjectStorage ?? WeakObjectStorage())
                .validated(fetchValidation: inMemoryFetchValidation, storeValidation: inMemoryStoreValidation)
            )
            .coordinated() // Always finish an `async` cache chain with this one. You usually need only one at the end.
    }

    // If the data is already in-memory, immediately returns it.
    func testInMemoryImageHappyPath() async throws {
        let inMemoryStorage = WeakObjectStorage<URL, XXImage>()
        inMemoryStorage.store(value: XXImage.sampleImage, id: Self.dummyURL)
        let inMemoryFetchExpectation = expectation(description: "In-memory storage fetch was called as expected.")

        let imageCache = Self.buildImageCache(
            preloadedWeakObjectStorage: inMemoryStorage,
            inMemoryFetchValidation: { id, value in
                inMemoryFetchExpectation.fulfill()
                XCTAssertEqual(id, Self.dummyURL)
                XCTAssertEqual(value, XXImage.sampleImage)
            }
        )

        let image = try await imageCache.valueForID(Self.dummyURL)

        await fulfillment(of: [inMemoryFetchExpectation])

        XCTAssertEqual(image, XXImage.sampleImage)
    }

    // If the data is found locally, we return it and don't do anything else weird.
    func testLocallyStoredImageDataHappyPath() async throws {
        let localStorageFetchExpectation = expectation(description: "Local storage fetch was called as expected.")
        let inMemoryFetchExpectation = expectation(description: "In-memory storage fetch was called as expected.")
        let inMemoryStoreExpectation = expectation(description: "In-memory storage store was called as expected.")

        let imageCache = Self.buildImageCache(localStorageFetch: { filePath in
            localStorageFetchExpectation.fulfill()
            XCTAssertEqual(filePath, .init(Self.dummyURL.lastPathComponent))
            return XXImage.sampleImageData
        }, inMemoryFetchValidation: { id, value in
            inMemoryFetchExpectation.fulfill()
            XCTAssertEqual(id, Self.dummyURL)
            XCTAssertEqual(value, nil)
        }, inMemoryStoreValidation: { id, value in
            inMemoryStoreExpectation.fulfill()
            XCTAssertEqual(id, Self.dummyURL)
            XCTAssertEqual(value.size, XXImage.sampleImage.size)
        })

        let image = try await imageCache.valueForID(Self.dummyURL)

        await fulfillment(of: [localStorageFetchExpectation, inMemoryFetchExpectation, inMemoryStoreExpectation])

        // Looping image -> data -> image -> data doesn't usually result in equal data or equal images as some config
        // data gets lost, but at least we can check pixel size.
        XCTAssertEqual(image.size, XXImage.sampleImage.size)
    }

    // If the data is not local, we get remote and store.
    func testRemotelyStoredImageDataHappyPath() async throws {
        let networkSourceExpectation = expectation(description: "Network source was called as expected.")
        let localStorageFetchExpectation = expectation(description: "Local storage fetch was called as expected.")
        let localStorageStoreExpectation = expectation(description: "Local storage store was called as expected.")
        let inMemoryFetchExpectation = expectation(description: "In-memory storage fetch was called as expected.")
        let inMemoryStoreExpectation = expectation(description: "In-memory storage store was called as expected.")

        let imageCache = Self.buildImageCache { url in
            networkSourceExpectation.fulfill()
            XCTAssertEqual(url, Self.dummyURL)
            return XXImage.sampleImageData
        } localStorageFetch: { filePath in
            localStorageFetchExpectation.fulfill()
            XCTAssertEqual(filePath, .init(Self.dummyURL.lastPathComponent))
            return nil
        } localStorageStore: { filePath, data in
            localStorageStoreExpectation.fulfill()
            XCTAssertEqual(data, XXImage.sampleImageData)
            XCTAssertEqual(filePath, .init(Self.dummyURL.lastPathComponent))
        } inMemoryFetchValidation: { url, image in
            inMemoryFetchExpectation.fulfill()
            XCTAssertEqual(url, Self.dummyURL)
            XCTAssertNil(image)
        } inMemoryStoreValidation: { url, image in
            inMemoryStoreExpectation.fulfill()
            XCTAssertEqual(url, Self.dummyURL)
            XCTAssertEqual(image.size, XXImage.sampleImage.size)
        }

        let image = try await imageCache.valueForID(Self.dummyURL)

        await fulfillment(
            of: [
                networkSourceExpectation,
                localStorageFetchExpectation,
                localStorageStoreExpectation,
                inMemoryFetchExpectation,
                inMemoryStoreExpectation
            ]
        )

        // Looping image -> data -> image -> data doesn't usually result in equal data or equal images as some config
        // data gets lost, but at least we can check pixel size.
        XCTAssertEqual(image.size, XXImage.sampleImage.size)
    }

    // If the remote data is bad we throw.
    func testRemoteDataIsBad() async throws {
        let networkSourceExpectation = expectation(description: "Network source was called as expected.")
        let localStorageFetchExpectation = expectation(description: "Local storage fetch was called as expected.")
        let inMemoryFetchExpectation = expectation(description: "In-memory storage fetch was called as expected.")

        let imageCache = Self.buildImageCache { url in
            networkSourceExpectation.fulfill()
            XCTAssertEqual(url, Self.dummyURL)
            return Self.badImageData
        } localStorageFetch: { filePath in
            localStorageFetchExpectation.fulfill()
            XCTAssertEqual(filePath, .init(Self.dummyURL.lastPathComponent))
            return nil
        } inMemoryFetchValidation: { url, image in
            inMemoryFetchExpectation.fulfill()
            XCTAssertEqual(url, Self.dummyURL)
            XCTAssertNil(image)
        }

        do {
            _ = try await imageCache.valueForID(Self.dummyURL)
            XCTFail("Exception expected, didn't happen.")
        } catch is ImageConversionError {
            // This block intentionally left blank. This is the error we expect.
        } catch {
            XCTFail("Unexpected error \(error)")
        }

        await fulfillment(of: [networkSourceExpectation, localStorageFetchExpectation, inMemoryFetchExpectation])
    }

    // Tests that retrying works if source is good the second time (no crap left behind on error).
    // swiftlint:disable:next function_body_length
    func testRemoteDataIsBadButRetryWorks() async throws {
        let networkSourceExpectation = expectation(description: "Network source was called as expected.")
        networkSourceExpectation.expectedFulfillmentCount = 2
        let localStorageFetchExpectation = expectation(description: "Local storage fetch was called as expected.")
        localStorageFetchExpectation.expectedFulfillmentCount = 2
        let localStorageStoreExpectation = expectation(description: "Local storage store was called as expected.")
        let inMemoryFetchExpectation = expectation(description: "In-memory storage fetch was called as expected.")
        inMemoryFetchExpectation.expectedFulfillmentCount = 2
        let inMemoryStoreExpectation = expectation(description: "In-memory storage store was called as expected.")

        var firstPass = true
        let imageCache = Self.buildImageCache { url in
            networkSourceExpectation.fulfill()
            XCTAssertEqual(url, Self.dummyURL)
            if firstPass {
                firstPass = false
                return Self.badImageData
            } else {
                return XXImage.sampleImageData
            }
        } localStorageFetch: { filePath in
            localStorageFetchExpectation.fulfill()
            XCTAssertEqual(filePath, .init(Self.dummyURL.lastPathComponent))
            return nil
        } localStorageStore: { filePath, data in
            localStorageStoreExpectation.fulfill()
            XCTAssertEqual(data, XXImage.sampleImageData)
            XCTAssertEqual(filePath, .init(Self.dummyURL.lastPathComponent))
        } inMemoryFetchValidation: { url, image in
            inMemoryFetchExpectation.fulfill()
            XCTAssertEqual(url, Self.dummyURL)
            XCTAssertNil(image)
        } inMemoryStoreValidation: { url, image in
            inMemoryStoreExpectation.fulfill()
            XCTAssertEqual(url, Self.dummyURL)
            XCTAssertEqual(image.size, XXImage.sampleImage.size)
        }

        do {
            _ = try await imageCache.valueForID(Self.dummyURL)
            XCTFail("Exception expected, didn't happen.")
        } catch is ImageConversionError {
            // This block intentionally left blank. This is the error we expect.
        } catch {
            XCTFail("Unexpected error \(error)")
        }

        // Try again, this one should work.
        let image = try await imageCache.valueForID(Self.dummyURL)

        await fulfillment(
            of: [
                networkSourceExpectation,
                localStorageFetchExpectation,
                localStorageStoreExpectation,
                inMemoryFetchExpectation,
                inMemoryStoreExpectation
            ]
        )

        // Looping image -> data -> image -> data doesn't usually result in equal data or equal images as some config
        // data gets lost, but at least we can check pixel size.
        XCTAssertEqual(image.size, XXImage.sampleImage.size)
    }
}
