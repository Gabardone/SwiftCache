//
//  Source.swift
//
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

extension Cache {
    static func source<ID: Hashable, Value>(_ source: @escaping (ID) -> Value) -> some SyncCache<ID, Value> {
        AnySyncCache(valueProvider: source)
    }

    static func source<ID: Hashable, Value>(
        _ source: @escaping (ID) throws -> Value
    ) -> some ThrowingSyncCache<ID, Value> {
        AnyThrowingSyncCache(valueProvider: source)
    }

    static func source<ID: Hashable, Value>(_ source: @escaping (ID) async -> Value) -> some AsyncCache<ID, Value> {
        AnyAsyncCache(valueProvider: source)
    }

    static func source<ID: Hashable, Value>(
        _ source: @escaping (ID) async throws -> Value
    ) -> some ThrowingAsyncCache<ID, Value> {
        AnyThrowingAsyncCache(valueProvider: source)
    }
}
