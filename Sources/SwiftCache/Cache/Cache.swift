//
//  Cache.swift
//
//
//  Created by Óscar Morales Vivó on 4/23/23.
//

import Foundation

/// Namespace `enum` for cache building.
public enum Cache {}

/**
 A cache component that sources the values.

 This type is meant to be used as the start of a cache setup, either fetching or generating the values that will be
 stored by subsequent steps. It has no smarts beyond calling the block it's set up with a given `id`, if you want to
 avoid redundant work you should attach a `CoordinatedCache` to it.

 Common examples would be network-backed value fetching (see `NetworkSource` for a simple baseline one) or expensive
 image generation.
 */
public struct Cache<ID: Hashable, Value, ValueProvider: SwiftCache.ValueProvider> where ValueProvider.ID == ID, ValueProvider.Value == Value {

    // MARK: - Lifetime

    /**
     Private initializer. Use the extension ones to initialize.

     To placate the Swift type system while allowing for sync and/or non-throwing `Source` types, the initializer is
     kept private and all the creation is externally done with the `extension` initializers.
     - Parameter storage: The storage where we will attempt to fetch values from.
     - Parameter idConverter: A block that converts cache IDs to storage IDs for the cache's storage.
     - Parameter fromStorageConverter: A block that converts storage values into cache values.
     */
    init(valueProvider: ValueProvider) {
        self.valueProvider = valueProvider
    }

    // MARK: - Stored Properties

    private let valueProvider: ValueProvider
}

/**
 Functionality wrapper.

 This is an unfortunate leaky abstraction to help allow for non-throwing and/or non-async `Source` adoptions of `Cache`.
 Do not use directly.
 */
public protocol ValueProvider {
    associatedtype ID: Hashable

    associatedtype Value
}

// MARK: - Sync Cache

public struct SyncValueProvider<ID: Hashable, Value>: ValueProvider {
    public typealias ID = ID
    public typealias Value = Value

    fileprivate let block: (ID) -> Value
}

extension Cache: SyncCache where ValueProvider == SyncValueProvider<ID, Value> {
    public func cachedValueWith(id: ID) -> Value {
        valueProvider.block(id)
    }

    public init(valueProvider: @escaping (ID) -> Value) {
        self.valueProvider =  ValueProvider(block: valueProvider)
    }
}

// MARK: - Throwing Sync Cache

public struct ThrowingValueProvider<ID: Hashable, Value>: ValueProvider {
    public typealias ID = ID
    public typealias Value = Value

    fileprivate let block: (ID) throws -> Value
}

extension Cache: ThrowingSyncCache where ValueProvider == ThrowingValueProvider<ID, Value> {
    public func cachedValueWith(id: ID) throws -> Value {
        try valueProvider.block(id)
    }

    public init(valueProvider: @escaping (ID) throws -> Value) {
        self.valueProvider = ThrowingValueProvider(block: valueProvider)
    }
}

// MARK: - Async Cache

public struct AsyncValueProvider<ID: Hashable, Value>: ValueProvider {
    public typealias ID = ID
    public typealias Value = Value

    fileprivate let block: (ID) async -> Value
}

extension Cache: AsyncCache where ValueProvider == AsyncValueProvider<ID, Value> {
    public func cachedValueWith(id: ID) async -> Value {
        await valueProvider.block(id)
    }

    public init(valueProvider: @escaping (ID) async -> Value) {
        self.valueProvider = AsyncValueProvider(block: valueProvider)
    }
}

// MARK: - Throwing Async Cache

public struct ThrowingAsyncValueProvider<ID: Hashable, Value>: ValueProvider {
    public typealias ID = ID
    public typealias Value = Value

    fileprivate let block: (ID) async throws -> Value
}

extension Cache: ThrowingAsyncCache where ValueProvider == ThrowingAsyncValueProvider<ID, Value> {
    public func cachedValueWith(id: ID) async throws -> Value {
        try await valueProvider.block(id)
    }

    public init(valueProvider: @escaping (ID) async throws -> Value) {
        self.valueProvider = ThrowingAsyncValueProvider(block: valueProvider)
    }
}
