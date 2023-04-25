//
//  Cache.swift
//
//
//  Created by Óscar Morales Vivó on 4/21/23.
//

import Foundation

/**
 An interface to an asynchronous cache of identifiable resources.

 A cache is defined by the kinds of `Cached` values it stores and the `CacheID` used to access them.

 Values are meant to be static for the identifier, such that the same identifier will always return the exact same value
 if it remained cached.
 */
public protocol Cache<Cached, CacheID>: Actor {
    /**
     The type of values that the cache manages. Can be most anything.
     */
    associatedtype Cached

    /*
     The ID used to identify cached values. While different caches may treat a given ID differently, we still require
     that it adopts `Hashable` as to help guarantee that the same value ID will lead to the same value quickly and
     repeatably.
     */
    associatedtype CacheID: Hashable

    /**
     Returns the cached value for the given value ID in the calling cache.

     The method returns `nil` if the resource can not be found in the calling cache. It may `throw` if the operation of
     attempting to fetch the value fails in any other way. The errors thrown (if any) will depend on the cache type.

     You normally don't want to call this method from outside the cache, using instead the `fetch` methods that will
     dig in chained caches if needed.
     - Parameter identifier: The cache ID for the resource.
     - Returns: The value, or `nil` if not present in the cache.
     */
    func cachedValueWith(identifier: CacheID) async throws -> Cached?
}
