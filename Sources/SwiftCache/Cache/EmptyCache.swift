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
}

extension EmptyCache: Cache {
    public func cachedValueWith(identifier: CacheID) async throws -> Cached? {
        return nil
    }

    public func invalidateCachedValueFor(identifier: CacheID) async throws {
        // This method deliberately left blank.
    }
}
