//
//  LocalFileDataStorage.swift
//
//
//  Created by Óscar Morales Vivó on 4/23/23.
//

@_exported import FileSystemDependency
import Foundation
@_exported import GlobalDependencies

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
     Initializer with dependencies.

     To make the local file data storage testable we introduce the actual file system access as a
     `FileSystemDependency`. By default it will get the system `FileManager.default` and `Data` based one.
     - Parameter dependencies: The global dependencies where we'll extract a `FileSystemDependency` from.
     */
    public init(dependencies: GlobalDependencies = .default) {
        self.dependencies = dependencies
    }

    private let dependencies: any FileSystemDependency
}

// MARK: - ReadOnlyStorage Adoption

extension LocalFileDataStorage: ValueSource {
    public typealias Stored = Data

    public typealias StorageID = URL

    public func valueFor(identifier: URL) async throws -> Data? {
        do {
            return try await dependencies.fileSystem.dataFor(fileURL: identifier)
        } catch let error as NSError {
            if error.domain == NSCocoaErrorDomain, error.code == NSFileReadNoSuchFileError {
                // File not found error means no stored value, so return `nil`.
                return nil
            } else {
                throw error
            }
        }
    }
}

// MARK: - Storage Adoption

extension LocalFileDataStorage: ValueStorage {
    public func store(value: Data, identifier: URL) async throws {
        // Wrapped in a task for asynchronous behavior.
        try await dependencies.fileSystem.write(data: value, fileURL: identifier, doNotOverwrite: false)
    }

    public func removeValueFor(identifier: URL) async throws {
        try await dependencies.fileSystem.removeFileAt(fileURL: identifier)
    }
}
