//
//  Medication.swift
//  Drug Interaction Checker
//

import Foundation

/// A medication the user entered, optionally resolved to an RxNorm concept id (RxCUI).
struct Medication: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    /// RxNorm identifier when resolution succeeds; `nil` when the drug is unknown to the resolver.
    var rxcui: String?

    init(id: UUID = UUID(), name: String, rxcui: String? = nil) {
        self.id = id
        self.name = name
        self.rxcui = rxcui
    }
}
