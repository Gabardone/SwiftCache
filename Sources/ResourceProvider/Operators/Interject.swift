//
//  Interject.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 9/23/24.
//

public extension SyncProvider {
    func interject(_ interject: @escaping (ID) -> Value?) -> SyncProvider {
        .init { id in
            interject(id) ?? valueForID(id)
        }
    }

    func interject(_ interject: @escaping (ID) throws -> Value?) -> ThrowingSyncProvider<ID, Value> {
        .init { id in
            try interject(id) ?? valueForID(id)
        }
    }

    func interject(_ interject: @escaping (ID) async -> Value?) -> AsyncProvider<ID, Value> {
        .init { id in
            await interject(id) ?? valueForID(id)
        }
    }

    func interject(_ interject: @escaping (ID) async throws -> Value?) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            try await interject(id) ?? valueForID(id)
        }
    }
}

public extension ThrowingSyncProvider {
    func interject(_ interject: @escaping (ID) -> Value?) -> ThrowingSyncProvider {
        .init { id in
            try interject(id) ?? valueForID(id)
        }
    }

    func interject(_ interject: @escaping (ID) throws -> Value?) -> ThrowingSyncProvider {
        .init { id in
            try interject(id) ?? valueForID(id)
        }
    }

    func interject(_ interject: @escaping (ID) async -> Value?) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            try await interject(id) ?? valueForID(id)
        }
    }

    func interject(_ interject: @escaping (ID) async throws -> Value?) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            try await interject(id) ?? valueForID(id)
        }
    }
}

public extension AsyncProvider {
    func interject(_ interject: @escaping (ID) -> Value?) -> AsyncProvider {
        .init { id in
            if let result = interject(id) {
                result
            } else {
                await valueForID(id)
            }
        }
    }

    func interject(_ interject: @escaping (ID) throws -> Value?) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            if let result = try interject(id) {
                result
            } else {
                await valueForID(id)
            }
        }
    }

    func interject(_ interject: @escaping (ID) async -> Value?) -> AsyncProvider {
        .init { id in
            if let result = await interject(id) {
                result
            } else {
                await valueForID(id)
            }
        }
    }

    func interject(_ interject: @escaping (ID) async throws -> Value?) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            if let result = try await interject(id) {
                result
            } else {
                await valueForID(id)
            }
        }
    }
}

public extension ThrowingAsyncProvider {
    func interject(_ interject: @escaping (ID) -> Value?) -> ThrowingAsyncProvider {
        .init { id in
            if let result = interject(id) {
                result
            } else {
                try await valueForID(id)
            }
        }
    }

    func interject(_ interject: @escaping (ID) throws -> Value?) -> ThrowingAsyncProvider {
        .init { id in
            if let result = try interject(id) {
                result
            } else {
                try await valueForID(id)
            }
        }
    }

    func interject(_ interject: @escaping (ID) async -> Value?) -> ThrowingAsyncProvider {
        .init { id in
            if let result = await interject(id) {
                result
            } else {
                try await valueForID(id)
            }
        }
    }

    func interject(_ interject: @escaping (ID) async throws -> Value?) -> ThrowingAsyncProvider<ID, Value> {
        .init { id in
            if let result = try await interject(id) {
                result
            } else {
                try await valueForID(id)
            }
        }
    }
}
