//
//  Cache.swift
//
//
//  Created by Óscar Morales Vivó on 4/23/23.
//

import Foundation
import os

/// Namespace `enum` for cache building. Functionality is built with the protocols in `CacheProtocols.swift` and the
/// various `extension` methods for them.
public enum Cache {}

extension Cache {
    static let logger = Logger(subsystem: "CacheLogging", category: "SwiftCache")

}
