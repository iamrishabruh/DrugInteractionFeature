//
//  RxNavResponseParser.swift
//  Drug Interaction Checker
//

import Foundation

enum RxNavResponseParser {
    static func parseRxCUI(from data: Data) throws -> String? {
        let decoded = try JSONDecoder().decode(RxCUILookupResponseDTO.self, from: data)
        return decoded.idGroup?.rxnormId?.first
    }

    static func parseInteractions(from data: Data) throws -> [DrugInteraction] {
        let decoded = try JSONDecoder().decode(InteractionListResponseDTO.self, from: data)
        guard let groups = decoded.fullInteractionTypeGroup else {
            return []
        }

        var results: [DrugInteraction] = []
        for group in groups {
            guard let types = group.fullInteractionType else { continue }
            for interaction in types {
                guard let concepts = interaction.minConcept, concepts.count >= 2 else { continue }
                let drug1 = concepts[0].name ?? "Unknown"
                let drug2 = concepts[1].name ?? "Unknown"
                guard let pair = interaction.interactionPair?.first else { continue }
                let severityString = pair.severity ?? "N/A"
                let description = pair.description ?? ""
                let severity = InteractionSeverity.from(apiValue: severityString)
                results.append(
                    DrugInteraction(
                        drug1Name: drug1,
                        drug2Name: drug2,
                        clinicalDescription: description,
                        severity: severity
                    )
                )
            }
        }
        return results
    }
}
