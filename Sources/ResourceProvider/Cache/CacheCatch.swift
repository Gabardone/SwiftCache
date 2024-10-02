//
//  CacheCatch.swift
//  SwiftCache
//
//  Created by Óscar Morales Vivó on 9/23/24.
//

public extension ThrowingSyncCache {
    func `catch`(_ catcher: @escaping (Error, ID) -> Value) -> SyncCache<ID, Value> {
        SyncCache { id in
            do {
                return try valueForID(id)
            } catch {
                return catcher(error, id)
            }
        }
    }

    func `catch`(_ catcher: @escaping (Error, ID) throws -> Value) -> ThrowingSyncCache {
        .init { id in
            do {
                return try valueForID(id)
            } catch {
                return try catcher(error, id)
            }
        }
    }

    func `catch`(_ catcher: @escaping (Error, ID) async -> Value) -> AsyncCache<ID, Value> {
        .init { id in
            do {
                return try valueForID(id)
            } catch {
                return await catcher(error, id)
            }
        }
    }

    func `catch`(_ catcher: @escaping (Error, ID) async throws -> Value) -> ThrowingAsyncCache<ID, Value> {
        .init { id in
            do {
                return try valueForID(id)
            } catch {
                return try await catcher(error, id)
            }
        }
    }
}

public extension ThrowingAsyncCache {
    func `catch`(_ catcher: @escaping (Error, ID) -> Value) -> AsyncCache<ID, Value> {
        .init { id in
            do {
                return try await valueForID(id)
            } catch {
                return catcher(error, id)
            }
        }
    }

    func `catch`(_ catcher: @escaping (Error, ID) throws -> Value) -> ThrowingAsyncCache {
        .init { id in
            do {
                return try await valueForID(id)
            } catch {
                return try catcher(error, id)
            }
        }
    }

    func `catch`(_ catcher: @escaping (Error, ID) async -> Value) -> AsyncCache<ID, Value> {
        .init { id in
            do {
                return try await valueForID(id)
            } catch {
                return await catcher(error, id)
            }
        }
    }

    func `catch`(_ catcher: @escaping (Error, ID) async throws -> Value) -> ThrowingAsyncCache {
        .init { id in
            do {
                return try await valueForID(id)
            } catch {
                return try await catcher(error, id)
            }
        }
    }
}
