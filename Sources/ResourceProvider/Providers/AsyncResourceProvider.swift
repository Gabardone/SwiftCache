//
//  AsyncResourceProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 9/21/24.
//

public struct AsyncResourceProvider<ID: Hashable, Value> {
    /**
     Returns, asynchronously, the cached value for the given value ID in the calling cache. A sync cache is expected to
     always succeed in producing a value, use `ThrowingAsyncResourceProvider` if the operation may fail.
     - Parameter ID: The cache ID for the resource.
     - Returns: The value for the given `ID`
     */
    public var valueForID: (ID) async -> Value
}

public extension ResourceProvider {
    static func source<ID: Hashable, Value>(
        _ source: @escaping (ID) async -> Value
    ) -> AsyncResourceProvider<ID, Value> {
        AsyncResourceProvider(valueForID: source)
    }
}
