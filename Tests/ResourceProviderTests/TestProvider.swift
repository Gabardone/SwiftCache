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
    ///   - idValidation: An optional block that gets the requested ID passed in as a parameter.
    ///   - valueValidation: An optional block that gets the returned value passed in as a parameter.
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
