//
//  RemoteResourceCacheTests.swift
//  RemoteResourceCacheTests
//
//  Created by Óscar Morales Vivó on 4/11/23.
//

#if canImport(UIKit)
import RemoteResourceCache
import RemoteResourceCacheTesting
import XCTest

final class RemoteResourceCacheTests: XCTestCase {
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

    // If the data is found locally, we return it and don't do anything else weird.
    func testLocallyStoredImageDataHappyPath() async throws {
        let localDataExpectation = expectation(description: "Grabbing local data")
        let mockImageDataProvider = MockResourceDataProvider { _ in
            XCTFail("Unexpected call to remoteData(imageURL:)")
            return Self.sampleImageData
        } localDataOverride: { url in
            localDataExpectation.fulfill()
            XCTAssertEqual(url, Self.dummyURL)
            return Self.sampleImageData
        } storeLocallyOverride: { _, _ in
            XCTFail("Unexpected call to storeLocally(data:imageURL:)")
        }

        let imageCache = RemoteImageCache(imageDataProvider: mockImageDataProvider)

        let image = try await imageCache.fetchResource(remoteURL: Self.dummyURL).value

        await fulfillment(of: [localDataExpectation])

        // Looping image -> data -> image -> data doesn't usually result in equal data or equal images as some config
        // data gets lost, but at least we can check pixel size.
        XCTAssertEqual(image.cgImage?.width, Self.sampleImage.cgImage?.width)
        XCTAssertEqual(image.cgImage?.height, Self.sampleImage.cgImage?.height)
    }

    // If the data is not local, we get remote and store.
    func testRemotelyStoredImageDataHappyPath() async throws {
        struct DummyError: Error {}

        let localDataExpectation = expectation(description: "Attempting to grab local data")
        let remoteDataExpectation = expectation(description: "Grabbing remote data")
        let localStoreExpectation = expectation(description: "Storing remote data locally")
        let mockImageDataProvider = MockResourceDataProvider { _ in
            remoteDataExpectation.fulfill()
            return Self.sampleImageData
        } localDataOverride: { _ in
            localDataExpectation.fulfill()
            throw DummyError()
        } storeLocallyOverride: { _, _ in
            localStoreExpectation.fulfill()
        }

        let imageCache = RemoteImageCache(imageDataProvider: mockImageDataProvider)

        let image = try await imageCache.fetchResource(remoteURL: Self.dummyURL).value

        await fulfillment(of: [localDataExpectation, remoteDataExpectation, localStoreExpectation])

        // Looping image -> data -> image -> data doesn't usually result in equal data or equal images as some config
        // data gets lost, but at least we can check pixel size.
        XCTAssertEqual(image.cgImage?.width, Self.sampleImage.cgImage?.width)
        XCTAssertEqual(image.cgImage?.height, Self.sampleImage.cgImage?.height)
    }

    // If the local data is bad we recover by grabbing remote again.
    func testLocalDataIsBad() async throws {
        struct DummyError: Error {}

        let localDataExpectation = expectation(description: "Attempting to grab local data")
        let remoteDataExpectation = expectation(description: "Grabbing remote data")
        let localStoreExpectation = expectation(description: "Storing remote data locally")
        let mockImageDataProvider = MockResourceDataProvider { _ in
            remoteDataExpectation.fulfill()
            return Self.sampleImageData
        } localDataOverride: { _ in
            localDataExpectation.fulfill()
            return Self.badImageData
        } storeLocallyOverride: { _, _ in
            localStoreExpectation.fulfill()
        }

        let imageCache = RemoteImageCache(imageDataProvider: mockImageDataProvider)

        let image = try await imageCache.fetchResource(remoteURL: Self.dummyURL).value

        await fulfillment(of: [localDataExpectation, remoteDataExpectation, localStoreExpectation])

        // Looping image -> data -> image -> data doesn't usually result in equal data or equal images as some config
        // data gets lost, but at least we can check pixel size.
        XCTAssertEqual(image.cgImage?.width, Self.sampleImage.cgImage?.width)
        XCTAssertEqual(image.cgImage?.height, Self.sampleImage.cgImage?.height)
    }

    // If the remote data is bad we throw.
    func testRemoteDataIsBad() async throws {
        struct LocalDummyError: Error {}
        struct RemoteDummyError: Error {}

        let localDataExpectation = expectation(description: "Attempting to grab local data")
        let remoteDataExpectation = expectation(description: "Grabbing remote data")
        let mockImageDataProvider = MockResourceDataProvider { _ in
            remoteDataExpectation.fulfill()
            return Self.badImageData
        } localDataOverride: { _ in
            localDataExpectation.fulfill()
            throw LocalDummyError()
        } storeLocallyOverride: { _, _ in
            XCTFail("We shouldn't have made it here")
        }

        let imageCache = RemoteImageCache(imageDataProvider: mockImageDataProvider)

        do {
            _ = try await imageCache.fetchResource(remoteURL: Self.dummyURL).value
            XCTFail("Shouldn't have made it here")
        } catch {
            XCTAssert(error is RemoteImageCache.UnableToDecodeImageFromData)
        }

        await fulfillment(of: [localDataExpectation, remoteDataExpectation])
    }
}
#endif
