//
//  TestStorage.swift
//  SwiftCache
//
//  Created by Óscar Morales Vivó on 8/22/24.
//

import SwiftCache

/// Unlike `AnyStorage`, it's a reference type and allows for swapping around the functionality so it can be more
/// readily used in tests.
class TestStorage<ID: Hashable, Value> {
    var valueForID: (ID) async -> Value?

    var storeValueForID: (ID, Value) async -> Void

    init(valueForID: @escaping (ID) -> Value?, storeValueForID: @escaping (ID, Value) -> Void) {
        self.valueForID = valueForID
        self.storeValueForID = storeValueForID
    }
}

extension TestStorage: AsyncStorage {
    func valueFor(id: ID) async -> Value? {
        await valueForID(id)
    }

    func store(value: Value, id: ID) async {
        await storeValueForID(id, value)
    }
}

extension SyncStorage {
    func validated(
        fetchValidation: ((ID, Value?) -> Void)? = nil,
        storeValidation: ((ID, Value) -> Void)? = nil
    ) -> some AsyncStorage<ID, Value> {
        AnyAsyncStorage { id in
            let result = valueFor(id: id)
            fetchValidation?(id, result)
            return result
        } storeValueForID: { value, id in
            storeValidation?(id, value)
            store(value: value, id: id)
        }
    }
}
