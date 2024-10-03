//
//  ThrowingSyncResourceProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 9/21/24.
//

/**
 A synchronous, potentially failing cache.

 This type will return its values synchronously, and may fail to do so in which case it will `throw` an error.

 The ID used to identify cached values is required to adopt `Hashable` as to help guarantee that the same value ID will
 lead to the same value quickly and repeatably.

 The type of values that the cache manages can be most anything.
 */
public struct ThrowingSyncResourceProvider<ID: Hashable, Value> {
    /**
     Returns the cached value for the given value ID in the calling cache.

     The function may `throw` if the attempting to fetch the value fails in any way. The errors thrown (if any) will
     depend on the logic being injected in.
     - Parameter id: The cache ID for the resource.
     - Returns: The value for the given `ID`
     */
    public var valueForID: (ID) throws -> Value
}

public extension ResourceProvider {
    static func source<ID: Hashable, Value>(
        _ source: @escaping (ID) throws -> Value
    ) -> ThrowingSyncResourceProvider<ID, Value> {
        ThrowingSyncResourceProvider(valueForID: source)
    }
}
