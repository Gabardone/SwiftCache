//
//  Catch.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 9/23/24.
//

public extension ThrowingSyncProvider {
    func `catch`(_ catcher: @escaping (Error, ID) -> Value) -> SyncProvider<ID, Value> {
        SyncProvider { id in
            do {
                return try valueForID(id)
            } catch {
                return catcher(error, id)
            }
        }
    }

    func `catch`(_ catcher: @escaping (Error, ID) throws -> Value) -> ThrowingSyncProvider {
        .init { id in
            do {
                return try valueForID(id)
            } catch {
                return try catcher(error, id)
            }
        }
    }

    func `catch`(_ catcher: @escaping (Error, ID) async -> Value) -> AsyncProvider<ID, Value> {
        .init { id in
            do {
                return try valueForID(id)
            } catch {
                return await catcher(error, id)
            }
        }
    }

    func `catch`(_ catcher: @escaping (Error, ID) async throws -> Value) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            do {
                return try valueForID(id)
            } catch {
                return try await catcher(error, id)
            }
        }
    }
}

public extension ThrowingAsyncProvider {
    func `catch`(_ catcher: @escaping (Error, ID) -> Value) -> AsyncProvider<ID, Value> {
        .init { id in
            do {
                return try await valueForID(id)
            } catch {
                return catcher(error, id)
            }
        }
    }

    func `catch`(_ catcher: @escaping (Error, ID) throws -> Value) -> ThrowingAsyncProvider {
        .init { id in
            do {
                return try await valueForID(id)
            } catch {
                return try catcher(error, id)
            }
        }
    }

    func `catch`(_ catcher: @escaping (Error, ID) async -> Value) -> AsyncProvider<ID, Value> {
        .init { id in
            do {
                return try await valueForID(id)
            } catch {
                return await catcher(error, id)
            }
        }
    }

    func `catch`(_ catcher: @escaping (Error, ID) async throws -> Value) -> ThrowingAsyncProvider {
        .init { id in
            do {
                return try await valueForID(id)
            } catch {
                return try await catcher(error, id)
            }
        }
    }
}
