//
//  SeveritySortingTests.swift
//  DrugInteractionCheckerTests
//

import XCTest
@testable import DrugInteractionChecker

final class SeveritySortingTests: XCTestCase {
    func testSortBySeverity_ordersHighBeforeLow() {
        let low = DrugInteraction(
            drug1Name: "a",
            drug2Name: "b",
            clinicalDescription: "low",
            severity: .low
        )
        let high = DrugInteraction(
            drug1Name: "c",
            drug2Name: "d",
            clinicalDescription: "high",
            severity: .high
        )
        let moderate = DrugInteraction(
            drug1Name: "e",
            drug2Name: "f",
            clinicalDescription: "mod",
            severity: .moderate
        )

        let sorted = DrugInteractionViewModel.sortBySeverity([low, high, moderate])
        XCTAssertEqual(sorted.map(\.severity), [.high, .moderate, .low])
    }

    func testInteractionSeverityFromAPI_normalizesNA() {
        XCTAssertEqual(InteractionSeverity.from(apiValue: "N/A"), .unknown)
        XCTAssertEqual(InteractionSeverity.from(apiValue: "HIGH"), .high)
    }
}
