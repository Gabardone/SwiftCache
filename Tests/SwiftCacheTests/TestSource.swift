//
//  TestSource.swift
//  SwiftCache
//
//  Created by Óscar Morales Vivó on 8/22/24.
//

import SwiftCache

/// Unlike `AnyCache`, it's a reference type and allows for swapping around the functionality so it can be more readily
/// used in tests.
class TestSource<ID: Hashable, Value> {
    // Can be adjustable on the fly during a test. Don't do this for production logic.
    var cachedValueWithID: (ID) async throws -> Value

    init(cachedValueWithID: @escaping (ID) async throws -> Value) {
        self.cachedValueWithID = cachedValueWithID
    }
}

extension TestSource: ThrowingAsyncCache {
    func cachedValueWith(id: ID) async throws -> Value {
        try await cachedValueWithID(id)
    }
}

extension Cache {
    /// Use this one if you want to hold a reference to the test source for manipulation during the test.
    func testSource<ID: Hashable, Value>(
        testSource: inout TestSource<ID, Value>?,
        cachedValueWithID: @escaping (ID) async throws -> Value
    ) -> some ThrowingAsyncCache<ID, Value> {
        let source = TestSource(cachedValueWithID: cachedValueWithID)
        testSource = source
        return source
    }
}
