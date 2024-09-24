//
//  StorageCache.swift
//
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

public extension SyncCache {
    func storage(_ storage: some SyncStorage<ID, Value>) -> SyncCache {
        sideEffect { value, id in
            storage.store(value: value, id: id)
        }
        .interject { id in
            storage.valueFor(id: id)
        }
    }

    func storage(_ storage: some AsyncStorage<ID, Value>) -> AsyncCache<ID, Value> {
        sideEffect { value, id in
            await storage.store(value: value, id: id)
        }
        .interject { id in
            await storage.valueFor(id: id)
        }
    }
}

public extension ThrowingSyncCache {
    func storage(_ storage: some SyncStorage<ID, Value>) -> ThrowingSyncCache {
        sideEffect { value, id in
            storage.store(value: value, id: id)
        }
        .interject { id in
            storage.valueFor(id: id)
        }
    }

    func storage(_ storage: some AsyncStorage<ID, Value>) -> ThrowingAsyncCache<ID, Value> {
        sideEffect { value, id in
            await storage.store(value: value, id: id)
        }
        .interject { id in
            await storage.valueFor(id: id)
        }
    }
}

public extension AsyncCache {
    func storage(_ storage: some SyncStorage<ID, Value>) -> AsyncCache {
        sideEffect { value, id in
            storage.store(value: value, id: id)
        }
        .interject { id in
            storage.valueFor(id: id)
        }
    }

    func storage(_ storage: some AsyncStorage<ID, Value>) -> AsyncCache {
        sideEffect { value, id in
            await storage.store(value: value, id: id)
        }
        .interject { id in
            await storage.valueFor(id: id)
        }
    }
}

public extension ThrowingAsyncCache {
    func storage(_ storage: some SyncStorage<ID, Value>) -> ThrowingAsyncCache {
        sideEffect { value, id in
            storage.store(value: value, id: id)
        }
        .interject { id in
            storage.valueFor(id: id)
        }
    }

    func storage(_ storage: some AsyncStorage<ID, Value>) -> ThrowingAsyncCache {
        sideEffect { value, id in
            await storage.store(value: value, id: id)
        }
        .interject { id in
            await storage.valueFor(id: id)
        }
    }
}
