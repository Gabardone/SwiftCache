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
 */
public struct WeakObjectStorage<Object: AnyObject, StorageID: Hashable> {
    /**
     A simple, private wrapper type so non-object and non-Obj-C types can be used with a `NSMapTable`. An implementation
     detail.
     */
    fileprivate class KeyWrapper {
        init(wrapping: StorageID) {
            self.wrapping = wrapping
        }

        let wrapping: StorageID
    }

    // MARK: - Stored Properties

    private let weakObjects = NSMapTable<KeyWrapper, Object>.strongToWeakObjects()
}

extension WeakObjectStorage: ReadOnlyStorage {
    public typealias Stored = Object

    public typealias StorageID = StorageID

    public func storedValueFor(identifier: StorageID) -> Object? {
        weakObjects.object(forKey: .init(wrapping: identifier))
    }
}

extension WeakObjectStorage: Storage {
    public func store(value: Object, identifier: StorageID) {
        weakObjects.setObject(value, forKey: .init(wrapping: identifier))
    }
}
