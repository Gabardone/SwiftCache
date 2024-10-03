//
//  StorageProtocols.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

/// Note: This doesn't have throwing versions because the attached composed cache will keep working even if they fail,
/// even if at a reduced performance.
///
/// You should still deal sensibly with storage failures (i.e. log etc.)
public protocol SyncStorage<ID, Value> {
    associatedtype ID: Hashable

    associatedtype Value

    func valueFor(id: ID) -> Value?

    func store(value: Value, id: ID)
}

/// Note: This doesn't have throwing versions because the attached composed cache will keep working even if they fail,
/// even if at a reduced performance.
///
/// You should still deal sensibly with storage failures (i.e. log etc.)
public protocol AsyncStorage<ID, Value> {
    associatedtype ID: Hashable

    associatedtype Value

    func valueFor(id: ID) async -> Value?

    func store(value: Value, id: ID) async
}
