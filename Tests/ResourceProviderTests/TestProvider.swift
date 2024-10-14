//
//  TestProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/22/24.
//

@testable import ResourceProvider

extension ThrowingAsyncProvider {
    /// You can interspede a provider chain in tests with one of these to validate that the right id and/or resource
    /// values are being passed around.
    /// - Parameters:
    ///   - idValidation: An optional block called with the requested ID before requesting the value from the parent's
    ///   provider for validation.
    ///   - valueValidation: An optional block called with the returned value from the parent for validation.
    func validated(
        idValidation: ((ID) -> Void)? = nil,
        valueValidation: ((Value) -> Void)? = nil
    ) -> ThrowingAsyncProvider {
        .init { id in
            idValidation?(id)
            let result = try await valueForID(id)
            valueValidation?(result)
            return result
        }
    }
}
