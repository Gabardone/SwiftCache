//
//  ResourceDataProvider.swift
//  RemoteResourceCache
//
//  Created by Óscar Morales Vivó on 4/11/23.
//

import Foundation

/**
 Helper protocol for RemoteResourceCache

 The protocol abstracts away interactions with both the remote source for resources (remote data, usually the network)
 and a faster but still not necessarily fast enough for synchronous retrieval local storage (the local file system or
 local database would be common options).

 `RemoteResourceCache` instance should thus be testable without any dependencies external to the test bundle.

 The API is basically designed around `FileManager` and `URLSession` as the sources for local and remote data
 respectively so some of the details are such as to correspond to the framework ones.
 */
public protocol ResourceDataProvider {
    /**
     Type used to address the remote data. Usually `URL` but could be others.
     */
    associatedtype RemoteAddress: Hashable

    /**
     Fetches the remote data for the image.
     - Parameter remoteAddress: The remote URL for the image you want.
     - Returns: The image data fetched from remote persistence.
     */
    func remoteData(remoteAddress: RemoteAddress) async throws -> Data

    /**
     Type used to identify the cached local storage of the resource. Usually `String` for file system storage as a
     file name but could be something else for example if storage happens in a DB.
     */
    associatedtype LocalIdentifier: Hashable

    /**
     Fetches the local data for the image.

     The method will throw if there's no local data for the image or it can otherwise not be accessed.

     While the method is declared `async` it is expected that the implementation will be reasonably fast, especially as
     compared to `remoteData(remoteAddress:)`
     - Parameter localIdentifier: The identifier to use for local storage and local data retrieval. Must be unique and
     stable.
     - Returns: The image data fetched from local persistence.
     */
    func localData(localIdentifier: LocalIdentifier) async throws -> Data

    /**
     Stores the given data locally for the given `imageURL`

     Local storage isn't guaranteed to remain for any specific duration of time, but after calling this it should be
     there for a bit.

     While the method is declared `async` it is expected that the implementation will be reasonably fast, especially as
     compared to `remoteData(remoteAddress:)`
     - Parameter data: The image data.
     - Parameter localIdentifier: The identifier to use for local storage and local data retrieval. Must be unique and
     stable.
     */
    func storeLocally(data: Data, localIdentifier: LocalIdentifier) async throws
}
