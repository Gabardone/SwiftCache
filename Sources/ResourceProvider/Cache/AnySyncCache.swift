//
//  AnySyncCache.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/3/24.
//

/**
 Type-erased sync cache.

 This wrapper value type can be (and is) used to build up adapters for actual cache types, and can also be used to
 build mocks for testing.
 */
public struct AnySyncCache<ID: Hashable, Value> {
    public init(
        valueForID: @escaping (ID) -> Value? = { _ in nil },
        storeValueForID: @escaping (Value, ID) -> Void = { _, _ in }
    ) {
        self.valueForID = valueForID
        self.storeValueForID = storeValueForID
    }

    public let valueForID: (ID) -> Value?

    public let storeValueForID: (Value, ID) -> Void
}

extension AnySyncCache: SyncCache {
    public func valueFor(id: ID) -> Value? {
        valueForID(id)
    }

    public func store(value: Value, id: ID) {
        storeValueForID(value, id)
    }
}

extension SyncCache {
    func eraseToAnyCache() -> AnySyncCache<ID, Value> {
        AnySyncCache { id in
            valueFor(id: id)
        } storeValueForID: { value, id in
            store(value: value, id: id)
        }
    }
}
