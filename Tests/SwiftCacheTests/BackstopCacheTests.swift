//
//  BackstopCacheTests.swift
//
//
//  Created by Óscar Morales Vivó on 2/5/24.
//

@testable import SwiftCache
import XCTest

final class BackstopCacheTests: XCTestCase {
    func testSimpleRequest() async throws {
        let identifier = "Potato"
        let generatorStorage = GeneratorStorage { (id: String) in
            "I like " + id
        }

        let backstopCache = BackstopCache(storage: generatorStorage)
        let fetchedValue = try await backstopCache.cachedValueWith(identifier: identifier)

        XCTAssertEqual(fetchedValue, "I like " + identifier)
    }

    // Checks that two requests for the same identifier at the same time will cause a single task to execute.
    func testReentrancy() async throws {
        let identifier = "Potato"

        // Task left behind by the first entrance in the cache. Also checked by generator to make sure we went past.
        var firstCacheGate: Task<Void, Never>?
        // Task left behind by the second entrance in the cache. Also checked by generator to make sure we went past.
        var secondCacheGate: Task<Void, Never>?

        // Used to ensure reentrancy by making first entrance wait until second entrance to continue.
        var firstContinuation: CheckedContinuation<Void, Never>?

        let generatorExpectation = expectation(description: "Generator generated its thing.")
        let generatorStorage = GeneratorStorage { (id: String) in
            generatorExpectation.fulfill()

            XCTAssertNotNil(firstCacheGate)
            XCTAssertNotNil(secondCacheGate)
            _ = await (firstCacheGate?.value, secondCacheGate?.value)

            return "I like " + id
        }

        let backstopCache = BackstopCache(storage: generatorStorage)
        let backstopExpectation = expectation(description: "Cache called")
        backstopExpectation.expectedFulfillmentCount = 2
        var hasEntered = false
        await backstopCache.setEnteredCachedValueWithIdentifier { _ in
            backstopExpectation.fulfill()
            if hasEntered {
                XCTAssertNotNil(firstContinuation)
                firstContinuation?.resume()

                secondCacheGate = Task {}
            } else {
                hasEntered = true

                await withCheckedContinuation { continuation in
                    firstContinuation = continuation
                }

                firstCacheGate = Task {}
            }
        }

        async let firstFetch = backstopCache.cachedValueWith(identifier: identifier)
        async let secondFetch = backstopCache.cachedValueWith(identifier: identifier)

        let (firstFetchedValue, secondFetchedValue) = try await (firstFetch, secondFetch)

        await fulfillment(of: [generatorExpectation, backstopExpectation])

        XCTAssertEqual(firstFetchedValue, "I like " + identifier)
        XCTAssertEqual(firstFetchedValue, secondFetchedValue)
    }
}
