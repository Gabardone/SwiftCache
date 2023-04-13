//
//  RemoteResourceCache.swift
//  RemoteResourceCache
//
//  Created by Óscar Morales Vivó on 1/8/23.
//

import Foundation

/**
 A remote resource cache for an app who fetches uniquely identifiable, immutable resources.

 The cache is declared as an actor as to make clear that all access to it has to happen asynchronously, but the
 implementation is mostly sequential as to keep cache state consistency.

 The global dependencies on system services are abstracted away behind an implementation of the `ImageDataSource`
 protocol. Use `DefaultImageDataSource` to use the system's networking/file services, or build a mock one for testing.

 The cache will work under the assumption that the URLs will be tasked to fetch and cache are built up in the same way
 as the ones found in the sample json replies. I.e. the last components of the URL path are "\<UUID\>/size.jpg".

 The cache will also assume that all images pointed at by given URLs are immutable, and once cached no refresh would
 ever be needed unless their data were dropped from storage.

 - Note: There's some issues with actor behavior (namely that the order of calls made from a serial thread
 like the main one doesn't necessarily correspond to the order in which operations begin in the actor) which make them
 surprisingly less useful than expected in regular app use. For a cache solution like this however they are not an
 obstacle, so this is an easy way to guarantee cache correctness and avoid accidental repeated operations.
 */
public actor RemoteResourceCache<Resource: AnyObject> {
    public typealias DataToResource = (Data) throws -> Resource

    public enum CacheError: Error, Equatable {
        case unableToDecodeLocalData
        case unableToDecodeRemoteData
    }

    public init(resourceDataProvider: ResourceDataProvider, dataToResource: @escaping DataToResource) {
        self.resourceDataProvider = resourceDataProvider
        self.dataToResource = dataToResource
    }

    private let resourceDataProvider: any ResourceDataProvider

    private let dataToResource: (Data) throws -> Resource

    public func fetchResource(remoteURL: URL) throws -> Task<Resource, Error> {
        if let inMemoryImage = inMemoryResources.object(forKey: remoteURL as NSURL) {
            // Well watcha know we already have it.
            return Task { inMemoryImage }
        }

        let fetchTask: Task<Resource, Error>
        if let inFlightTask = inFlightTasks[remoteURL] {
            fetchTask = inFlightTask
        } else {
            fetchTask = Task { [resourceDataProvider] in
                let resource: Resource
                do {
                    // Let's just try to read the data from the file.
                    let resourceData = try resourceDataProvider.localData(remoteURL: remoteURL)

                    // Let's make sure we can still decode the image proper.
                    resource = try dataToResource(resourceData)
                } catch {
                    // If we couldn't get the data from the file we'll have to download it.
                    let resourceData = try await resourceDataProvider.remoteData(remoteURL: remoteURL)

                    // We don't want to store the data locally if we can't decode it into an UIImage.
                    let decodedResource = try dataToResource(resourceData)

                    // Time to store locally for future tasks to find earlier.
                    try resourceDataProvider.storeLocally(data: resourceData, remoteURL: remoteURL)

                    resource = decodedResource
                }

                // Update the in-memory storage. We're in an actor so this should be orderly.
                // Starting with `inMemoryResources` means that even if there's reentrancy it will do the right thing.
                inMemoryResources.setObject(resource, forKey: remoteURL as NSURL)

                // Now that everything is in place we can remove this oversized task as to free resources.
                inFlightTasks.removeValue(forKey: remoteURL)

                return resource
            }

            // The task won't start running until we're done with this method. Store it in case someone else asks for
            // this `imageURL` before the task is done.
            inFlightTasks[remoteURL] = fetchTask
        }

        return fetchTask
    }

    /// Once again using the jankiest class in Foundation because it's the one officially supported weak dictionary.
    private let inMemoryResources = NSMapTable<NSURL, Resource>.strongToWeakObjects()

    /**
     This keeps around the current in flight tasks so we don't accidentally try to download or read from file the
     same image more than once.
     */
    private var inFlightTasks = [URL: Task<Resource, Error>]()
}
