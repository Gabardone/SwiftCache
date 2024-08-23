//
//  TestCache.swift
//  SwiftCache
//
//  Created by Óscar Morales Vivó on 8/22/24.
//

@testable import SwiftCache

class TestCache<ID: Hashable, Value, Parent: ThrowingAsyncCache> where Parent.ID == ID, Parent.Value == Value {
    let parent: Parent

    var idValidation: ((ID) -> Void)?

    var valueValidation: ((Result<Value, Error>) -> Void)?

    init(
        parent: Parent,
        idValidation: ((ID) -> Void)? = nil,
        valueValidation: ((Result<Value, Error>) -> Void)? = nil
    ) {
        self.parent = parent
        self.idValidation = idValidation
        self.valueValidation = valueValidation
    }
}

extension TestCache: ThrowingAsyncCache {
    func cachedValueWith(id: ID) async throws -> Value {
        idValidation?(id)
        let result = await Result(asyncCatching: { try await parent.cachedValueWith(id: id) })
        valueValidation?(result)
        return try result.get()
    }
}

extension ThrowingAsyncCache {
    /// Use this one if you don't need to keep the reference to the `TestCache` around.
    func validated(
        idValidation: ((ID) -> Void)? = nil,
        valueValidation: ((Result<Value, Error>) -> Void)? = nil
    ) -> some ThrowingAsyncCache<ID, Value> {
        TestCache(parent: self, idValidation: idValidation, valueValidation: valueValidation)
    }

    /// Use this one if you want to get a reference to the `TestCache` for later tweaking.
    func validated(
        validator: inout TestCache<ID, Value, Self>?,
        idValidation: ((ID) -> Void)? = nil,
        valueValidation: ((Result<Value, Error>) -> Void)? = nil
    ) -> some ThrowingAsyncCache<ID, Value> {
        let testCache = TestCache(parent: self, idValidation: idValidation, valueValidation: valueValidation)
        validator = testCache
        return testCache
    }
}
