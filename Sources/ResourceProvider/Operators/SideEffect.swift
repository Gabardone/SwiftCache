//
//  SideEffect.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 9/23/24.
//

public extension SyncResourceProvider {
    func sideEffect(_ sideEffect: @escaping (Value, ID) -> Void) -> SyncResourceProvider {
        .init { id in
            let result = valueForID(id)
            sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) throws -> Void) -> ThrowingSyncResourceProvider<ID, Value> {
        .init { id in
            let result = valueForID(id)
            try sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) async -> Void) -> AsyncResourceProvider<ID, Value> {
        .init { id in
            let result = valueForID(id)
            await sideEffect(result, id)
            return result
        }
    }

    func sideEffect(
        _ sideEffect: @escaping (Value, ID) async throws -> Void
    ) -> ThrowingAsyncResourceProvider<ID, Value> {
        .init { id in
            let result = valueForID(id)
            try await sideEffect(result, id)
            return result
        }
    }
}

public extension ThrowingSyncResourceProvider {
    func sideEffect(_ sideEffect: @escaping (Value, ID) -> Void) -> ThrowingSyncResourceProvider {
        .init { id in
            let result = try valueForID(id)
            sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) throws -> Void) -> ThrowingSyncResourceProvider {
        .init { id in
            let result = try valueForID(id)
            try sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) async -> Void) -> ThrowingAsyncResourceProvider<ID, Value> {
        .init { id in
            let result = try valueForID(id)
            await sideEffect(result, id)
            return result
        }
    }

    func sideEffect(
        _ sideEffect: @escaping (Value, ID) async throws -> Void
    ) -> ThrowingAsyncResourceProvider<ID, Value> {
        .init { id in
            let result = try valueForID(id)
            try await sideEffect(result, id)
            return result
        }
    }
}

public extension AsyncResourceProvider {
    func sideEffect(_ sideEffect: @escaping (Value, ID) -> Void) -> AsyncResourceProvider {
        .init { id in
            let result = await valueForID(id)
            sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) throws -> Void) -> ThrowingAsyncResourceProvider<ID, Value> {
        .init { id in
            let result = await valueForID(id)
            try sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) async -> Void) -> AsyncResourceProvider {
        .init { id in
            let result = await valueForID(id)
            await sideEffect(result, id)
            return result
        }
    }

    func sideEffect(
        _ sideEffect: @escaping (Value, ID) async throws -> Void
    ) -> ThrowingAsyncResourceProvider<ID, Value> {
        .init { id in
            let result = await valueForID(id)
            try await sideEffect(result, id)
            return result
        }
    }
}

public extension ThrowingAsyncResourceProvider {
    func sideEffect(_ sideEffect: @escaping (Value, ID) -> Void) -> ThrowingAsyncResourceProvider {
        .init { id in
            let result = try await valueForID(id)
            sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) throws -> Void) -> ThrowingAsyncResourceProvider {
        .init { id in
            let result = try await valueForID(id)
            try sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) async -> Void) -> ThrowingAsyncResourceProvider {
        .init { id in
            let result = try await valueForID(id)
            await sideEffect(result, id)
            return result
        }
    }

    func sideEffect(
        _ sideEffect: @escaping (Value, ID) async throws -> Void
    ) -> ThrowingAsyncResourceProvider<ID, Value> {
        .init { id in
            let result = try await valueForID(id)
            try await sideEffect(result, id)
            return result
        }
    }
}
