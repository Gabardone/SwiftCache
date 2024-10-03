//
//  MapID.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

public extension SyncResourceProvider {
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> SyncResourceProvider<OtherID, Value> {
        .init { otherID in
            valueForID(transform(otherID))
        }
    }
}

public extension ThrowingSyncResourceProvider {
    func mapID<OtherID: Hashable>(
        _ transform: @escaping (OtherID) -> ID
    ) -> ThrowingSyncResourceProvider<OtherID, Value> {
        .init { otherID in
            try valueForID(transform(otherID))
        }
    }
}

public extension AsyncResourceProvider {
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> AsyncResourceProvider<OtherID, Value> {
        .init { otherID in
            await valueForID(transform(otherID))
        }
    }
}

public extension ThrowingAsyncResourceProvider {
    func mapID<OtherID: Hashable>(
        _ transform: @escaping (OtherID) -> ID
    ) -> ThrowingAsyncResourceProvider<OtherID, Value> {
        .init { otherID in
            try await valueForID(transform(otherID))
        }
    }
}
