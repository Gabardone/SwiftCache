//
//  UniqueFileNameResourceIdentifier.swift
//
//
//  Created by Óscar Morales Vivó on 4/13/23.
//

import Foundation

/**
 A type of resource identifier where the remote resource is a URL whose last path component is unique.

 If your resources are already named with a GUID or have otherwise a unique file name among their peers for their path
 this implementation of `ResourceIdentifier` will do the trick.
 */
public struct UniqueFileNameResourceIdentifier: Identifiable {
    public init(_ remoteAddress: URL) {
        self.id = remoteAddress
    }

    /// We use the URL as both the ID and the remote address.
    public let id: URL
}

extension UniqueFileNameResourceIdentifier: ResourceIdentifier {
    public var remoteAddress: URL {
        id
    }

    public var localIdentifier: String {
        id.lastPathComponent
    }
}
