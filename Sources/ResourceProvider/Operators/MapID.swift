//
//  MapID.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import Foundation

public extension SyncProvider {
    /**
     Maps an id type to the calling provider's id type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods has the id passed in, where you want to get the outside `ID` coming from the earlier provider so
     you can use it to encode or reconstitute any data lost in the id translation.
     - Parameter transform: A block that translates an id of `OtherID` type to the one used by the calling provider.
     - Returns: A provider that takes `OtherID` as its `ID` type.
     */
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> SyncProvider<OtherID, Value> {
        .init { otherID in
            valueForID(transform(otherID))
        }
    }
}

public extension ThrowingSyncProvider {
    /**
     Maps an id type to the calling provider's id type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods has the id passed in, where you want to get the outside `ID` coming from the earlier provider so
     you can use it to encode or reconstitute any data lost in the id translation.
     - Parameter transform: A block that translates an id of `OtherID` type to the one used by the calling provider.
     - Returns: A provider that takes `OtherID` as its `ID` type.
     */
    func mapID<OtherID: Hashable>(
        _ transform: @escaping (OtherID) -> ID
    ) -> ThrowingSyncProvider<OtherID, Value> {
        .init { otherID in
            try valueForID(transform(otherID))
        }
    }
}

public extension AsyncProvider {
    /**
     Maps an id type to the calling provider's id type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods has the id passed in, where you want to get the outside `ID` coming from the earlier provider so
     you can use it to encode or reconstitute any data lost in the id translation.
     - Parameter transform: A block that translates an id of `OtherID` type to the one used by the calling provider.
     - Returns: A provider that takes `OtherID` as its `ID` type.
     */
    func mapID<OtherID: Hashable>(_ transform: @escaping (OtherID) -> ID) -> AsyncProvider<OtherID, Value> {
        .init { otherID in
            await valueForID(transform(otherID))
        }
    }
}

public extension ThrowingAsyncProvider {
    /**
     Maps an id type to the calling provider's id type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods has the id passed in, where you want to get the outside `ID` coming from the earlier provider so
     you can use it to encode or reconstitute any data lost in the id translation.
     - Parameter transform: A block that translates an id of `OtherID` type to the one used by the calling provider.
     - Returns: A provider that takes `OtherID` as its `ID` type.
     */
    func mapID<OtherID: Hashable>(
        _ transform: @escaping (OtherID) -> ID
    ) -> ThrowingAsyncProvider<OtherID, Value> {
        .init { otherID in
            try await valueForID(transform(otherID))
        }
    }
}
