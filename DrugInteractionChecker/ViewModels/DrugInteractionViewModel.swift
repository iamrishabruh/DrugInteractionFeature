//
//  DrugInteractionViewModel.swift
//  Drug Interaction Checker
//

import Foundation

@MainActor
final class DrugInteractionViewModel: ObservableObject {
    enum Phase: Equatable {
        case idle
        case loading
        case loaded([DrugInteraction])
        case failed(DrugInteractionError)
    }

    @Published private(set) var medicationNames: [String] = []
    @Published private(set) var phase: Phase = .idle

    private let client: DrugInteractionAPIClient

    init(client: DrugInteractionAPIClient) {
        self.client = client
    }

    /// Chooses the networking implementation. Defaults to the mock client so the POC runs without live RxNav.
    static func makeClient() -> DrugInteractionAPIClient {
        if ProcessInfo.processInfo.environment["USE_LIVE_RXNAV"] == "1" {
            return RxNavDrugInteractionClient()
        }
        return MockDrugInteractionClient()
    }

    func addMedication(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        medicationNames.append(trimmed)
        phase = .idle
    }

    func removeMedication(named name: String) {
        medicationNames.removeAll { $0 == name }
        phase = .idle
    }

    func loadInteractions() async {
        if medicationNames.isEmpty {
            phase = .failed(.emptyMedicationList)
            return
        }

        phase = .loading

        do {
            let resolved = try await client.resolveMedications(names: medicationNames)
            let unknown = resolved.filter { $0.rxcui == nil }.map(\.name)
            if !unknown.isEmpty {
                phase = .failed(.unknownDrugs(unknown))
                return
            }

            let rxcuis = resolved.compactMap(\.rxcui)
            let rows = try await client.fetchInteractions(forRxCUIs: rxcuis)
            phase = .loaded(Self.sortBySeverity(rows))
        } catch let drugError as DrugInteractionError {
            phase = .failed(drugError)
        } catch {
            phase = .failed(.networkFailure(message: error.localizedDescription))
        }
    }

    func acknowledgeError() {
        if case .failed = phase {
            phase = .idle
        }
    }

    nonisolated static func sortBySeverity(_ interactions: [DrugInteraction]) -> [DrugInteraction] {
        interactions.sorted { lhs, rhs in
            if lhs.severity != rhs.severity {
                return lhs.severity < rhs.severity
            }
            let a = lhs.drug1Name.localizedCaseInsensitiveCompare(rhs.drug1Name)
            if a != .orderedSame { return a == .orderedAscending }
            return lhs.drug2Name.localizedCaseInsensitiveCompare(rhs.drug2Name) == .orderedAscending
        }
    }
}
