//
//  ValueSource.swift
//
//
//  Created by Óscar Morales Vivó on 4/22/23.
//

import Foundation

/**
 A protocol for asynchronous, failable access to values by identifier.

 Caches that fetch data from storage should use a façaded `ValueSource` to perform those operations as to allow
 for testability and overall abstract away hard dependencies on storage APIs (DBs, network, file system…).

 A value source implementation must be safe against reentrance for different identifiers since it may get several
 simultaneous requests from a cache. This can either be accomplished by making an adopting type with internal storage
 that is unsafe against cross-threaded access into an `actor`, using locks for internal state access or by using APIs
 that are thread safe (i.e. `FileManager`, `URLSession`) although that last option may lead to performance issues.

 It is recommended that adopting types are named `*<Type>Source`. For examples, as seen in this package,
 `NetworkDataSource`. Types that adopt `ValueStorage` are named `*<type>Storage` instead.
 */
public protocol ValueSource<Stored, StorageID> {
    /**
     The type used for storage.
     */
    associatedtype Stored

    /**
     Type used to identify a stored value.
     */
    associatedtype StorageID: Hashable

    /**
     returns the value, if any, for the given `identifier`.

     The method will return `nil` if the value cannot be retrieved (whether because it's in storage, cannot be built
     or may not be returned for some other reason depends on the implementation). Overall `nil` is a valid return if
     it's repeatable and not caused by a subsystem failure but by an inability of the value source to retrieve the
     value for the given ID by its design.

     If there is a failure in the value retrieval process then the method will throw instead.

     For example a network based resource value storage will return nil if the resource isn't present in the backend,
     but it will throw if there is a network error. In the former case a repeated call to the value source will not
     make any difference while in the latter if the error can be tackled the method would be expected to return
     successfully.
     - Parameter identifier: The identifier to use for data retrieval. Must be unique and stable.
     - Returns: The value fetched from local persistence, or `nil` if none can be found in storage for `identifier`.
     */
    func valueFor(identifier: StorageID) async throws -> Stored?
}
