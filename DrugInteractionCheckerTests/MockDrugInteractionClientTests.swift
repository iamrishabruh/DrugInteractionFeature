//
//  MockDrugInteractionClientTests.swift
//  DrugInteractionCheckerTests
//

import XCTest
@testable import DrugInteractionChecker

final class MockDrugInteractionClientTests: XCTestCase {
    func testResolveMedications_matchesKnownDirectory() async throws {
        let client = MockDrugInteractionClient()
        let meds = try await client.resolveMedications(names: [" Aspirin "])
        XCTAssertEqual(meds.count, 1)
        XCTAssertEqual(meds[0].name, "Aspirin")
        XCTAssertEqual(meds[0].rxcui, "1191")
    }

    func testResolveMedications_unknownDrugHasNilRxCUI() async throws {
        let client = MockDrugInteractionClient()
        let meds = try await client.resolveMedications(names: ["not-in-directory-xyz"])
        XCTAssertEqual(meds.first?.rxcui, nil)
    }

    func testFetchInteractions_returnsMatrixMatch() async throws {
        let client = MockDrugInteractionClient()
        let rows = try await client.fetchInteractions(forRxCUIs: ["1191", "855290"])
        XCTAssertFalse(rows.isEmpty)
        XCTAssertTrue(rows.contains { $0.severity == .high })
    }

    func testNetworkFailureMode_surfacesError() async {
        let client = MockDrugInteractionClient()
        client.mode = .networkFailure

        do {
            _ = try await client.resolveMedications(names: ["aspirin"])
            XCTFail("Expected error")
        } catch let error as DrugInteractionError {
            if case .networkFailure = error { return }
            XCTFail("Unexpected error \(error)")
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func testApiUnavailableMode_surfacesError() async {
        let client = MockDrugInteractionClient()
        client.mode = .apiUnavailable

        do {
            _ = try await client.fetchInteractions(forRxCUIs: ["1191"])
            XCTFail("Expected error")
        } catch let error as DrugInteractionError {
            if case .apiUnavailable = error { return }
            XCTFail("Unexpected error \(error)")
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }
}
