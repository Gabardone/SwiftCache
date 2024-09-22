//
//  StorageCache.swift
//
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

public extension SyncCache {
    func storage(_ storage: some SyncStorage<ID, Value>) -> SyncCache {
        .init { id in
            if let storedValue = storage.valueFor(id: id) {
                return storedValue
            } else {
                let newValue = valueForID(id)
                storage.store(value: newValue, id: id)
                return newValue
            }
        }
    }

    func storage(_ storage: some AsyncStorage<ID, Value>) -> AsyncCache<ID, Value> {
        .init { id in
            if let storedValue = await storage.valueFor(id: id) {
                return storedValue
            } else {
                let newValue = valueForID(id)
                await storage.store(value: newValue, id: id)
                return newValue
            }
        }
    }
}

public extension ThrowingSyncCache {
    func storage(_ storage: some SyncStorage<ID, Value>) -> ThrowingSyncCache {
        .init { id in
            if let storedValue = storage.valueFor(id: id) {
                return storedValue
            } else {
                let newValue = try valueForID(id)
                storage.store(value: newValue, id: id)
                return newValue
            }
        }
    }

    func storage(_ storage: some AsyncStorage<ID, Value>) -> ThrowingAsyncCache<ID, Value>  {
        .init { id in
            if let storedValue = await storage.valueFor(id: id) {
                return storedValue
            } else {
                let newValue = try valueForID(id)
                await storage.store(value: newValue, id: id)
                return newValue
            }
        }
    }
}

public extension AsyncCache {
    func storage(_ storage: some SyncStorage<ID, Value>) -> AsyncCache {
        .init { id in
            if let storedValue = storage.valueFor(id: id) {
                return storedValue
            } else {
                let newValue = await valueForID(id)
                storage.store(value: newValue, id: id)
                return newValue
            }
        }
    }

    func storage(_ storage: some AsyncStorage<ID, Value>) -> AsyncCache {
        .init { id in
            if let storedValue = await storage.valueFor(id: id) {
                return storedValue
            } else {
                let newValue = await valueForID(id)
                await storage.store(value: newValue, id: id)
                return newValue
            }
        }
    }
}

public extension ThrowingAsyncCache {
    func storage(_ storage: some SyncStorage<ID, Value>) -> ThrowingAsyncCache {
        .init { id in
            if let storedValue = storage.valueFor(id: id) {
                return storedValue
            } else {
                let newValue = try await valueForID(id)
                storage.store(value: newValue, id: id)
                return newValue
            }
        }
    }

    func storage(_ storage: some AsyncStorage<ID, Value>) -> ThrowingAsyncCache {
        .init { id in
            if let storedValue = await storage.valueFor(id: id) {
                return storedValue
            } else {
                let newValue = try await valueForID(id)
                await storage.store(value: newValue, id: id)
                return newValue
            }
        }
    }
}
