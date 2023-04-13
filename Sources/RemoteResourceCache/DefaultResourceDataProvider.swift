//
//  DefaultResourceDataProvider.swift
//  RemoteResourceCache
//
//  Created by Óscar Morales Vivó on 1/9/23.
//

import Foundation

/**
 The default implementation of `ImageDataProvider` uses `URLSession` to download remote content and stores local
 data in the app's `FileManager.default.temporaryFolder`, using unique file names based on its URL UUID and name.
 */
public struct DefaultResourceDataProvider: ResourceDataProvider {
    public init() {}

    public func remoteData(remoteURL: URL) async throws -> Data {
        let (imageData, _) = try await URLSession.shared.data(from: remoteURL)
        return imageData
    }

    public func localData(remoteURL: URL) throws -> Data {
        try Data(contentsOf: FileManager.default.localCacheURLFor(remoteImageURL: remoteURL))
    }

    public func storeLocally(data: Data, remoteURL: URL) throws {
        let localURL = FileManager.default.localCacheURLFor(remoteImageURL: remoteURL)
        try data.write(to: localURL)
    }
}

private extension FileManager {
    func localCacheURLFor(remoteImageURL: URL) -> URL {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return temporaryDirectory.appending(component: remoteImageURL.storageIdentifier)
        } else {
            var result = temporaryDirectory
            result.appendPathComponent(remoteImageURL.storageIdentifier, isDirectory: false)
            return result
        }
    }
}

private extension URL {
    var storageIdentifier: String {
        // A bit of a blast form the past but if it works it works.
        (pathComponents.suffix(2) as NSArray).componentsJoined(by: "-")
    }
}
