//
//  StorageMap.swift
//  SwiftCache
//
//  Created by Óscar Morales Vivó on 8/22/24.
//

public extension SyncStorage {
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> some SyncStorage<OtherID, Value> {
        AnySyncStorage { id in
            valueFor(id: transform(id))
        } storeValueForID: { value, id in
            store(value: value, id: transform(id))
        }
    }

    func mapValue<OtherValue>(
        toStorage: @escaping (OtherValue) -> Value,
        fromStorage: @escaping (Value?) -> OtherValue?
    ) -> some SyncStorage<ID, OtherValue> {
        AnySyncStorage { id in
            fromStorage(valueFor(id: id))
        } storeValueForID: { value, id in
            store(value: toStorage(value), id: id)
        }
    }

    func mapValue<OtherValue>(
        toStorage: @escaping (OtherValue) async -> Value,
        fromStorage: @escaping (Value?) async -> OtherValue?
    ) -> some AsyncStorage<ID, OtherValue> {
        AnyAsyncStorage { id in
            await fromStorage(valueFor(id: id))
        } storeValueForID: { value, id in
            await store(value: toStorage(value), id: id)
        }
    }
}

public extension AsyncStorage {
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> some AsyncStorage<OtherID, Value> {
        AnyAsyncStorage { id in
            await valueFor(id: transform(id))
        } storeValueForID: { value, id in
            await store(value: value, id: transform(id))
        }
    }

    func mapValue<OtherValue>(
        toStorage: @escaping (OtherValue) -> Value,
        fromStorage: @escaping (Value?) -> OtherValue?
    ) -> some AsyncStorage<ID, OtherValue> {
        AnyAsyncStorage { id in
            await fromStorage(valueFor(id: id))
        } storeValueForID: { value, id in
            await store(value: toStorage(value), id: id)
        }
    }

    func mapValue<OtherValue>(
        toStorage: @escaping (OtherValue) async -> Value,
        fromStorage: @escaping (Value?) async -> OtherValue?
    ) -> some AsyncStorage<ID, OtherValue> {
        AnyAsyncStorage { id in
            await fromStorage(valueFor(id: id))
        } storeValueForID: { value, id in
            await store(value: toStorage(value), id: id)
        }
    }
}
