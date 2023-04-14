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
 memory caching, remote resource retrival, and local storage. The API naming conventions and types presume that remote
 resources can be uniquely reached through a URL and local storage through a combination of an —optional— local
 directory and local file name, but it's possible to coordinate with a custom `ResourceDataProvider` implementation to
 map those values into other sources of data like, for example, a DB.
 - Todo: Consider allowing for generic remote and local types in coordination with `ResourceDataProvider` if Swift's
 treatment of exitentials ever gets to the point where that wouldn't be a gigantic headache.
 */
protocol RemoteResourceIdentifier: Hashable {
    /**
     The address of the remote resource.

     Just because it's a URL doesn't mean it has to be a network resource, but in any case the meaning of the URL will
     need to be coordinated with the cache's resource data provider.
     */
    var remoteAddress: URL { get }

    /**
     A string that determines a grouping for the local storage of a resource.

     Advanced caches may store related resources (i.e. different sized versions of the same image). Returning a
     non-`nil` value from this property will let the cache easily group those related versions for a more efficient
     retrieval later.
     */
    var localGrouping: String? { get }

    /**
     The name to use for the locally stored copy of the resource. Must be unique within its grouping (including the
     `nil` group) and must be stable.
     */
    var localName: String { get }
}

extension RemoteResourceIdentifier {
    /**
     The default implementation of `localGrouping` returns nil, which causes all locally persisted copies of the cached
     data to be grouped together.
     */
    var localGrouping: String? {
        nil
    }
}
