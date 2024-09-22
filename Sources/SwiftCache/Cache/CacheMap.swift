//
//  CacheMap.swift
//
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

public extension SyncCache {
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> SyncCache<OtherID, Value> {
        .init { otherID in
            valueForID(transform(otherID))
        }
    }

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
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> ThrowingSyncCache<OtherID, Value> {
        .init { otherID in
            try valueForID(transform(otherID))
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Result<Value, Error>, ID) -> OtherValue
    ) -> SyncCache<ID, OtherValue> {
        SyncCache { id in
            transform(.init(catching: { try valueForID(id) }), id)
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
        _ transform: @escaping (Result<Value, Error>, ID) throws -> OtherValue
    ) -> ThrowingSyncCache<ID, OtherValue> {
        .init { id in
            try transform(.init(catching: { try valueForID(id) }), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Result<Value, Error>, ID) async -> OtherValue
    ) -> AsyncCache<ID, OtherValue> {
        .init { id in
            await transform(.init(catching: { try valueForID(id) }), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) async throws -> OtherValue
    ) -> ThrowingAsyncCache<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Result<Value, Error>, ID) async throws -> OtherValue
    ) -> ThrowingAsyncCache<ID, OtherValue> {
        .init { id in
            try await transform(.init(catching: { try valueForID(id) }), id)
        }
    }
}

public extension AsyncCache {
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> AsyncCache<OtherID, Value> {
        .init { otherID in
            await valueForID(transform(otherID))
        }
    }

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
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> ThrowingAsyncCache<OtherID, Value> {
        .init { otherID in
            try await valueForID(transform(otherID))
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Result<Value, Error>, ID) -> OtherValue
    ) -> AsyncCache<ID, OtherValue> {
        .init { id in
            await transform(.init(asyncCatching: { try await valueForID(id) }), id)
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
        _ transform: @escaping (Result<Value, Error>, ID) throws -> OtherValue
    ) -> ThrowingAsyncCache<ID, OtherValue> {
        .init { id in
            try await transform(.init(asyncCatching: { try await valueForID(id) }), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Result<Value, Error>, ID) async -> OtherValue
    ) -> AsyncCache<ID, OtherValue> {
        .init { id in
            await transform(.init(asyncCatching: { try await valueForID(id) }), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) async throws -> OtherValue
    ) -> ThrowingAsyncCache<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Result<Value, Error>, ID) async throws -> OtherValue
    ) -> ThrowingAsyncCache<ID, OtherValue> {
        .init { id in
            try await transform(.init(asyncCatching: { try await valueForID(id) }), id)
        }
    }
}
