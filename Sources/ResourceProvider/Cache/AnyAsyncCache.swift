//
//  AnyAsyncCache.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 4/11/23.
//

/**
 Type-erased async cache.

 This wrapper value type can be (and is) used to build up adapters for actual cache types, and can also be used to
 build mocks for testing.
 */
public struct AnyAsyncCache<ID: Hashable, Value> {
    public init(
        valueForID: @escaping (ID) async -> Value? = { _ in nil },
        storeValueForID: @escaping (Value, ID) async -> Void = { _, _ in }
    ) {
        self.valueForID = valueForID
        self.storeValueForID = storeValueForID
    }

    public let valueForID: (ID) async -> Value?

    public let storeValueForID: (Value, ID) async -> Void
}

extension AnyAsyncCache: AsyncCache {
    public func valueFor(id: ID) async -> Value? {
        await valueForID(id)
    }

    public func store(value: Value, id: ID) async {
        await storeValueForID(value, id)
    }
}

extension AsyncCache {
    func eraseToAnyCache() -> AnyAsyncCache<ID, Value> {
        AnyAsyncCache { id in
            await valueFor(id: id)
        } storeValueForID: { value, id in
            await store(value: value, id: id)
        }
    }
}
