//
//  CacheMapID.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/3/24.
//

public extension SyncCache {
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> some SyncCache<OtherID, Value> {
        AnySyncCache { id in
            valueFor(id: transform(id))
        } storeValueForID: { value, id in
            store(value: value, id: transform(id))
        }
    }
}

public extension AsyncCache {
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> some AsyncCache<OtherID, Value> {
        AnyAsyncCache { id in
            await valueFor(id: transform(id))
        } storeValueForID: { value, id in
            await store(value: value, id: transform(id))
        }
    }
}
