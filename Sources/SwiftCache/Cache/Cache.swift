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

/**
 An error thrown when a cached value that should be available is not.

 APIs that expect cached values to be found (i.e. your typical cache chain backstopped by a network backend) will
 `throw` this error instead of returning `nil` when a value is requested that cannot be found. The error packs in the
 cache ID.
 */
public struct CachedValueNotFound<ResourceID>: Error {
    var cacheID: ResourceID

    var localizedDescription: String {
        "Cached value for ID \(String(describing: cacheID)) could not be found."
    }
}

public extension Cache {
    /**
     Attempts to fetch a resource from a cache, presuming it should be there.

     This is the method you will normally use when attempting to fetch a resource from a cache that is expected to
     contain it. The implementation for `Cache` will just `throw` if the resource is not found. A chainable
     cache will instead attempt to fetch the resource from the next cache in the chain.
     */
    func fetchResourceWith(identifier: CacheID) async throws -> Cached {
        if let cached = try await cachedValueWith(identifier: identifier) {
            return cached
        } else {
            throw CachedValueNotFound(cacheID: identifier)
        }
    }
}
