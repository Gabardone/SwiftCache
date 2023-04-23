//
//  DataProvider.swift
//  
//
//  Created by Óscar Morales Vivó on 4/22/23.
//

import Foundation

/**
 A protocol for asynchronous, failable access to data by an identifier.

 Caches that either store or manage raw data should use a façaded `DataProvider` to perform those operations as to allow
 for testability and overall abstract away hard dependencies on storage APIs (DBs, network, file system…).
 */
public protocol DataProvider<DataIdentifier> {
    /**
     Type used to identify the cached local storage of the resource. Usually `String` for file system storage as a
     file name but could be something else for example if storage happens in a DB.
     */
    associatedtype DataIdentifier: Hashable

    /**
     Fetches the local data for the image.

     The method will throw if there's no local data for the image or it can otherwise not be accessed.

     While the method is declared `async` it is expected that the implementation will be reasonably fast, especially as
     compared to `remoteData(remoteAddress:)`
     - Parameter localIdentifier: The identifier to use for local storage and local data retrieval. Must be unique and
     stable.
     - Returns: The image data fetched from local persistence.
     */
    func dataFor(dataIdentifier: DataIdentifier) async throws -> Data
}
