//
//  ThrowingSyncProvider.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 9/21/24.
//

/**
 A resouce provider that returns values synchronously and may fail.

 A `ThrowingSyncProvider` will `throw` if value retrieval fails. It may be used for those cases where we want to cache
 the result of calling sync failable system APIs:
 - To manage storage of a set of lightly modified SF Symbols.
 */
public struct ThrowingSyncProvider<ID: Hashable, Value> {
    /**
     Returns, ssynchronously, the value for the given ID. A `ThrowingSyncProvider` will throw if it fails to return a
     value. In that case, the implementation should ensure that the operations leaves no side effects in the provider's
     state and a subsequent call to the provider for the same `ID` will run the same logic again.
     - Parameter ID: The ID for the resource.
     - Returns: The value for the given `ID`
     */
    public var valueForID: (ID) throws -> Value
}

public extension Provider {
    /**
     Builds a throwing synchronous provider source.
     - Parameter source: A block that generates values based on a given `ID`, or throws if it cannot.
     - Returns: An synchronous provider that generates its values by running the given block.
     */
    static func source<ID: Hashable, Value>(
        _ source: @escaping (ID) throws -> Value
    ) -> ThrowingSyncProvider<ID, Value> {
        ThrowingSyncProvider(valueForID: source)
    }
}
