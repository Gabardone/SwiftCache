//
//  ThrowingAsyncCache.swift
//  SwiftCache
//
//  Created by Óscar Morales Vivó on 9/21/24.
//

public struct ThrowingAsyncCache<ID: Hashable, Value> {
    /**
     Returns the cached value for the given value ID in the calling cache.

     The function may `throw` if the attempting to fetch the value fails in any way. The errors thrown (if any) will
     depend on the logic being injected in.
     - Parameter id: The cache ID for the resource.
     - Returns: The value for the given `ID`
     */
    public var valueForID: (ID) async throws -> Value
}

public extension Cache {
    static func source<ID: Hashable, Value>(
        _ source: @escaping (ID) async throws -> Value
    ) -> ThrowingAsyncCache<ID, Value> {
        .init(valueForID: source)
    }
}
