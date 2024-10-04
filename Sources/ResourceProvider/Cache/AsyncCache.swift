//
//  AsyncCache.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

/// Note: This doesn't have throwing versions because the attached composed cache will keep working even if they fail,
/// even if at a reduced performance.
///
/// You should still deal sensibly with cache failures (i.e. log etc.)
public protocol AsyncCache<ID, Value> {
    associatedtype ID: Hashable

    associatedtype Value

    func valueFor(id: ID) async -> Value?

    func store(value: Value, id: ID) async
}
