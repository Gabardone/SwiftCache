//
//  EmptyCache.swift
//
//
//  Created by Óscar Morales Vivó on 9/12/23.
//

import Foundation

/**
 A cache that is always empty.

 This may not seem like much, but it makes for a great stub to use in testing and preview work.
 */
public actor EmptyCache<Cached, CacheID: Hashable> {
    public init() {}
}

extension EmptyCache: Cache {
    public func cachedValueWith(identifier _: CacheID) async throws -> Cached? {
        nil
    }

    public func invalidateCachedValueFor(identifier _: CacheID) async throws {
        // This method deliberately left blank.
    }
}
