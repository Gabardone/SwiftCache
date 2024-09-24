//
//  CacheMapID.swift
//
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

public extension SyncCache {
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> SyncCache<OtherID, Value> {
        .init { otherID in
            valueForID(transform(otherID))
        }
    }
}

public extension ThrowingSyncCache {
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> ThrowingSyncCache<OtherID, Value> {
        .init { otherID in
            try valueForID(transform(otherID))
        }
    }
}

public extension AsyncCache {
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> AsyncCache<OtherID, Value> {
        .init { otherID in
            await valueForID(transform(otherID))
        }
    }
}

public extension ThrowingAsyncCache {
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> ThrowingAsyncCache<OtherID, Value> {
        .init { otherID in
            try await valueForID(transform(otherID))
        }
    }
}
