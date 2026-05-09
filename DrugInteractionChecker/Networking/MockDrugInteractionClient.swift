//
//  MockDrugInteractionClient.swift
//  Drug Interaction Checker
//

import Foundation

/// Deterministic mock client so the SwiftUI POC runs without relying on live RxNav availability.
final class MockDrugInteractionClient: DrugInteractionAPIClient {
    enum Mode: Equatable {
        case success
        case networkFailure
        case apiUnavailable
    }

    var mode: Mode = .success

    /// Lowercased name → RxCUI
    private let directory: [String: String]

    /// Pairs of RxCUIs that should produce a mocked interaction.
    private let interactionMatrix: [String: [(other: String, interaction: DrugInteraction)]]

    init(
        directory: [String: String]? = nil,
        interactionMatrix: [String: [(other: String, interaction: DrugInteraction)]]? = nil
    ) {
        self.directory = directory ?? Self.defaultDirectory
        self.interactionMatrix = interactionMatrix ?? Self.defaultInteractionMatrix()
    }

    func resolveMedications(names: [String]) async throws -> [Medication] {
        switch mode {
        case .networkFailure:
            throw DrugInteractionError.networkFailure(message: "Mock network failure.")
        case .apiUnavailable:
            throw DrugInteractionError.apiUnavailable(message: "Mock service retirement.")
        case .success:
            break
        }

        return names.map { raw in
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            let key = trimmed.lowercased()
            let rxcui = directory[key]
            return Medication(name: trimmed.isEmpty ? raw : trimmed, rxcui: rxcui)
        }
        .filter { !$0.name.isEmpty }
    }

    func fetchInteractions(forRxCUIs rxcuis: [String]) async throws -> [DrugInteraction] {
        switch mode {
        case .networkFailure:
            throw DrugInteractionError.networkFailure(message: "Mock network failure.")
        case .apiUnavailable:
            throw DrugInteractionError.apiUnavailable(message: "Mock service retirement.")
        case .success:
            break
        }

        var results: [DrugInteraction] = []
        let unique = Array(Set(rxcuis))

        for a in unique {
            guard let neighbors = interactionMatrix[a] else { continue }
            for other in unique where other != a {
                if let match = neighbors.first(where: { $0.other == other }) {
                    results.append(match.interaction)
                }
            }
        }

        // De-dupe symmetric pairs by drug names + description
        var seen = Set<String>()
        return results.filter { row in
            let key = [row.drug1Name, row.drug2Name, row.clinicalDescription].joined(separator: "|").lowercased()
            if seen.contains(key) { return false }
            seen.insert(key)
            return true
        }
    }

    private static let defaultDirectory: [String: String] = [
        "aspirin": "1191",
        "warfarin": "855290",
        "ibuprofen": "5640",
        "acetaminophen": "161",
        "metformin": "860975",
        "lisinopril": "29046",
        "atorvastatin": "83367",
        "simvastatin": "36567",
        "omeprazole": "7646",
        "amlodipine": "17767",
    ]

    private static func defaultInteractionMatrix() -> [String: [(other: String, interaction: DrugInteraction)]] {
        let aspirinWarfarin = DrugInteraction(
            drug1Name: "Aspirin",
            drug2Name: "Warfarin",
            clinicalDescription: "Combined use may increase bleeding risk.",
            recommendation: "Ask a clinician or pharmacist before combining these medications; watch for bleeding signs.",
            severity: .high
        )

        let ibuprofenLisinopril = DrugInteraction(
            drug1Name: "Ibuprofen",
            drug2Name: "Lisinopril",
            clinicalDescription: "NSAIDs may reduce antihypertensive effect and affect kidney function.",
            recommendation: "Discuss pain control options with a clinician if you take both medicines.",
            severity: .moderate
        )

        return [
            "1191": [("855290", aspirinWarfarin)],
            "855290": [("1191", aspirinWarfarin)],
            "5640": [("29046", ibuprofenLisinopril)],
            "29046": [("5640", ibuprofenLisinopril)],
        ]
    }
}
