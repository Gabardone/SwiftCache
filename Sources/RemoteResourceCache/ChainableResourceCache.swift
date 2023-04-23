//
//  ChainableResourceCache.swift
//  
//
//  Created by Óscar Morales Vivó on 4/21/23.
//

import Foundation

public protocol ChainableResourceCache: ResourceCache {
    /**
     The next cache in the chain must use the same kind of resource ID, although it may interpret it differently.
     */
    associatedtype Next: ResourceCache where Next.ResourceID == ResourceID

    /**
     The next cache in the chain. May be `nil` which means this is the last cache in the chain.
     */
    var next: Next? { get }

    /**
     Translates a resource returned from `next` into one of the type that `self` manages. May throw if conversion is
     not possible.
     - Parameter nextResource: The resource returned from `next`.
     - Returns: An equivalent resource of the type managed by the caller.
     */
    func processFromNext(nextResource: Next.Resource) async throws -> Resource

    /**
     Stores a resource returned from `next` into this cache's storage.

     After this, a call to `cachedResourceWith(resourceID:)` should return `resource` unless the cache was cleared
     inbetween.

     If storage is not possible for whatever reason the method will `throw` and no storage will happen.
     - Parameter resource: The resource to store.
     - Parameter resourceID: The ID of the resource
     */
    func store(resource: Resource, resourceID: ResourceID) async throws
}

public extension ChainableResourceCache where Resource == Next.Resource {
    /**
     If the next cache's resource type and ours are the same, this default implementation will just pass it along.

     Can be overwritten if needed in implementations although it's unclear of why anyone would do so.
     */
    func processFromNext(cached: Next.Resource) throws -> Resource {
        return cached
    }
}
