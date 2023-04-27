//
//  LocalFileDataStorage.swift
//
//
//  Created by Óscar Morales Vivó on 4/23/23.
//

import Foundation

/**
 A simple implementation of local file system storage for caching.

 Storage is keyed by file names, which are appended to the given storage directory (defaults to an unique directory
 inside the app sandbox temporary directory). The identifiers passed in need to be valid file names for the local file
 system and remain unique not just for the storage but for any other file system activity in the storage's root
 directory.

 The identifiers also need to maintain uniqueness with respect to the original cache IDs they have been derived from.
 */
public struct LocalFileDataStorage {
    /**
     Initializes the local file data storage with a given directory to store the files.
     - Parameter rootDirectory: The directory where the data will be stored and retrieved. Has to be a local file system
     directory that the application can read and write from. Defaults to the app's sandbox temporary directory.
     */
    public init(rootDirectory: URL = Self.safeTemporaryDirectory()) throws {
        self.rootDirectory = rootDirectory

        // Make sure the directory exists.
        try FileManager.default.createDirectory(at: rootDirectory, withIntermediateDirectories: true)
    }

    /**
     Creates a unique directory inside the temporary directory for safe file caching.
     - Returns: A unique directory inside ``FileManager.temporaryDirectory``
     */
    public static func safeTemporaryDirectory() -> URL {
        if #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) {
            return FileManager.default.temporaryDirectory.appending(
                component: UUID().uuidString,
                directoryHint: .isDirectory
            )
        } else {
            return FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        }
    }

    private let rootDirectory: URL
}

// MARK: - ReadOnlyStorage Adoption

extension LocalFileDataStorage: StorageSource {
    public typealias Stored = Data

    public typealias StorageID = String

    public func storedValueFor(identifier: String) async throws -> Data? {
        // Wrapped in a task for asynchronous behavior.
        try await Task {
            do {
                if #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) {
                    return try Data(contentsOf: rootDirectory.appending(path: identifier, directoryHint: .notDirectory))
                } else {
                    return try Data(contentsOf: rootDirectory.appendingPathComponent(identifier, isDirectory: false))
                }
            } catch let error as NSError {
                if error.domain == NSCocoaErrorDomain, error.code == NSFileReadNoSuchFileError {
                    // File not found error means no stored value, so return `nil`.
                    return nil
                } else {
                    throw error
                }
            }
        }.value
    }
}

// MARK: - Storage Adoption

extension LocalFileDataStorage: Storage {
    public func store(value: Data, identifier: String) async throws {
        // Wrapped in a task for asynchronous behavior.
        try await Task {
            if #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) {
                try value.write(to: rootDirectory.appending(path: identifier, directoryHint: .notDirectory))
            } else {
                try value.write(to: rootDirectory.appendingPathComponent(identifier, isDirectory: false))
            }
        }.value
    }

    public func removeValueFor(identifier: String) async throws {
        try await Task {
            do {
                let fileURL: URL
                if #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) {
                    fileURL = rootDirectory.appending(path: identifier, directoryHint: .notDirectory)
                } else {
                    fileURL = rootDirectory.appendingPathComponent(identifier, isDirectory: false)
                }
                try FileManager.default.removeItem(at: fileURL)
            } catch let error as NSError
                where error.domain == NSCocoaErrorDomain && error.code == NSFileNoSuchFileError {
                // File not found is fine. We'll let it go.
            }
        }.value
    }
}
