//
//  NetworkDataSource.swift
//
//
//  Created by Óscar Morales Vivó on 4/23/23.
//

import Foundation

public extension Cache {
    /**
     A simple implementation of a network based cache source that returns the data at the given `URL`.

     This is a most basic example, if you need more sophisticated networking you can build up using this one as a
     baseline. It returns a `ThrowingAsyncCache` since networking is slow enough that it wouldn't make sense to make it
     synchronous for about any use casel.

     Some suggestions for use:
     - Use `mapID(_:)` to convert any other identifying data to a `URL` that can feed this.
     - Make sure there's a `coordinated()` addition to the cache chain if you don't want the same `URL` to go to the
     network twice.
     */
    static func networkDataSource(urlSession: URLSession = .shared) -> some ThrowingAsyncCache<URL, Data> {
        source { url in
            try await urlSession.data(from: url).0
        }
    }
}
