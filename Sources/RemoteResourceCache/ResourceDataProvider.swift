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
     - Parameter imageURL: The remote URL for the image you want.
     - Returns: The image data fetched from remote persistence.
     */
    func remoteData(remoteURL: URL) async throws -> Data

    /**
     Fetches the local data for the image.

     The method will throw if there's no local data for the image or it can otherwise not be accessed.
     - Parameter imageURL: The _remote_ URL for the image you want. Local storage location is private but has to
     be stable for a given `imageURL` value.
     - Returns: The image data fetched from local persistence.
     */
    func localData(remoteURL: URL) throws -> Data

    /**
     Stores the given data locally for the given `imageURL`

     Local storage isn't guaranteed to remain for any specific duration of time, but after calling this it should be
     there for a bit.
     - Parameter data: The image data.
     - Parameter imageURL: The _remote_ URL for the image, which will be the key for uniquely identifying the data in
     local storage.
     */
    func storeLocally(data: Data, remoteURL: URL) throws
}
