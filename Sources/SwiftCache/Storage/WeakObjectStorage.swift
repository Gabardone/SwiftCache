//
//  WeakObjectStorage.swift
//
//
//  Created by Óscar Morales Vivó on 4/23/23.
//

import Foundation

/**
 In-memory `weak` reference storage for objects.

 Since `weak` references can only be used for reference types, this won't work for value types.

 The type is an `actor` as to ensure thread safety for access to its internal storage.
 */
public struct WeakObjectStorage<ID: Hashable, Value: AnyObject> {
    public init() {}

    // MARK: - Stored Properties

    private let weakObjects = NSMapTable<KeyWrapper<ID>, Value>.strongToWeakObjects()
}

extension WeakObjectStorage: SyncStorage {
    public func valueFor(id: ID) -> Value? {
        weakObjects.object(forKey: .init(wrapping: id))
    }

    public func store(value: Value, id: ID) {
        weakObjects.setObject(value, forKey: .init(wrapping: id))
    }
}

/**
 A simple, private wrapper type so non-object and non-Obj-C types can be used with a `NSMapTable`. An implementation
 detail.
 */
private class KeyWrapper<ID: Hashable>: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        self
    }

    init(wrapping: ID) {
        self.wrapping = wrapping
    }

    let wrapping: ID
}

extension KeyWrapper: Equatable {
    static func == (lhs: KeyWrapper<ID>, rhs: KeyWrapper<ID>) -> Bool {
        lhs.wrapping == rhs.wrapping
    }
}

extension KeyWrapper: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(wrapping)
    }
}
