//
//  LocalFileDataStorage.swift
//  SwiftCache
//
//  Created by Óscar Morales Vivó on 8/22/24.
//

import Foundation
import System

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
        self.storageDirectory = FilePath(cacheDirectory.path).appending(storageIdentifier.components)
    }
}

extension LocalFileDataStorage: SyncStorage {
    public func valueFor(id: FilePath) -> Data? {
        fileManager.contents(atPath: storageDirectory.appending(id.components).description)
    }

    public func store(value: Data, id: FilePath) {
        fileManager.createFile(atPath: storageDirectory.appending(id.components).description, contents: value)
    }
}
