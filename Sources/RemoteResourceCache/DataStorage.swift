//
//  File.swift
//  
//
//  Created by Óscar Morales Vivó on 4/23/23.
//

import Foundation

/**
 A protocol for asynchronous, failable storage of data by identifier.

 This is the mutable extension of `DataStorage` to be used on `ChainableCache` adoptions to store the results of its
 `next` cache fetch.
 */
protocol DataStorage<DataIdentifier>: DataProvider {
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
    func store(data: Data, dataIdentifier: DataIdentifier) async throws
}
