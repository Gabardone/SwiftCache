//
//  CachingProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

public extension SyncProvider {
    func cache(_ cache: some SyncCache<ID, Value>) -> SyncProvider {
        sideEffect { value, id in
            cache.store(value: value, id: id)
        }
        .interject { id in
            cache.valueFor(id: id)
        }
    }

    func cache(_ cache: some AsyncCache<ID, Value>) -> AsyncProvider<ID, Value> {
        sideEffect { value, id in
            await cache.store(value: value, id: id)
        }
        .interject { id in
            await cache.valueFor(id: id)
        }
    }
}

public extension ThrowingSyncProvider {
    func cache(_ cache: some SyncCache<ID, Value>) -> ThrowingSyncProvider {
        sideEffect { value, id in
            cache.store(value: value, id: id)
        }
        .interject { id in
            cache.valueFor(id: id)
        }
    }

    func cache(_ cache: some AsyncCache<ID, Value>) -> ThrowingAsyncProvider<ID, Value> {
        sideEffect { value, id in
            await cache.store(value: value, id: id)
        }
        .interject { id in
            await cache.valueFor(id: id)
        }
    }
}

public extension AsyncProvider {
    func cache(_ cache: some SyncCache<ID, Value>) -> AsyncProvider {
        sideEffect { value, id in
            cache.store(value: value, id: id)
        }
        .interject { id in
            cache.valueFor(id: id)
        }
    }

    func cache(_ cache: some AsyncCache<ID, Value>) -> AsyncProvider {
        sideEffect { value, id in
            await cache.store(value: value, id: id)
        }
        .interject { id in
            await cache.valueFor(id: id)
        }
    }
}

public extension ThrowingAsyncProvider {
    func cache(_ cache: some SyncCache<ID, Value>) -> ThrowingAsyncProvider {
        sideEffect { value, id in
            cache.store(value: value, id: id)
        }
        .interject { id in
            cache.valueFor(id: id)
        }
    }

    func cache(_ cache: some AsyncCache<ID, Value>) -> ThrowingAsyncProvider {
        sideEffect { value, id in
            await cache.store(value: value, id: id)
        }
        .interject { id in
            await cache.valueFor(id: id)
        }
    }
}
