//
//  MapID.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

public extension SyncProvider {
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> SyncProvider<OtherID, Value> {
        .init { otherID in
            valueForID(transform(otherID))
        }
    }
}

public extension ThrowingSyncProvider {
    func mapID<OtherID: Hashable>(
        _ transform: @escaping (OtherID) -> ID
    ) -> ThrowingSyncProvider<OtherID, Value> {
        .init { otherID in
            try valueForID(transform(otherID))
        }
    }
}

public extension AsyncProvider {
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> AsyncProvider<OtherID, Value> {
        .init { otherID in
            await valueForID(transform(otherID))
        }
    }
}

public extension ThrowingAsyncProvider {
    func mapID<OtherID: Hashable>(
        _ transform: @escaping (OtherID) -> ID
    ) -> ThrowingAsyncProvider<OtherID, Value> {
        .init { otherID in
            try await valueForID(transform(otherID))
        }
    }
}
