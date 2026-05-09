//
//  DrugInteractionViewModelTests.swift
//  DrugInteractionCheckerTests
//

import XCTest
@testable import DrugInteractionChecker

@MainActor
final class DrugInteractionViewModelTests: XCTestCase {
    func testEmptyListProducesError() async {
        let vm = DrugInteractionViewModel(client: MockDrugInteractionClient())
        await vm.loadInteractions()

        guard case .failed(let error) = vm.phase else {
            return XCTFail("Expected failure, got \(vm.phase)")
        }
        XCTAssertEqual(error, .emptyMedicationList)
    }

    func testHappyPathLoadsInteractions() async {
        let vm = DrugInteractionViewModel(client: MockDrugInteractionClient())
        vm.addMedication(name: "aspirin")
        vm.addMedication(name: "warfarin")

        await vm.loadInteractions()

        guard case .loaded(let rows) = vm.phase else {
            return XCTFail("Expected loaded, got \(vm.phase)")
        }
        XCTAssertFalse(rows.isEmpty)
    }

    func testUnknownDrugFails() async {
        let vm = DrugInteractionViewModel(client: MockDrugInteractionClient())
        vm.addMedication(name: "totally-unknown-medication")

        await vm.loadInteractions()

        guard case .failed(let error) = vm.phase else {
            return XCTFail("Expected failure, got \(vm.phase)")
        }
        guard case .unknownDrugs(let names) = error else {
            return XCTFail("Expected unknownDrugs, got \(error)")
        }
        XCTAssertTrue(names.contains("totally-unknown-medication"))
    }

    func testAcknowledgeErrorClearsFailure() async {
        let vm = DrugInteractionViewModel(client: MockDrugInteractionClient())
        await vm.loadInteractions()
        XCTAssertTrue({
            if case .failed = vm.phase { return true }
            return false
        }())

        vm.acknowledgeError()
        XCTAssertEqual(vm.phase, .idle)
    }

    func testNetworkFailureMapsThroughViewModel() async {
        let client = MockDrugInteractionClient()
        client.mode = .networkFailure
        let vm = DrugInteractionViewModel(client: client)
        vm.addMedication(name: "aspirin")

        await vm.loadInteractions()

        guard case .failed(let error) = vm.phase else {
            return XCTFail("Expected failure, got \(vm.phase)")
        }
        guard case .networkFailure = error else {
            return XCTFail("Expected networkFailure, got \(error)")
        }
    }
}
