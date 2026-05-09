//
//  DrugInteraction.swift
//  Drug Interaction Checker
//

import Foundation

/// A single drug–drug interaction row suitable for UI and tests.
struct DrugInteraction: Identifiable, Equatable, Hashable {
    let id: UUID
    var drug1Name: String
    var drug2Name: String
    /// Verbatim clinical interaction text from the data source (when available).
    var clinicalDescription: String
    /// Short, patient-facing guidance derived from the source text for this POC.
    var recommendation: String
    var severity: InteractionSeverity

    init(
        id: UUID = UUID(),
        drug1Name: String,
        drug2Name: String,
        clinicalDescription: String,
        recommendation: String? = nil,
        severity: InteractionSeverity
    ) {
        self.id = id
        self.drug1Name = drug1Name
        self.drug2Name = drug2Name
        self.clinicalDescription = clinicalDescription
        self.recommendation = recommendation ?? Self.defaultRecommendation(from: clinicalDescription, severity: severity)
        self.severity = severity
    }

    private static func defaultRecommendation(from description: String, severity: InteractionSeverity) -> String {
        let trimmed = description.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "Discuss this combination with a qualified clinician or pharmacist before making changes."
        }
        switch severity {
        case .high:
            return "Potential high-risk combination—seek professional advice promptly. Source note: \(trimmed)"
        case .moderate, .low, .unknown:
            return "Review this combination with a qualified clinician or pharmacist. Source note: \(trimmed)"
        }
    }
}
