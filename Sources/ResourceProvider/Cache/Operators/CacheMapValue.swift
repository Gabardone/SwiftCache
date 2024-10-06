//
//  CacheMapValue.swift
//  swift-resource-provider
//
//  Created by Óscar Morales Vivó on 10/3/24.
//

public extension SyncCache {
    /**
     Maps a value type to the calling cache's value type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods have the id passed in, where you want to get the outside `ID` coming in from the provider so you
     can use it to encode or reconstitute any data lost in the id translation.
     - Parameters:
       - toStorage: A block that translates an id from `OtherValue` to `Self.Value` so it can be stored by the cache. It
     gets both the value and the associated id passed in. If translation is impossible or some other error occurs the
     block can return `nil`
       - fromStorage: A block that translates a cached value to `OtherValue`. It gets both the cached value and the
     associated id passed in. If translation is impossible or some other error occurs the block can return `nil`
     - Returns: A cache that takes `OtherID` as its `ID` type.
     */
    func mapValue<OtherValue>(
        toStorage: @escaping (OtherValue) -> Value?,
        fromStorage: @escaping (Value, ID) -> OtherValue?
    ) -> some SyncCache<ID, OtherValue> {
        AnySyncCache { id in
            valueFor(id: id).flatMap { value in
                fromStorage(value, id)
            }
        } storeValueForID: { value, id in
            if let cacheValue = toStorage(value) {
                store(value: cacheValue, id: id)
            }
        }
    }

    /**
     Maps a value type to the calling cache's value type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods have the id passed in, where you want to get the outside `ID` coming in from the provider so you
     can use it to encode or reconstitute any data lost in the id translation.
     - Parameters:
       - toStorage: A block that translates an id from `OtherValue` to `Self.Value` so it can be stored by the cache. It
     gets both the value and the associated id passed in. If translation is impossible or some other error occurs the
     block can return `nil`
       - fromStorage: A block that translates a cached value to `OtherValue`. It gets both the cached value and the
     associated id passed in. If translation is impossible or some other error occurs the block can return `nil`
     - Returns: A cache that takes `OtherID` as its `ID` type.
     */
    func mapValue<OtherValue>(
        toStorage: @escaping (OtherValue) async -> Value?,
        fromStorage: @escaping (Value, ID) async -> OtherValue?
    ) -> some AsyncCache<ID, OtherValue> {
        AnyAsyncCache { id in
            if let storedValue = valueFor(id: id) {
                await fromStorage(storedValue, id)
            } else {
                nil
            }
        } storeValueForID: { value, id in
            if let cacheValue = await toStorage(value) {
                store(value: cacheValue, id: id)
            }
        }
    }
}

public extension AsyncCache {
    /**
     Maps a value type to the calling cache's value type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods have the id passed in, where you want to get the outside `ID` coming in from the provider so you
     can use it to encode or reconstitute any data lost in the id translation.
     - Parameters:
       - toStorage: A block that translates an id from `OtherValue` to `Self.Value` so it can be stored by the cache. It
     gets both the value and the associated id passed in. If translation is impossible or some other error occurs the
     block can return `nil`
       - fromStorage: A block that translates a cached value to `OtherValue`. It gets both the cached value and the
     associated id passed in. If translation is impossible or some other error occurs the block can return `nil`
     - Returns: A cache that takes `OtherID` as its `ID` type.
     */
    func mapValue<OtherValue>(
        toStorage: @escaping (OtherValue) -> Value?,
        fromStorage: @escaping (Value, ID) -> OtherValue?
    ) -> some AsyncCache<ID, OtherValue> {
        AnyAsyncCache { id in
            await valueFor(id: id).flatMap { storedValue in
                fromStorage(storedValue, id)
            }
        } storeValueForID: { value, id in
            if let cacheValue = toStorage(value) {
                await store(value: cacheValue, id: id)
            }
        }
    }

    /**
     Maps a value type to the calling cache's value type.

     If you want to map both `ID` and `Value` it's usually best to map the the `ID` first (above) since the value
     mapping methods have the id passed in, where you want to get the outside `ID` coming in from the provider so you
     can use it to encode or reconstitute any data lost in the id translation.
     - Parameters:
       - toStorage: A block that translates an id from `OtherValue` to `Self.Value` so it can be stored by the cache. It
     gets both the value and the associated id passed in. If translation is impossible or some other error occurs the
     block can return `nil`
       - fromStorage: A block that translates a cached value to `OtherValue`. It gets both the cached value and the
     associated id passed in. If translation is impossible or some other error occurs the block can return `nil`
     - Returns: A cache that takes `OtherID` as its `ID` type.
     */
    func mapValue<OtherValue>(
        toStorage: @escaping (OtherValue) async -> Value?,
        fromStorage: @escaping (Value, ID) async -> OtherValue?
    ) -> some AsyncCache<ID, OtherValue> {
        AnyAsyncCache { id in
            if let storedValue = await valueFor(id: id) {
                await fromStorage(storedValue, id)
            } else {
                nil
            }
        } storeValueForID: { value, id in
            if let cacheValue = await toStorage(value) {
                await store(value: cacheValue, id: id)
            }
        }
    }
}
