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

    public func remoteData(remoteAddress: URL) async throws -> Data {
        let (imageData, _) = try await URLSession.shared.data(from: remoteAddress)
        return imageData
    }

    public func localData(localIdentifier: String) throws -> Data {
        try Data(contentsOf: FileManager.default.localCacheURLFor(localIdentifier: localIdentifier))
    }

    public func storeLocally(data: Data, localIdentifier: String) throws {
        let localURL = FileManager.default.localCacheURLFor(localIdentifier: localIdentifier)
        try data.write(to: localURL)
    }
}

private extension FileManager {
    func localCacheURLFor(localIdentifier: String) -> URL {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return temporaryDirectory.appending(component: localIdentifier)
        } else {
            var result = temporaryDirectory
            result.appendPathComponent(localIdentifier, isDirectory: false)
            return result
        }
    }
}
