//
//  Interject.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 9/23/24.
//

public extension SyncResourceProvider {
    func interject(_ interject: @escaping (ID) -> Value?) -> SyncResourceProvider {
        .init { id in
            interject(id) ?? valueForID(id)
        }
    }

    func interject(_ interject: @escaping (ID) throws -> Value?) -> ThrowingSyncResourceProvider<ID, Value> {
        .init { id in
            try interject(id) ?? valueForID(id)
        }
    }

    func interject(_ interject: @escaping (ID) async -> Value?) -> AsyncResourceProvider<ID, Value> {
        .init { id in
            await interject(id) ?? valueForID(id)
        }
    }

    func interject(_ interject: @escaping (ID) async throws -> Value?) -> ThrowingAsyncResourceProvider<ID, Value> {
        .init { id in
            try await interject(id) ?? valueForID(id)
        }
    }
}

public extension ThrowingSyncResourceProvider {
    func interject(_ interject: @escaping (ID) -> Value?) -> ThrowingSyncResourceProvider {
        .init { id in
            try interject(id) ?? valueForID(id)
        }
    }

    func interject(_ interject: @escaping (ID) throws -> Value?) -> ThrowingSyncResourceProvider {
        .init { id in
            try interject(id) ?? valueForID(id)
        }
    }

    func interject(_ interject: @escaping (ID) async -> Value?) -> ThrowingAsyncResourceProvider<ID, Value> {
        .init { id in
            try await interject(id) ?? valueForID(id)
        }
    }

    func interject(_ interject: @escaping (ID) async throws -> Value?) -> ThrowingAsyncResourceProvider<ID, Value> {
        .init { id in
            try await interject(id) ?? valueForID(id)
        }
    }
}

public extension AsyncResourceProvider {
    func interject(_ interject: @escaping (ID) -> Value?) -> AsyncResourceProvider {
        .init { id in
            if let result = interject(id) {
                result
            } else {
                await valueForID(id)
            }
        }
    }

    func interject(_ interject: @escaping (ID) throws -> Value?) -> ThrowingAsyncResourceProvider<ID, Value> {
        .init { id in
            if let result = try interject(id) {
                result
            } else {
                await valueForID(id)
            }
        }
    }

    func interject(_ interject: @escaping (ID) async -> Value?) -> AsyncResourceProvider {
        .init { id in
            if let result = await interject(id) {
                result
            } else {
                await valueForID(id)
            }
        }
    }

    func interject(_ interject: @escaping (ID) async throws -> Value?) -> ThrowingAsyncResourceProvider<ID, Value> {
        .init { id in
            if let result = try await interject(id) {
                result
            } else {
                await valueForID(id)
            }
        }
    }
}

public extension ThrowingAsyncResourceProvider {
    func interject(_ interject: @escaping (ID) -> Value?) -> ThrowingAsyncResourceProvider {
        .init { id in
            if let result = interject(id) {
                result
            } else {
                try await valueForID(id)
            }
        }
    }

    func interject(_ interject: @escaping (ID) throws -> Value?) -> ThrowingAsyncResourceProvider {
        .init { id in
            if let result = try interject(id) {
                result
            } else {
                try await valueForID(id)
            }
        }
    }

    func interject(_ interject: @escaping (ID) async -> Value?) -> ThrowingAsyncResourceProvider {
        .init { id in
            if let result = await interject(id) {
                result
            } else {
                try await valueForID(id)
            }
        }
    }

    func interject(_ interject: @escaping (ID) async throws -> Value?) -> ThrowingAsyncResourceProvider<ID, Value> {
        .init { id in
            if let result = try await interject(id) {
                result
            } else {
                try await valueForID(id)
            }
        }
    }
}
