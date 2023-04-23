//
//  TemporaryStorageResourceCache.swift
//  
//
//  Created by Óscar Morales Vivó on 4/22/23.
//

import Foundation

/**
 A chainable cache that temporarily stores data from its `next` cache and returns it if requested again.

 Most commonly used for file storage and DB storage of data, but can be set up for any combination of types as needed.
 */
actor TemporaryStorageResourceCache<ResourceID: Hashable> {
    init(dataStorage: some DataStorage<String>,idConverter: @escaping (ResourceID) -> String) {
        self.dataStorage = dataStorage
        self.idConverter = idConverter
    }

    private let dataStorage: any DataStorage<String>

    private let idConverter: (ResourceID) -> String
}

extension TemporaryStorageResourceCache: ResourceCache {
    typealias Resource = Data

    typealias ResourceID = ResourceID

    func cachedResourceWith(resourceID: ResourceID) async throws -> Data? {
        try await dataStorage.dataFor(dataIdentifier: idConverter(resourceID))
    }
}
