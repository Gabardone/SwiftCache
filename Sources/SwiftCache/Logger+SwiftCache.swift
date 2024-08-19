//
//  Logger+SwiftCache.swift
//
//
//  Created by Óscar Morales Vivó on 8/18/24.
//

import os

/**
 Module-wide logger object.
 */
extension Logger {
    static let cache = Logger(subsystem: "CacheLogging", category: "SwiftCache")
}
