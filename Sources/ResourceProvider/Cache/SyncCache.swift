//
//  SyncCache.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/3/24.
//

/// Note: This doesn't have throwing versions because the attached provider will keep working even if they fail,
/// if at a reduced performance.
///
/// You should still deal sensibly with cache failures (i.e. log etc.)
public protocol SyncCache<ID, Value> {
    associatedtype ID: Hashable

    associatedtype Value

    func valueFor(id: ID) -> Value?

    func store(value: Value, id: ID)
}
