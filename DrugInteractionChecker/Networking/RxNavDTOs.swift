//
//  RxNavDTOs.swift
//  Drug Interaction Checker
//
//  Lightweight Codable shapes for RxNav JSON (subset used by this POC).
//

import Foundation

struct RxCUILookupResponseDTO: Decodable {
    struct IdGroup: Decodable {
        let rxnormId: [String]?
    }

    let idGroup: IdGroup?
}

struct InteractionListResponseDTO: Decodable {
    let fullInteractionTypeGroup: [FullInteractionTypeGroupDTO]?
}

struct FullInteractionTypeGroupDTO: Decodable {
    let fullInteractionType: [FullInteractionTypeDTO]?
}

struct FullInteractionTypeDTO: Decodable {
    let minConcept: [MinConceptDTO]?
    let interactionPair: [InteractionPairDTO]?
}

struct MinConceptDTO: Decodable {
    let name: String?
}

struct InteractionPairDTO: Decodable {
    let severity: String?
    let description: String?
}
