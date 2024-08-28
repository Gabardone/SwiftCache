//
//  LocalFileDataStorage.swift
//  SwiftCache
//
//  Created by Óscar Morales Vivó on 8/22/24.
//

import Foundation
import System

/**
 A simple storage type that stores data in a local cache folder in the local type system.

 The storage is hardcoded to `ID == FilePath` and `Value == Data`. You will normally want to convert to/from your
 cache's `ID` and `Value` using `mapID` and `mapValue` respectively.

 Availability limited by `FilePath` API only being declared in later OS versions.
 */
@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public struct LocalFileDataStorage {
    let storageDirectory: FilePath

    let fileManager: FileManager

    init(storageIdentifier: FilePath, fileManager: FileManager = .default) {
        self.fileManager = fileManager

        // Calculate the storageDirecotry.
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first ?? {
            Cache.logger.warning("""
            User cache directory not found, using temporary directory for local file data storage
            """)
            return fileManager.temporaryDirectory
        }()
        var storagePath = FilePath(cacheDirectory.path)
        storagePath.append(storageIdentifier.components)
        self.storageDirectory = storagePath
    }
}

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension LocalFileDataStorage: SyncStorage {
    public func valueFor(id: FilePath) -> Data? {
        fileManager.contents(atPath: storageDirectory.appending(id.components).description)
    }

    public func store(value: Data, id: FilePath) {
        fileManager.createFile(atPath: storageDirectory.appending(id.components).description, contents: value)
    }
}
