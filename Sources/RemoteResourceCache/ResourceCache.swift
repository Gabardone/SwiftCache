//
//  ResourceCache.swift
//  
//
//  Created by Óscar Morales Vivó on 4/21/23.
//

import Foundation

/**
 An interface to a cache of identifiable resources.

 A resource cache will asynchronously return a cached resource if possible. If the resource is not available it will
 return `nil`.

 The resources are meant to be static for the identifier, such that the same identifier will always return the exact
 same resource (if possible).
 */
public protocol ResourceCache: Actor {
    /**
     The resource type that the cache manages. Can be most anything.
     */
    associatedtype Resource

    /*
     The ID used to identify a resource. While different caches may treat a given resource ID differently, we still
     require that it adopts `Hashable` as to help guarantee that the same resource ID will lead to the same value
     quickly and repeatably.
     */
    associatedtype ResourceID: Hashable

    /**
     Returns the cached resource for the given cache ID.

     The method returns `nil` if the resource is not in the cache. It may `throw` if the operation of attempting to
     fetch the resource fails in any way. The errors thrown (if any) will depend on the cache type.
     - Parameter identifier: The cache ID for the resource.
     - Returns: The resource, or `nil` if not present in the cache.
     */
    func cachedResourceWith(resourceID: ResourceID) async throws -> Resource?
}

/**
 An error thrown when a resource that should be available is not.

 If your cache chain is supposed to find any resource you request of it, yet it cannot find a specific one by
 `resourceID`, this error will be thrown.
 */
public struct CachedResourceNotFound<ResourceID>: Error {
    var resourceID: ResourceID

    var localizedDescription: String {
        return "Resource with ID \(String(describing: resourceID)) could not be found."
    }
}

public extension ResourceCache {
    /**
     Attempts to fetch a resource from a cache, presuming it should be there.

     This is the method you will normally use when attempting to fetch a resource from a cache that is expected to
     contain it. The implementation for `ResourceCache` will just `throw` if the resource is not found. A chainable
     cache will instead attempt to fetch the resource from the next cache in the chain.
     */
    func fetchResourceWith(resourceID: ResourceID) async throws -> Resource {
        if let cached = try await cachedResourceWith(resourceID: resourceID) {
            return cached
        } else {
            throw CachedResourceNotFound(resourceID: resourceID)
        }
    }
}
