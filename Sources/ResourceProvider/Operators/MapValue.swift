//
//  MapValue.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

public extension SyncProvider {
    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) -> OtherValue
    ) -> SyncProvider<ID, OtherValue> {
        .init { id in
            transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) throws -> OtherValue
    ) -> ThrowingSyncProvider<ID, OtherValue> {
        .init { id in
            try transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) async -> OtherValue
    ) -> AsyncProvider<ID, OtherValue> {
        .init { id in
            await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) async throws -> OtherValue
    ) -> ThrowingAsyncProvider<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }
}

public extension ThrowingSyncProvider {
    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) -> OtherValue
    ) -> ThrowingSyncProvider<ID, OtherValue> {
        .init { id in
            try transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) throws -> OtherValue
    ) -> ThrowingSyncProvider<ID, OtherValue> {
        .init { id in
            try transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) async -> OtherValue
    ) -> ThrowingAsyncProvider<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) async throws -> OtherValue
    ) -> ThrowingAsyncProvider<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }
}

public extension AsyncProvider {
    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) -> OtherValue
    ) -> AsyncProvider<ID, OtherValue> {
        .init { id in
            await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) throws -> OtherValue
    ) -> ThrowingAsyncProvider<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) async -> OtherValue
    ) -> AsyncProvider<ID, OtherValue> {
        .init { id in
            await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) async throws -> OtherValue
    ) -> ThrowingAsyncProvider<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }
}

public extension ThrowingAsyncProvider {
    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) -> OtherValue
    ) -> ThrowingAsyncProvider<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) throws -> OtherValue
    ) -> ThrowingAsyncProvider<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) async -> OtherValue
    ) -> ThrowingAsyncProvider<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) async throws -> OtherValue
    ) -> ThrowingAsyncProvider<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }
}
