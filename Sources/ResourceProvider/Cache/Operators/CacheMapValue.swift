//
//  CacheMapValue.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/3/24.
//

public extension SyncCache {
    func mapValue<OtherValue>(
        toStorage: @escaping (OtherValue) -> Value,
        fromStorage: @escaping (Value, ID) -> OtherValue?
    ) -> some SyncCache<ID, OtherValue> {
        AnySyncCache { id in
            valueFor(id: id).flatMap { value in
                fromStorage(value, id)
            }
        } storeValueForID: { value, id in
            store(value: toStorage(value), id: id)
        }
    }

    func mapValue<OtherValue>(
        toStorage: @escaping (OtherValue) async -> Value,
        fromStorage: @escaping (Value, ID) async -> OtherValue?
    ) -> some AsyncCache<ID, OtherValue> {
        AnyAsyncCache { id in
            if let storedValue = valueFor(id: id) {
                await fromStorage(storedValue, id)
            } else {
                nil
            }
        } storeValueForID: { value, id in
            await store(value: toStorage(value), id: id)
        }
    }
}

public extension AsyncCache {
    func mapValue<OtherValue>(
        toStorage: @escaping (OtherValue) -> Value,
        fromStorage: @escaping (Value, ID) -> OtherValue?
    ) -> some AsyncCache<ID, OtherValue> {
        AnyAsyncCache { id in
            await valueFor(id: id).flatMap { storedValue in
                fromStorage(storedValue, id)
            }
        } storeValueForID: { value, id in
            await store(value: toStorage(value), id: id)
        }
    }

    func mapValue<OtherValue>(
        toStorage: @escaping (OtherValue) async -> Value,
        fromStorage: @escaping (Value, ID) async -> OtherValue?
    ) -> some AsyncCache<ID, OtherValue> {
        AnyAsyncCache { id in
            if let storedValue = await valueFor(id: id) {
                await fromStorage(storedValue, id)
            } else {
                nil
            }
        } storeValueForID: { value, id in
            await store(value: toStorage(value), id: id)
        }
    }
}
