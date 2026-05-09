//
//  DrugInteractionError.swift
//  Drug Interaction Checker
//

import Foundation

/// User-visible failure modes for the proof of concept.
enum DrugInteractionError: Equatable, LocalizedError {
    case emptyMedicationList
    case unknownDrugs([String])
    case networkFailure(message: String?)
    case apiUnavailable(message: String)

    var errorDescription: String? {
        switch self {
        case .emptyMedicationList:
            return "Add at least one medication before checking for interactions."
        case .unknownDrugs(let names):
            let list = names.joined(separator: ", ")
            return "These medications could not be matched in the drug directory: \(list). Try standard generic names (for example “aspirin”)."
        case .networkFailure(let message):
            if let message, !message.isEmpty {
                return "Network error: \(message)"
            }
            return "Could not reach the drug interaction service. Check your connection and try again."
        case .apiUnavailable(let message):
            return "The interaction service is unavailable or deprecated: \(message)"
        }
    }
}
