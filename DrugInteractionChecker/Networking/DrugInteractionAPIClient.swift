//
//  DrugInteractionAPIClient.swift
//  Drug Interaction Checker
//

import Foundation

/// Abstraction over medication resolution and interaction retrieval for tests and runtime swapping.
protocol DrugInteractionAPIClient: AnyObject {
    func resolveMedications(names: [String]) async throws -> [Medication]
    func fetchInteractions(forRxCUIs rxcuis: [String]) async throws -> [DrugInteraction]
}
