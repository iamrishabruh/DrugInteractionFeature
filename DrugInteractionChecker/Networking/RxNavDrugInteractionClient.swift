//
//  RxNavDrugInteractionClient.swift
//  Drug Interaction Checker
//
//  Live client for NIH RxNav REST endpoints. Public APIs may change or be retired; treat as best-effort.
//

import Foundation

final class RxNavDrugInteractionClient: DrugInteractionAPIClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func resolveMedications(names: [String]) async throws -> [Medication] {
        var medications: [Medication] = []
        for name in names {
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            var components = URLComponents(string: "https://rxnav.nlm.nih.gov/REST/rxcui.json")!
            components.queryItems = [URLQueryItem(name: "name", value: trimmed)]

            guard let url = components.url else {
                throw DrugInteractionError.networkFailure(message: "Invalid RxCUI lookup URL.")
            }

            let data: Data
            let response: URLResponse
            do {
                (data, response) = try await session.data(from: url)
            } catch let urlError as URLError {
                throw DrugInteractionError.networkFailure(message: urlError.localizedDescription)
            } catch {
                throw DrugInteractionError.networkFailure(message: error.localizedDescription)
            }

            try validateHTTP(response: response, data: data)

            let rxcui = try? RxNavResponseParser.parseRxCUI(from: data)
            medications.append(Medication(name: trimmed, rxcui: rxcui))
        }
        return medications
    }

    func fetchInteractions(forRxCUIs rxcuis: [String]) async throws -> [DrugInteraction] {
        guard !rxcuis.isEmpty else { return [] }

        var components = URLComponents(string: "https://rxnav.nlm.nih.gov/REST/interaction/list.json")!
        components.queryItems = [URLQueryItem(name: "rxcuis", value: rxcuis.joined(separator: "+"))]

        guard let url = components.url else {
            throw DrugInteractionError.networkFailure(message: "Invalid interaction list URL.")
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch let urlError as URLError {
            throw DrugInteractionError.networkFailure(message: urlError.localizedDescription)
        } catch {
            throw DrugInteractionError.networkFailure(message: error.localizedDescription)
        }

        try validateHTTP(response: response, data: data)

        do {
            return try RxNavResponseParser.parseInteractions(from: data)
        } catch {
            throw DrugInteractionError.apiUnavailable(message: "Unexpected interaction response format.")
        }
    }

    private func validateHTTP(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw DrugInteractionError.networkFailure(message: "Missing HTTP response.")
        }

        switch http.statusCode {
        case 200..<300:
            return
        case 404, 410:
            throw DrugInteractionError.apiUnavailable(message: "HTTP \(http.statusCode) — endpoint not found or removed.")
        case 429:
            throw DrugInteractionError.apiUnavailable(message: "HTTP 429 — rate limited.")
        default:
            let snippet = String(data: data, encoding: .utf8).map { String($0.prefix(120)) }
            throw DrugInteractionError.networkFailure(message: "HTTP \(http.statusCode). \(snippet ?? "")")
        }
    }
}
