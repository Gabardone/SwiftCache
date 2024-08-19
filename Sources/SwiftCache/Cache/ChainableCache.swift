//
//  ChainableCache.swift
//
//
//  Created by Óscar Morales Vivó on 4/21/23.
//

import Foundation

/**
 A protocol extension of `Cache` to allow for building chains of caches.

 More sophisticated caching will have multiple levels. For example if we're caching images for display that are stored
 in a network backend we'd want to first look in memory, then in temporary storage inside the app's sandbox, and finally
 on the network itself. Each operation is more costly than the prior one but also uses less valuable resources (RAM,
 device storage and network storage in the example given).

 An implementation of `ChainableCache` has to make sure that `next?.cachedValueWith(identifier:)` is called if the
 requested value is not found in the calling cache's storage itself.
 */
public protocol ChainableCache: Cache {
    /**
     The next cache in the chain must use the same kind of cache ID, although it may interpret it differently.
     */
    associatedtype Next: Cache where Next.ID == ID

    /**
     The next cache in the chain. May be `nil` which means this is the last cache in the chain.
     */
    var next: Next? { get }

    /**
     Translates a cached value returned from `next` into one of the type that `self` manages. May throw if conversion is
     not possible.
     - Parameter nextValue: The value returned from `next`.
     - Returns: An equivalent value of the type managed by the caller.
     */
    func processFromNext(nextValue: Next.Value) async throws -> Value

    /**
     Stores a value returned from `next` into this cache's storage.

     After this, a call to ``cachedValueWith(identifier:)`` should return `value` unless the cache was cleared
     inbetween.

     If storage is not possible for whatever reason the method will `throw` and no storage will happen.
     - Parameter value: The value to store in the cache.
     - Parameter identifier: The identifier to use to store the value.
     */
    func store(value: Value, identifier: ID) async throws
}

public extension ChainableCache where Value == Next.Value {
    /**
     If the next cache's `Cached` type and ours are the same, this default implementation will just pass it along.

     Can still be overwritten if needed in implementations although it's not something that should happen often.
     */
    func processFromNext(cached: Next.Value) throws -> Value {
        cached
    }
}
