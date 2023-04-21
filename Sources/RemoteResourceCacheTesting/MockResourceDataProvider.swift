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

 Declared as a reference type so the overrides can be "safely" swapped during a test.
 */
public class MockResourceDataProvider: ResourceDataProvider {
    /// Swift made us declare this.
    public init(
        remoteDataOverride: ((URL) async throws -> Data)? = nil,
        localDataOverride: ((String) throws -> Data)? = nil,
        storeLocallyOverride: ((Data, String) throws -> Void)? = nil
    ) {
        self.remoteDataOverride = remoteDataOverride
        self.localDataOverride = localDataOverride
        self.storeLocallyOverride = storeLocallyOverride
    }

    /// Error thrown when a method is called with no override set.
    struct UnimplementedError: Error {}

    public var remoteDataOverride: ((URL) async throws -> Data)?

    public func remoteData(remoteAddress: URL) async throws -> Data {
        if let remoteDataOverride {
            return try await remoteDataOverride(remoteAddress)
        } else {
            throw UnimplementedError()
        }
    }

    public var localDataOverride: ((String) throws -> Data)?

    public func localData(localIdentifier: String) throws -> Data {
        if let localDataOverride {
            return try localDataOverride(localIdentifier)
        } else {
            throw UnimplementedError()
        }
    }

    public var storeLocallyOverride: ((Data, String) throws -> Void)?

    public func storeLocally(data: Data, localIdentifier: String) throws {
        if let storeLocallyOverride {
            return try storeLocallyOverride(data, localIdentifier)
        } else {
            throw UnimplementedError()
        }
    }
}
