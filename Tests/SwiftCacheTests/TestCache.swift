//
//  TestCache.swift
//  SwiftCache
//
//  Created by Óscar Morales Vivó on 8/22/24.
//

@testable import SwiftCache

extension ThrowingAsyncCache {
    /// Use this one if you don't need to keep the reference to the `TestCache` around.
    func validated(
        idValidation: ((ID) -> Void)? = nil,
        valueValidation: ((Value) -> Void)? = nil
    ) -> ThrowingAsyncCache {
        .init { id in
            idValidation?(id)
            let result = try await valueForID(id)
            valueValidation?(result)
            return result
        }
    }
}
