//
//  MockResourceDataProvider.swift
//  RemoteResourceCache
//
//  Created by Óscar Morales Vivó on 4/11/23.
//

import Foundation
import RemoteResourceCache

/**
 Simple mock resource data provider for testing purposes.

 Set up its override blocks to specify the behavior you want.
 */
public struct MockResourceDataProvider: ResourceDataProvider {
    /// Swift made us declare this.
    public init(
        remoteDataOverride: ((URL) async throws -> Data)? = nil,
        localDataOverride: ((URL) throws -> Data)? = nil,
        storeLocallyOverride: ((Data, URL) throws -> Void)? = nil
    ) {
        self.remoteDataOverride = remoteDataOverride
        self.localDataOverride = localDataOverride
        self.storeLocallyOverride = storeLocallyOverride
    }

    /// Error thrown when a method is called with no override set.
    struct UnimplementedError: Error {}

    public var remoteDataOverride: ((URL) async throws -> Data)?

    public func remoteData(remoteURL: URL) async throws -> Data {
        if let remoteDataOverride {
            return try await remoteDataOverride(remoteURL)
        } else {
            throw UnimplementedError()
        }
    }

    public var localDataOverride: ((URL) throws -> Data)?

    public func localData(remoteURL: URL) throws -> Data {
        if let localDataOverride {
            return try localDataOverride(remoteURL)
        } else {
            throw UnimplementedError()
        }
    }

    public var storeLocallyOverride: ((Data, URL) throws -> Void)?

    public func storeLocally(data: Data, remoteURL: URL) throws {
        if let storeLocallyOverride {
            return try storeLocallyOverride(data, remoteURL)
        } else {
            throw UnimplementedError()
        }
    }
}
