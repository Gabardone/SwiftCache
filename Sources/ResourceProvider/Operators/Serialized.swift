//
//  Serialized.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/3/24.
//

private actor SyncProviderSerializer<ID: Hashable, Value> {
    typealias Serialized = SyncProvider<ID, Value>

    let serialized: Serialized

    init(serializing provider: Serialized) {
        self.serialized = provider
    }

    func valueFor(id: ID) -> Value {
        serialized.valueForID(id)
    }
}

public extension SyncProvider {
    /// Returns an async wrapper for a sync provider that guarantees serialization.
    ///
    /// If a sync storage needs to be used in an `async` context and it doesn't play well with concurrency —usually
    /// because you want to avoid data races with its state management— you will want to wrap it in one of these before
    /// attaching to a storage cache.
    ///
    /// This is not particularly problematic for storage types that live close to the call site i.e. in-memory storage.
    /// Normally you will be using a `Dictionary` or similar collection to keep your stored values around and those are
    /// both fast and do not play well with concurrency.
    func serialized() -> AsyncProvider<ID, Value> {
        let serializedProvider = SyncProviderSerializer(serializing: self)

        return AsyncProvider { id in
            await serializedProvider.valueFor(id: id)
        }
    }
}

private actor ThrowingSyncProviderSerializer<ID: Hashable, Value> {
    typealias Serialized = ThrowingSyncProvider<ID, Value>

    let serialized: Serialized

    init(serializing provider: Serialized) {
        self.serialized = provider
    }

    func valueFor(id: ID) throws -> Value {
        try serialized.valueForID(id)
    }
}

public extension ThrowingSyncProvider {
    /// Returns an async wrapper for a sync provider that guarantees serialization.
    ///
    /// If a sync storage needs to be used in an `async` context and it doesn't play well with concurrency —usually
    /// because you want to avoid data races with its state management— you will want to wrap it in one of these before
    /// attaching to a storage cache.
    ///
    /// This is not particularly problematic for storage types that live close to the call site i.e. in-memory storage.
    /// Normally you will be using a `Dictionary` or similar collection to keep your stored values around and those are
    /// both fast and do not play well with concurrency.
    func serialized() -> ThrowingAsyncProvider<ID, Value> {
        let serializedProvider = ThrowingSyncProviderSerializer(serializing: self)

        return ThrowingAsyncProvider { id in
            try await serializedProvider.valueFor(id: id)
        }
    }
}
