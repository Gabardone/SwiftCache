//
//  ResourceDataProvider.swift
//  RemoteResourceCache
//
//  Created by Óscar Morales Vivó on 4/11/23.
//

import Foundation

/**
 Helper protocol for RemoteResourceCache

 The protocol abstracts away interactions with both the remote source (remote data, usually the network) and the local
 file system (local data) so a `RemoteResourceCache` instance can be tested without hitting either or alternate caching
 storage approaches can be tried out.

 The API is basically covering over both `FileManager` and `URLSession` so some of the details are such as to correspond
 to the framework ones.
 */
public protocol ResourceDataProvider {
    /**
     Fetches the remote data for the image.
     - Parameter remoteAddress: The remote URL for the image you want.
     - Returns: The image data fetched from remote persistence.
     */
    func remoteData(remoteAddress: URL) async throws -> Data

    /**
     Fetches the local data for the image.

     The method will throw if there's no local data for the image or it can otherwise not be accessed.
     - Parameter localIdentifier: The identifier to use for local storage and local data retrieval. Must be unique and
     stable.
     - Returns: The image data fetched from local persistence.
     */
    func localData(localIdentifier: String) throws -> Data

    /**
     Stores the given data locally for the given `imageURL`

     Local storage isn't guaranteed to remain for any specific duration of time, but after calling this it should be
     there for a bit.
     - Parameter data: The image data.
     - Parameter localIdentifier: The identifier to use for local storage and local data retrieval. Must be unique and
     stable.
     */
    func storeLocally(data: Data, localIdentifier: String) throws
}
