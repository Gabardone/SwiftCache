//
//  SideEffect.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 9/23/24.
//

public extension SyncProvider {
    func sideEffect(_ sideEffect: @escaping (Value, ID) -> Void) -> SyncProvider {
        .init { id in
            let result = valueForID(id)
            sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) throws -> Void) -> ThrowingSyncProvider<ID, Value> {
        .init { id in
            let result = valueForID(id)
            try sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) async -> Void) -> AsyncProvider<ID, Value> {
        .init { id in
            let result = valueForID(id)
            await sideEffect(result, id)
            return result
        }
    }

    func sideEffect(
        _ sideEffect: @escaping (Value, ID) async throws -> Void
    ) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            let result = valueForID(id)
            try await sideEffect(result, id)
            return result
        }
    }
}

public extension ThrowingSyncProvider {
    func sideEffect(_ sideEffect: @escaping (Value, ID) -> Void) -> ThrowingSyncProvider {
        .init { id in
            let result = try valueForID(id)
            sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) throws -> Void) -> ThrowingSyncProvider {
        .init { id in
            let result = try valueForID(id)
            try sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) async -> Void) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            let result = try valueForID(id)
            await sideEffect(result, id)
            return result
        }
    }

    func sideEffect(
        _ sideEffect: @escaping (Value, ID) async throws -> Void
    ) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            let result = try valueForID(id)
            try await sideEffect(result, id)
            return result
        }
    }
}

public extension AsyncProvider {
    func sideEffect(_ sideEffect: @escaping (Value, ID) -> Void) -> AsyncProvider {
        .init { id in
            let result = await valueForID(id)
            sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) throws -> Void) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            let result = await valueForID(id)
            try sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) async -> Void) -> AsyncProvider {
        .init { id in
            let result = await valueForID(id)
            await sideEffect(result, id)
            return result
        }
    }

    func sideEffect(
        _ sideEffect: @escaping (Value, ID) async throws -> Void
    ) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            let result = await valueForID(id)
            try await sideEffect(result, id)
            return result
        }
    }
}

public extension ThrowingAsyncProvider {
    func sideEffect(_ sideEffect: @escaping (Value, ID) -> Void) -> ThrowingAsyncProvider {
        .init { id in
            let result = try await valueForID(id)
            sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) throws -> Void) -> ThrowingAsyncProvider {
        .init { id in
            let result = try await valueForID(id)
            try sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) async -> Void) -> ThrowingAsyncProvider {
        .init { id in
            let result = try await valueForID(id)
            await sideEffect(result, id)
            return result
        }
    }

    func sideEffect(
        _ sideEffect: @escaping (Value, ID) async throws -> Void
    ) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            let result = try await valueForID(id)
            try await sideEffect(result, id)
            return result
        }
    }
}
