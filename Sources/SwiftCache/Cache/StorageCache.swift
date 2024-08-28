//
//  StorageCache.swift
//
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

private struct SyncStorageSyncCache<
    ID: Hashable,
    Value,
    Storage: SyncStorage,
    Parent: SyncCache
>: SyncCache where Storage.ID == ID, Storage.Value == Value, Parent.ID == ID, Parent.Value == Value {
    let parent: Parent

    let storage: Storage

    func cachedValueWith(id: ID) -> Value {
        if let storedValue = storage.valueFor(id: id) {
            return storedValue
        } else {
            let newValue = parent.cachedValueWith(id: id)
            storage.store(value: newValue, id: id)
            return newValue
        }
    }
}

public extension SyncCache {
    func storage<Storage: SyncStorage>(
        _ storage: Storage
    ) -> some SyncCache<ID, Value> where Storage.ID == ID, Storage.Value == Value {
        SyncStorageSyncCache(parent: self, storage: storage)
    }
}

private struct AsyncStorageSyncCache<
    ID: Hashable,
    Value,
    Storage: AsyncStorage,
    Parent: SyncCache
>: AsyncCache where Storage.ID == ID, Storage.Value == Value, Parent.ID == ID, Parent.Value == Value {
    let parent: Parent

    let storage: Storage

    func cachedValueWith(id: ID) async -> Value {
        if let storedValue = await storage.valueFor(id: id) {
            return storedValue
        } else {
            let newValue = parent.cachedValueWith(id: id)
            await storage.store(value: newValue, id: id)
            return newValue
        }
    }
}

public extension SyncCache {
    func storage<Storage: AsyncStorage>(
        _ storage: Storage
    ) -> some AsyncCache<ID, Value> where Storage.ID == ID, Storage.Value == Value {
        AsyncStorageSyncCache(parent: self, storage: storage)
    }
}

private struct SyncStorageThrowingSyncCache<
    ID: Hashable,
    Value,
    Storage: SyncStorage,
    Parent: ThrowingSyncCache
>: ThrowingSyncCache where Storage.ID == ID, Storage.Value == Value, Parent.ID == ID, Parent.Value == Value {
    let parent: Parent

    let storage: Storage

    func cachedValueWith(id: ID) throws -> Value {
        if let storedValue = storage.valueFor(id: id) {
            return storedValue
        } else {
            let newValue = try parent.cachedValueWith(id: id)
            storage.store(value: newValue, id: id)
            return newValue
        }
    }
}

public extension ThrowingSyncCache {
    func storage<Storage: SyncStorage>(
        _ storage: Storage
    ) -> some ThrowingSyncCache<ID, Value> where Storage.ID == ID, Storage.Value == Value {
        SyncStorageThrowingSyncCache(parent: self, storage: storage)
    }
}

private struct AsyncStorageThrowingSyncCache<
    ID: Hashable,
    Value,
    Storage: AsyncStorage,
    Parent: ThrowingSyncCache
>: ThrowingAsyncCache where Storage.ID == ID, Storage.Value == Value, Parent.ID == ID, Parent.Value == Value {
    let parent: Parent

    let storage: Storage

    func cachedValueWith(id: ID) async throws -> Value {
        if let storedValue = await storage.valueFor(id: id) {
            return storedValue
        } else {
            let newValue = try parent.cachedValueWith(id: id)
            await storage.store(value: newValue, id: id)
            return newValue
        }
    }
}

public extension ThrowingSyncCache {
    func storage<Storage: AsyncStorage>(
        _ storage: Storage
    ) -> some ThrowingAsyncCache<ID, Value> where Storage.ID == ID, Storage.Value == Value {
        AsyncStorageThrowingSyncCache(parent: self, storage: storage)
    }
}

private struct SyncStorageAsyncCache<
    ID: Hashable,
    Value,
    Storage: SyncStorage,
    Parent: AsyncCache
>: AsyncCache where Storage.ID == ID, Storage.Value == Value, Parent.ID == ID, Parent.Value == Value {
    let parent: Parent

    let storage: Storage

    func cachedValueWith(id: ID) async -> Value {
        if let storedValue = storage.valueFor(id: id) {
            return storedValue
        } else {
            let newValue = await parent.cachedValueWith(id: id)
            storage.store(value: newValue, id: id)
            return newValue
        }
    }
}

public extension AsyncCache {
    func storage<Storage: SyncStorage>(
        _ storage: Storage
    ) -> some AsyncCache<ID, Value> where Storage.ID == ID, Storage.Value == Value {
        SyncStorageAsyncCache(parent: self, storage: storage)
    }
}

private struct AsyncStorageAsyncCache<
    ID: Hashable,
    Value,
    Storage: AsyncStorage,
    Parent: AsyncCache
>: AsyncCache where Storage.ID == ID, Storage.Value == Value, Parent.ID == ID, Parent.Value == Value {
    let parent: Parent

    let storage: Storage

    func cachedValueWith(id: ID) async -> Value {
        if let storedValue = await storage.valueFor(id: id) {
            return storedValue
        } else {
            let newValue = await parent.cachedValueWith(id: id)
            await storage.store(value: newValue, id: id)
            return newValue
        }
    }
}

public extension AsyncCache {
    func storage<Storage: AsyncStorage>(
        _ storage: Storage
    ) -> some AsyncCache<ID, Value> where Storage.ID == ID, Storage.Value == Value {
        AsyncStorageAsyncCache(parent: self, storage: storage)
    }
}

private struct SyncStorageThrowingAsyncCache<
    ID: Hashable,
    Value,
    Storage: SyncStorage,
    Parent: ThrowingAsyncCache
>: ThrowingAsyncCache where Storage.ID == ID, Storage.Value == Value, Parent.ID == ID, Parent.Value == Value {
    let parent: Parent

    let storage: Storage

    func cachedValueWith(id: ID) async throws -> Value {
        if let storedValue = storage.valueFor(id: id) {
            return storedValue
        } else {
            let newValue = try await parent.cachedValueWith(id: id)
            storage.store(value: newValue, id: id)
            return newValue
        }
    }
}

public extension ThrowingAsyncCache {
    func storage<Storage: SyncStorage>(
        _ storage: Storage
    ) -> some ThrowingAsyncCache<ID, Value> where Storage.ID == ID, Storage.Value == Value {
        SyncStorageThrowingAsyncCache(parent: self, storage: storage)
    }
}

private struct AsyncStorageThrowingAsyncCache<
    ID: Hashable,
    Value,
    Storage: AsyncStorage,
    Parent: ThrowingAsyncCache
>: ThrowingAsyncCache where Storage.ID == ID, Storage.Value == Value, Parent.ID == ID, Parent.Value == Value {
    let parent: Parent

    let storage: Storage

    func cachedValueWith(id: ID) async throws -> Value {
        if let storedValue = await storage.valueFor(id: id) {
            return storedValue
        } else {
            let newValue = try await parent.cachedValueWith(id: id)
            await storage.store(value: newValue, id: id)
            return newValue
        }
    }
}

public extension ThrowingAsyncCache {
    func storage<Storage: AsyncStorage>(
        _ storage: Storage
    ) -> some ThrowingAsyncCache<ID, Value> where Storage.ID == ID, Storage.Value == Value {
        AsyncStorageThrowingAsyncCache(parent: self, storage: storage)
    }
}
