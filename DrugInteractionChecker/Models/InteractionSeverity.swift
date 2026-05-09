//
//  InteractionSeverity.swift
//  Drug Interaction Checker
//

import Foundation

/// Normalized interaction severity for sorting and presentation.
enum InteractionSeverity: String, CaseIterable, Equatable, Comparable, Codable {
    case high
    case moderate
    case low
    case unknown

    /// Sort order where lower means higher clinical emphasis (shown first when ascending by `sortRank`).
    var sortRank: Int {
        switch self {
        case .high: return 0
        case .moderate: return 1
        case .low: return 2
        case .unknown: return 3
        }
    }

    static func < (lhs: InteractionSeverity, rhs: InteractionSeverity) -> Bool {
        lhs.sortRank < rhs.sortRank
    }

    /// Maps RxNav interaction payload strings (often lowercased) into a normalized severity.
    static func from(apiValue: String) -> InteractionSeverity {
        let normalized = apiValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch normalized {
        case "high": return .high
        case "moderate": return .moderate
        case "low": return .low
        case "n/a", "na", "": return .unknown
        default: return .unknown
        }
    }
}
