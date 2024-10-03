//
//  SyncResourceProvider.swift
//  SwiftCache
//
//  Created by Óscar Morales Vivó on 9/21/24.
//

/**
 A synchronous, non-failable cache.

 This type will return its values synchronously, and is expected to always obtain them successfully. Goot examples of
 use for this would be thumbnail generation for components that are either not run from the main thread or indirectly
 load outside it.

 The ID used to identify cached values is required to adopt `Hashable` as to help guarantee that the same value ID will
 lead to the same value quickly and repeatably.

 The type of values that the cache manages can be most anything.
 */
public struct SyncResourceProvider<ID: Hashable, Value> {
    /**
     Returns the cached value for the given value ID in the calling cache. A sync cache is expected to always succeed
     in producing a value, use `ThrowingSyncResourceProvider` if the operation may fail.
     - Parameter ID: The cache ID for the resource.
     - Returns: The value for the given `ID`
     */
    public var valueForID: (ID) -> Value
}

public extension ResourceProvider {
    static func source<ID: Hashable, Value>(_ source: @escaping (ID) -> Value) -> SyncResourceProvider<ID, Value> {
        SyncResourceProvider(valueForID: source)
    }
}
