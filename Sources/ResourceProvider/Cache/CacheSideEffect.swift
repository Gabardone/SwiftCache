//
//  CacheSideEffect.swift
//  SwiftCache
//
//  Created by Óscar Morales Vivó on 9/23/24.
//

public extension SyncCache {
    func sideEffect(_ sideEffect: @escaping (Value, ID) -> Void) -> SyncCache {
        .init { id in
            let result = valueForID(id)
            sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) throws -> Void) -> ThrowingSyncCache<ID, Value> {
        .init { id in
            let result = valueForID(id)
            try sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) async -> Void) -> AsyncCache<ID, Value> {
        .init { id in
            let result = valueForID(id)
            await sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) async throws -> Void) -> ThrowingAsyncCache<ID, Value> {
        .init { id in
            let result = valueForID(id)
            try await sideEffect(result, id)
            return result
        }
    }
}

public extension ThrowingSyncCache {
    func sideEffect(_ sideEffect: @escaping (Value, ID) -> Void) -> ThrowingSyncCache {
        .init { id in
            let result = try valueForID(id)
            sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) throws -> Void) -> ThrowingSyncCache {
        .init { id in
            let result = try valueForID(id)
            try sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) async -> Void) -> ThrowingAsyncCache<ID, Value> {
        .init { id in
            let result = try valueForID(id)
            await sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) async throws -> Void) -> ThrowingAsyncCache<ID, Value> {
        .init { id in
            let result = try valueForID(id)
            try await sideEffect(result, id)
            return result
        }
    }
}

public extension AsyncCache {
    func sideEffect(_ sideEffect: @escaping (Value, ID) -> Void) -> AsyncCache {
        .init { id in
            let result = await valueForID(id)
            sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) throws -> Void) -> ThrowingAsyncCache<ID, Value> {
        .init { id in
            let result = await valueForID(id)
            try sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) async -> Void) -> AsyncCache {
        .init { id in
            let result = await valueForID(id)
            await sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) async throws -> Void) -> ThrowingAsyncCache<ID, Value> {
        .init { id in
            let result = await valueForID(id)
            try await sideEffect(result, id)
            return result
        }
    }
}

public extension ThrowingAsyncCache {
    func sideEffect(_ sideEffect: @escaping (Value, ID) -> Void) -> ThrowingAsyncCache {
        .init { id in
            let result = try await valueForID(id)
            sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) throws -> Void) -> ThrowingAsyncCache {
        .init { id in
            let result = try await valueForID(id)
            try sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) async -> Void) -> ThrowingAsyncCache {
        .init { id in
            let result = try await valueForID(id)
            await sideEffect(result, id)
            return result
        }
    }

    func sideEffect(_ sideEffect: @escaping (Value, ID) async throws -> Void) -> ThrowingAsyncCache<ID, Value> {
        .init { id in
            let result = try await valueForID(id)
            try await sideEffect(result, id)
            return result
        }
    }
}
