//
//  NetworkDataSource.swift
//
//
//  Created by Óscar Morales Vivó on 4/23/23.
//

import Foundation
@_exported import NetworkDependency
import os

/**
 A simple implementation of a read only storage that fetches data from the network.

 This should be set up to backstop a cache chain for network backed data, and will `throw` if the requested value
 cannot be found.

 The storage takes in `URL` as a stored value identifier and returns `Data`. It's up to other components in a cache
 chain to convert identifiers and values back and forth to the required types.

 URLs are meant to be web URLs, the storage logic doesn't know how to deal with other request responses.
 */
public struct NetworkDataSource {
    /**
     Initializer with dependencies.

     To make the data source testable we introduce the actual network access as a `NetworkDependency`. By default it
     will get the system `URLSession` based one.
     - Parameter dependencies: The global dependencies where we'll extract a `NetworkDependency` from.
     */
    public init(dependencies: GlobalDependencies = .default) {
        self.dependencies = dependencies
    }

    // MARK: - Types

    public enum NetworkStorageError: Error {
        case unsupportedURLScheme(String?)
        case invalidHTTPResponseStatus(Int)
        case unexpectedResponseType(URLResponse.Type)
    }

    // MARK: - Stored Properties

    private static let defaultSession: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: configuration)
    }()

    private let dependencies: any NetworkDependency
}

// MARK: - ReadOnlyStorage Adoption

extension NetworkDataSource: ValueSource {
    public typealias Stored = Data

    public typealias StorageID = URL

    public func valueFor(identifier: URL) async throws -> Data? {
        guard identifier.scheme == "http" || identifier.scheme == "https" else {
            throw NetworkStorageError.unsupportedURLScheme(identifier.scheme)
        }

        return try await dependencies.network.dataFor(url: identifier)
    }
}
