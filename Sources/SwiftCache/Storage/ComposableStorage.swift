//
//  ComposableStorage.swift
//  SwiftCache
//
//  Created by Óscar Morales Vivó on 4/11/23.
//

import Foundation

public struct ComposableSyncStorage<ID: Hashable, Value> {
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

extension ComposableSyncStorage: SyncStorage {
    public func valueFor(id: ID) -> Value? {
        valueForID(id)
    }

    public func store(value: Value, id: ID) {
        storeValueForID(value, id)
    }
}

public struct ComposableAsyncStorage<ID: Hashable, Value> {
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

extension ComposableAsyncStorage: AsyncStorage {
    public func valueFor(id: ID) async -> Value? {
        await valueForID(id)
    }

    public func store(value: Value, id: ID) async {
        await storeValueForID(value, id)
    }
}
