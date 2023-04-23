//
//  InMemoryWeakResourceCache.swift
//  
//
//  Created by Óscar Morales Vivó on 4/22/23.
//

import Foundation

/**
 A simple implementation of a Chainable cache that stores objects in memory using weak references.

 The cache's stored values need to be objects (can't hold value types weakly in Swift) and the resource ID must adopt
 `Hashable` by itself as it is used as a
  to a `String` in a repeatable way that maintains uniqueness due to the implementation detail of
 */
public actor InMemoryWeakResourceCache<Resource: AnyObject, ResourceID: Hashable, Next: ResourceCache> {

    init(next: Next?, nextProcessor: @escaping (Next.Resource) async throws -> Resource) {
        self.next = next
        self.nextProcessor = nextProcessor
    }

    // MARK: - Types

    /**
     A simple, private wrapper type so non-object and non-Obj-C types can be used with a `NSMapTable`. An implementation
     detail.
     */
    fileprivate class KeyWrapper {
        init(wrapping: ResourceID) {
            self.wrapping = wrapping
        }

        let wrapping: ResourceID
    }

    // MARK: - Stored Properties

    public let next: Next?

    private let weakObjects = NSMapTable<KeyWrapper, Resource>.strongToWeakObjects()

    private let nextProcessor: (Next.Resource) async throws -> Resource
}

extension InMemoryWeakResourceCache: ResourceCache where Next.ResourceID == ResourceID {
    public typealias ResourceID = ResourceID

    public typealias Resource = Resource

    public func cachedResourceWith(resourceID: ResourceID) -> Resource? {
        weakObjects.object(forKey: .init(wrapping: resourceID))
    }
}

extension InMemoryWeakResourceCache: ChainableResourceCache where Next.ResourceID == ResourceID {
    public typealias Next = Next

    public func processFromNext(nextResource: Next.Resource) async throws -> Resource {
        try await nextProcessor(nextResource)
    }

    public func store(resource: Resource, resourceID: ResourceID) {
        weakObjects.setObject(resource, forKey: .init(wrapping: resourceID))
    }
}

extension InMemoryWeakResourceCache where Next.Resource == Resource {
    init(next: Next?) {
        self.init(next: next) { $0 }
    }
}

extension InMemoryWeakResourceCache.KeyWrapper: Hashable {
    static func == (lhs: InMemoryWeakResourceCache<Resource, ResourceID, Next>.KeyWrapper, rhs: InMemoryWeakResourceCache<Resource, ResourceID, Next>.KeyWrapper) -> Bool {
        lhs.wrapping == rhs.wrapping
    }

    func hash(into hasher: inout Hasher) {
        wrapping.hash(into: &hasher)
    }
}
