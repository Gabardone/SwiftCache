//
//  File.swift
//
//
//  Created by Óscar Morales Vivó on 4/13/23.
//

import Foundation

/**
 A protocol for resource identifiers for remote resource caches.

 Implementations need to be hashable and uniquely identify a specific resource so they can use for chache mapping.

 A given `RemoteResourceCache` will use a specific implementation of the protocol as its `Identifier` type to map in
 memory caching, remote resource retrival, and local storage. All of the differing identifiers need to be unique for
 the cache they are contained in.
 - Todo: Consider allowing for generic remote and local types in coordination with `ResourceDataProvider` if Swift's
 treatment of exitentials ever gets to the point where that wouldn't be a gigantic headache.
 */
public protocol ResourceIdentifier: Hashable, Identifiable {
    associatedtype RemoteAddress: Hashable

    /**
     The address of the remote resource.

     Just because it's a URL doesn't mean it has to be a network resource, but in any case the meaning of the URL will
     need to be coordinated with the cache's resource data provider.
     */
    var remoteAddress: RemoteAddress { get }

    associatedtype LocalIdentifier: Hashable

    /**
     The identifier to use for the locally stored copy of the resource. Must be unique within its cache and stable.
     Must be compatible with the requirements of the resource data provider local storage.
     */
    var localIdentifier: LocalIdentifier { get }
}
