//
//  File.swift
//
//
//  Created by Óscar Morales Vivó on 4/13/23.
//

import Foundation

/**
 Type erasing wrapper for a `ResourceDataProvider` with certain associated types.

 Despite the improvents in protocol existential use in Swift in the last few years, we still need this type to be able
 to do things like use a particular resource data provider as an abstracted injected dependency.
 */
public struct AnyResourceDataProvider<RemoteAddress: Hashable, LocalIdentifier: Hashable> {
    /**
     The type eraser can initialize with anything that implements `ResourceDataProvider` with the same associated types.
     - Parameter wrapping: The value that implements `ResourceDataProvider` with the same `RemoteAddress` and
     `LocalIdentifier` as this type eraser.
     */
    init<RDP>(
        wrapping: RDP
    ) where RDP: ResourceDataProvider, RDP.LocalIdentifier == LocalIdentifier, RDP.RemoteAddress == RemoteAddress {
        self.remoteDataWrapper = { remoteAddress in
            try await wrapping.remoteData(remoteAddress: remoteAddress)
        }
        self.localDataWrapper = { localIdentifier in
            try await wrapping.localData(localIdentifier: localIdentifier)
        }
        self.storeLocallyWrapper = { data, localIdentifier in
            try await wrapping.storeLocally(data: data, localIdentifier: localIdentifier)
        }
    }

    // MARK: - Stored Properties

    private let remoteDataWrapper: (RemoteAddress) async throws -> Data

    private let localDataWrapper: (LocalIdentifier) async throws -> Data

    private let storeLocallyWrapper: (Data, LocalIdentifier) async throws -> Void
}

// MARK: - ResourceDataProvider Adoption

extension AnyResourceDataProvider: ResourceDataProvider {
    public func remoteData(remoteAddress: RemoteAddress) async throws -> Data {
        try await remoteDataWrapper(remoteAddress)
    }

    public func localData(localIdentifier: LocalIdentifier) async throws -> Data {
        try await localDataWrapper(localIdentifier)
    }

    public func storeLocally(data: Data, localIdentifier: LocalIdentifier) async throws {
        try await storeLocallyWrapper(data, localIdentifier)
    }
}
