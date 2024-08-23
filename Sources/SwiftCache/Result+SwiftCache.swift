//
//  Result+SwiftCache.swift
//  SwiftCache
//
//  Created by Óscar Morales Vivó on 8/22/24.
//

extension Result where Failure == Error {
    init(asyncCatching body: () async throws -> Success) async {
        do {
            self = try await .success(body())
        } catch {
            self = .failure(error)
        }
    }
}
