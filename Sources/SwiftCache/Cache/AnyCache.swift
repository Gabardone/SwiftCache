//
//  AnyCache.swift
//
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

// MARK: - Sync Erased

public struct AnySyncCache<ID: Hashable, Value> {
    private let valueProvider: (ID) -> Value

    public init(valueProvider: @escaping (ID) -> Value) {
        self.valueProvider = valueProvider
    }
}

extension AnySyncCache: SyncCache {
    public func cachedValueWith(id: ID) -> Value {
        valueProvider(id)
    }

    public func eraseToAnyCache() -> AnySyncCache<ID, Value> {
        // Let's not build another wrapper for the wrapper.
        self
    }
}

public extension SyncCache {
    func eraseToAnyCache() -> AnySyncCache<ID, Value> {
        AnySyncCache { id in
            cachedValueWith(id: id)
        }
    }
}

// MARK: - Throwing Sync Erased

public struct AnyThrowingSyncCache<ID: Hashable, Value> {
    private let valueProvider: (ID) throws -> Value

    public init(valueProvider: @escaping (ID) throws -> Value) {
        self.valueProvider = valueProvider
    }
}

extension AnyThrowingSyncCache: ThrowingSyncCache {
    public func cachedValueWith(id: ID) throws -> Value {
        try valueProvider(id)
    }

    public func eraseToAnyCache() -> AnyThrowingSyncCache<ID, Value> {
        // Let's not build another wrapper for the wrapper.
        self
    }
}

public extension ThrowingSyncCache {
    func eraseToAnyCache() -> AnyThrowingSyncCache<ID, Value> {
        AnyThrowingSyncCache { id in
            try cachedValueWith(id: id)
        }
    }
}

// MARK: - Async Erased

public struct AnyAsyncCache<ID: Hashable, Value> {
    private let valueProvider: (ID) async -> Value

    public init(valueProvider: @escaping (ID) async -> Value) {
        self.valueProvider = valueProvider
    }
}

extension AnyAsyncCache: AsyncCache {
    public func cachedValueWith(id: ID) async -> Value {
        await valueProvider(id)
    }

    public func eraseToAnyCache() -> AnyAsyncCache<ID, Value> {
        // Let's not build another wrapper for the wrapper.
        self
    }
}

public extension AsyncCache {
    func eraseToAnyCache() -> AnyAsyncCache<ID, Value> {
        AnyAsyncCache { id in
            await cachedValueWith(id: id)
        }
    }
}

// MARK: - Throwing Async Erased

public struct AnyThrowingAsyncCache<ID: Hashable, Value> {
    private let valueProvider: (ID) async throws -> Value

    public init(valueProvider: @escaping (ID) async throws -> Value) {
        self.valueProvider = valueProvider
    }
}

extension AnyThrowingAsyncCache: ThrowingAsyncCache {
    public func cachedValueWith(id: ID) async throws -> Value {
        try await valueProvider(id)
    }

    public func eraseToAnyCache() -> AnyThrowingAsyncCache<ID, Value> {
        // Let's not build another wrapper for the wrapper.
        self
    }
}

public extension ThrowingAsyncCache {
    func eraseToAnyCache() -> AnyThrowingAsyncCache<ID, Value> {
        AnyThrowingAsyncCache { id in
            try await cachedValueWith(id: id)
        }
    }
}
