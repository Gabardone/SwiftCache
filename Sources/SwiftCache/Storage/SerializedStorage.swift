//
//  SerializedStorage.swift
//  SwiftCache
//
//  Created by Óscar Morales Vivó on 9/1/24.
//

private actor SerializedStorage<
    ID: Hashable,
    Value,
    Serialized: SyncStorage
> where Serialized.ID == ID, Serialized.Value == Value {
    let serialized: Serialized

    init(serializing storage: Serialized) {
        self.serialized = storage
    }
}

extension SerializedStorage: AsyncStorage {
    func valueFor(id: ID) -> Value? {
        serialized.valueFor(id: id)
    }

    func store(value: Value, id: ID) {
        serialized.store(value: value, id: id)
    }
}

public extension SyncStorage {
    /// Returns a wrapper for a sync storage that guarantees serialization.
    ///
    /// If a sync storage needs to be used in an `async` context and it doesn't play well with concurrency —usually
    /// because you want to avoid data races with its state management— you will want to wrap it in one of these before
    /// attaching to a storage cache.
    ///
    /// This is not particularly problematic for storage types that live close to the call site i.e. in-memory storage.
    /// Normally you will be using a `Dictionary` or similar collection to keep your stored values around and those are
    /// both fast and do not play well with concurrency.
    func serialized() -> some AsyncStorage<ID, Value> {
        SerializedStorage(serializing: self)
    }
}
