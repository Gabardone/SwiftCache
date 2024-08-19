//
//  Cache.swift
//
//
//  Created by Óscar Morales Vivó on 4/21/23.
//

import Foundation

public protocol SyncCache<ID, Value> {
    /*
     The ID used to identify cached values. While different caches may treat a given ID differently, we still require
     that it adopts `Hashable` as to help guarantee that the same value ID will lead to the same value quickly and
     repeatably.
     */
    associatedtype ID: Hashable

    /**
     The type of values that the cache manages. Can be most anything.
     */
    associatedtype Value

    /**
     Returns the cached value for the given value ID in the calling cache.

     The method returns `nil` if the resource can not be found in the cache. It may `throw` if the operation of
     attempting to fetch the value fails in any other way. The errors thrown (if any) will depend on the cache type.
     - Parameter id: The cache ID for the resource.
     - Returns: The value, or `nil` if not present in the cache.
     */
    func cachedValueWith(id: ID) async throws -> Value
}

public protocol AsyncCache<ID, Value> {
    /*
     The ID used to identify cached values. While different caches may treat a given ID differently, we still require
     that it adopts `Hashable` as to help guarantee that the same value ID will lead to the same value quickly and
     repeatably.
     */
    associatedtype ID: Hashable

    /**
     The type of values that the cache manages. Can be most anything.
     */
    associatedtype Value

    /**
     Returns the cached value for the given value ID in the calling cache.

     The method returns `nil` if the resource can not be found in the cache. It may `throw` if the operation of
     attempting to fetch the value fails in any other way. The errors thrown (if any) will depend on the cache type.
     - Parameter id: The cache ID for the resource.
     - Returns: The value, or `nil` if not present in the cache.
     */
    func cachedValueWith(id: ID) async -> Value
}

public protocol ThrowingSyncCache<ID, Value> {
    /*
     The ID used to identify cached values. While different caches may treat a given ID differently, we still require
     that it adopts `Hashable` as to help guarantee that the same value ID will lead to the same value quickly and
     repeatably.
     */
    associatedtype ID: Hashable

    /**
     The type of values that the cache manages. Can be most anything.
     */
    associatedtype Value

    /**
     Returns the cached value for the given value ID in the calling cache.

     The method returns `nil` if the resource can not be found in the cache. It may `throw` if the operation of
     attempting to fetch the value fails in any other way. The errors thrown (if any) will depend on the cache type.
     - Parameter id: The cache ID for the resource.
     - Returns: The value, or `nil` if not present in the cache.
     */
    func cachedValueWith(id: ID) throws -> Value
}

public protocol ThrowingAsyncCache<ID, Value> {
    /*
     The ID used to identify cached values. While different caches may treat a given ID differently, we still require
     that it adopts `Hashable` as to help guarantee that the same value ID will lead to the same value quickly and
     repeatably.
     */
    associatedtype ID: Hashable

    /**
     The type of values that the cache manages. Can be most anything.
     */
    associatedtype Value

    /**
     Returns the cached value for the given value ID in the calling cache.

     The method returns `nil` if the resource can not be found in the cache. It may `throw` if the operation of
     attempting to fetch the value fails in any other way. The errors thrown (if any) will depend on the cache type.
     - Parameter id: The cache ID for the resource.
     - Returns: The value, or `nil` if not present in the cache.
     */
    func cachedValueWith(id: ID) async throws -> Value
}
