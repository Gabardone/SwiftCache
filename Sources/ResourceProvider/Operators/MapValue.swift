//
//  MapValue.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

public extension SyncResourceProvider {
    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) -> OtherValue
    ) -> SyncResourceProvider<ID, OtherValue> {
        .init { id in
            transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) throws -> OtherValue
    ) -> ThrowingSyncResourceProvider<ID, OtherValue> {
        .init { id in
            try transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) async -> OtherValue
    ) -> AsyncResourceProvider<ID, OtherValue> {
        .init { id in
            await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) async throws -> OtherValue
    ) -> ThrowingAsyncResourceProvider<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }
}

public extension ThrowingSyncResourceProvider {
    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) -> OtherValue
    ) -> ThrowingSyncResourceProvider<ID, OtherValue> {
        .init { id in
            try transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) throws -> OtherValue
    ) -> ThrowingSyncResourceProvider<ID, OtherValue> {
        .init { id in
            try transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) async -> OtherValue
    ) -> ThrowingAsyncResourceProvider<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) async throws -> OtherValue
    ) -> ThrowingAsyncResourceProvider<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }
}

public extension AsyncResourceProvider {
    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) -> OtherValue
    ) -> AsyncResourceProvider<ID, OtherValue> {
        .init { id in
            await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) throws -> OtherValue
    ) -> ThrowingAsyncResourceProvider<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) async -> OtherValue
    ) -> AsyncResourceProvider<ID, OtherValue> {
        .init { id in
            await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) async throws -> OtherValue
    ) -> ThrowingAsyncResourceProvider<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }
}

public extension ThrowingAsyncResourceProvider {
    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) -> OtherValue
    ) -> ThrowingAsyncResourceProvider<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) throws -> OtherValue
    ) -> ThrowingAsyncResourceProvider<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) async -> OtherValue
    ) -> ThrowingAsyncResourceProvider<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }

    func mapValue<OtherValue>(
        _ transform: @escaping (Value, ID) async throws -> OtherValue
    ) -> ThrowingAsyncResourceProvider<ID, OtherValue> {
        .init { id in
            try await transform(valueForID(id), id)
        }
    }
}
