//
//  Cache.swift
//
//
//  Created by Óscar Morales Vivó on 4/21/23.
//

import Foundation
import os

/**
 Module-wide logger object.
 */
extension Logger {
    static let cache = Logger(subsystem: "CacheLogging", category: "SwiftCache")
}

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

     The method returns `nil` if the resource can not be found in the cache. It may `throw` if the operation of
     attempting to fetch the value fails in any other way. The errors thrown (if any) will depend on the cache type.
     - Parameter identifier: The cache ID for the resource.
     - Returns: The value, or `nil` if not present in the cache.
     */
    func cachedValueWith(identifier: CacheID) async throws -> Cached?

    /**
     Invalidates (removes) the cached value (if any) for the given identifer.

     While most usage of `Cache` is meant to be for stable caches (same ID always corresponds to same value) there are
     a few circumstances where invalidating a cached value may be recommended:
     1. When it is positively known that a value will no longer be needed and we want to free any resources it may be
     using.
     2. If there is some corruption or error of the value and we want to retry re-fetching (or re-generating) it again.

     There's no universally valid way for a cache to deal with either case so the method is declared on the API for use
     when there's no other good way around the need for manual invalidation.

     For caches that generate or get their values from readonly sources the caller should `await` the result of the
     method for a value before trying to get it again.

     Generating or readonly caches can and will do nothing when this method is called.
     - Parameter identifier: Identifier for the cache entry we want invalidated.
     */
    func invalidateCachedValueFor(identifier: CacheID) async throws
}
