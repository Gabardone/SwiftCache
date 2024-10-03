//
//  StorageCache.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

public extension SyncResourceProvider {
    func storage(_ storage: some SyncStorage<ID, Value>) -> SyncResourceProvider {
        sideEffect { value, id in
            storage.store(value: value, id: id)
        }
        .interject { id in
            storage.valueFor(id: id)
        }
    }

    func storage(_ storage: some AsyncStorage<ID, Value>) -> AsyncResourceProvider<ID, Value> {
        sideEffect { value, id in
            await storage.store(value: value, id: id)
        }
        .interject { id in
            await storage.valueFor(id: id)
        }
    }
}

public extension ThrowingSyncResourceProvider {
    func storage(_ storage: some SyncStorage<ID, Value>) -> ThrowingSyncResourceProvider {
        sideEffect { value, id in
            storage.store(value: value, id: id)
        }
        .interject { id in
            storage.valueFor(id: id)
        }
    }

    func storage(_ storage: some AsyncStorage<ID, Value>) -> ThrowingAsyncResourceProvider<ID, Value> {
        sideEffect { value, id in
            await storage.store(value: value, id: id)
        }
        .interject { id in
            await storage.valueFor(id: id)
        }
    }
}

public extension AsyncResourceProvider {
    func storage(_ storage: some SyncStorage<ID, Value>) -> AsyncResourceProvider {
        sideEffect { value, id in
            storage.store(value: value, id: id)
        }
        .interject { id in
            storage.valueFor(id: id)
        }
    }

    func storage(_ storage: some AsyncStorage<ID, Value>) -> AsyncResourceProvider {
        sideEffect { value, id in
            await storage.store(value: value, id: id)
        }
        .interject { id in
            await storage.valueFor(id: id)
        }
    }
}

public extension ThrowingAsyncResourceProvider {
    func storage(_ storage: some SyncStorage<ID, Value>) -> ThrowingAsyncResourceProvider {
        sideEffect { value, id in
            storage.store(value: value, id: id)
        }
        .interject { id in
            storage.valueFor(id: id)
        }
    }

    func storage(_ storage: some AsyncStorage<ID, Value>) -> ThrowingAsyncResourceProvider {
        sideEffect { value, id in
            await storage.store(value: value, id: id)
        }
        .interject { id in
            await storage.valueFor(id: id)
        }
    }
}
