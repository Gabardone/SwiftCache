//
//  CacheInterject.swift
//  SwiftCache
//
//  Created by Óscar Morales Vivó on 9/23/24.
//

public extension SyncCache {
    func interject(_ interject: @escaping (ID) -> Value?) -> SyncCache {
        .init { id in
            interject(id) ?? valueForID(id)
        }
    }

    func interject(_ interject: @escaping (ID) throws -> Value?) -> ThrowingSyncCache<ID, Value> {
        .init { id in
            try interject(id) ?? valueForID(id)
        }
    }

    func interject(_ interject: @escaping (ID) async -> Value?) -> AsyncCache<ID, Value> {
        .init { id in
            await interject(id) ?? valueForID(id)
        }
    }

    func interject(_ interject: @escaping (ID) async throws -> Value?) -> ThrowingAsyncCache<ID, Value> {
        .init { id in
            try await interject(id) ?? valueForID(id)
        }
    }
}

public extension ThrowingSyncCache {
    func interject(_ interject: @escaping (ID) -> Value?) -> ThrowingSyncCache {
        .init { id in
            try interject(id) ?? valueForID(id)
        }
    }

    func interject(_ interject: @escaping (ID) throws -> Value?) -> ThrowingSyncCache {
        .init { id in
            try interject(id) ?? valueForID(id)
        }
    }

    func interject(_ interject: @escaping (ID) async -> Value?) -> ThrowingAsyncCache<ID, Value> {
        .init { id in
            try await interject(id) ?? valueForID(id)
        }
    }

    func interject(_ interject: @escaping (ID) async throws -> Value?) -> ThrowingAsyncCache<ID, Value> {
        .init { id in
            try await interject(id) ?? valueForID(id)
        }
    }
}

public extension AsyncCache {
    func interject(_ interject: @escaping (ID) -> Value?) -> AsyncCache {
        .init { id in
            if let result = interject(id) {
                result
            } else {
                await valueForID(id)
            }
        }
    }

    func interject(_ interject: @escaping (ID) throws -> Value?) -> ThrowingAsyncCache<ID, Value> {
        .init { id in
            if let result = try interject(id) {
                result
            } else {
                await valueForID(id)
            }
        }
    }

    func interject(_ interject: @escaping (ID) async -> Value?) -> AsyncCache {
        .init { id in
            if let result = await interject(id) {
                result
            } else {
                await valueForID(id)
            }
        }
    }

    func interject(_ interject: @escaping (ID) async throws -> Value?) -> ThrowingAsyncCache<ID, Value> {
        .init { id in
            if let result = try await interject(id) {
                result
            } else {
                await valueForID(id)
            }
        }
    }
}

public extension ThrowingAsyncCache {
    func interject(_ interject: @escaping (ID) -> Value?) -> ThrowingAsyncCache {
        .init { id in
            if let result = interject(id) {
                result
            } else {
                try await valueForID(id)
            }
        }
    }

    func interject(_ interject: @escaping (ID) throws -> Value?) -> ThrowingAsyncCache {
        .init { id in
            if let result = try interject(id) {
                result
            } else {
                try await valueForID(id)
            }
        }
    }

    func interject(_ interject: @escaping (ID) async -> Value?) -> ThrowingAsyncCache {
        .init { id in
            if let result = await interject(id) {
                result
            } else {
                try await valueForID(id)
            }
        }
    }

    func interject(_ interject: @escaping (ID) async throws -> Value?) -> ThrowingAsyncCache<ID, Value> {
        .init { id in
            if let result = try await interject(id) {
                result
            } else {
                try await valueForID(id)
            }
        }
    }
}
