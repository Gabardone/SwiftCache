//
//  CacheMapValue.swift
//
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

public extension SyncCache {
    func mapValue<OtherValue>(_ transform: @escaping (Value, ID) -> OtherValue) -> SyncCache<ID, OtherValue> {
        .init { id in
            transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) throws -> OtherValue
    ) -> ThrowingSyncCache<ID, OtherValue> {
        .init { id in
            try transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(_ transform: @escaping (Value, ID) async -> OtherValue) -> AsyncCache<ID, OtherValue> {
        .init { id in
            await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) async throws -> OtherValue
    ) -> ThrowingAsyncCache<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }
}

public extension ThrowingSyncCache {
    func mapValue<OtherValue>(_ transform: @escaping (Value, ID) -> OtherValue) -> ThrowingSyncCache<ID, OtherValue> {
        .init { id in
            try transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) throws -> OtherValue
    ) -> ThrowingSyncCache<ID, OtherValue> {
        .init { id in
            try transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) async -> OtherValue
    ) -> ThrowingAsyncCache<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) async throws -> OtherValue
    ) -> ThrowingAsyncCache<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }
}

public extension AsyncCache {
    func mapValue<OtherValue>(_ transform: @escaping (Value, ID) -> OtherValue) -> AsyncCache<ID, OtherValue> {
        .init { id in
            await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) throws -> OtherValue
    ) -> ThrowingAsyncCache<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(_ transform: @escaping (Value, ID) async -> OtherValue) -> AsyncCache<ID, OtherValue> {
        .init { id in
            await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) async throws -> OtherValue
    ) -> ThrowingAsyncCache<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }
}

public extension ThrowingAsyncCache {
    func mapValue<OtherValue>(_ transform: @escaping (Value, ID) -> OtherValue) -> ThrowingAsyncCache<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) throws -> OtherValue
    ) -> ThrowingAsyncCache<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) async -> OtherValue
    ) -> ThrowingAsyncCache<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) async throws -> OtherValue
    ) -> ThrowingAsyncCache<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }
}
