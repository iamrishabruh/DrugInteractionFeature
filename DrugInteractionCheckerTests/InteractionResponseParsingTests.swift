//
//  InteractionResponseParsingTests.swift
//  DrugInteractionCheckerTests
//

import XCTest
@testable import DrugInteractionChecker

final class InteractionResponseParsingTests: XCTestCase {
    func testParseRxCUI_extractsFirstIdentifier() throws {
        let json = """
        {"idGroup":{"rxnormId":["1191","1192"]}}
        """
        let rxcui = try RxNavResponseParser.parseRxCUI(from: Data(json.utf8))
        XCTAssertEqual(rxcui, "1191")
    }

    func testParseRxCUI_returnsNilWhenMissing() throws {
        let json = """
        {"idGroup":{}}
        """
        let rxcui = try RxNavResponseParser.parseRxCUI(from: Data(json.utf8))
        XCTAssertNil(rxcui)
    }

    func testParseInteractions_mapsPairsAndSeverity() throws {
        let json = """
        {
          "fullInteractionTypeGroup": [
            {
              "fullInteractionType": [
                {
                  "minConcept": [
                    { "name": "warfarin" },
                    { "name": "aspirin" }
                  ],
                  "interactionPair": [
                    {
                      "severity": "high",
                      "description": "Increased bleeding risk."
                    }
                  ]
                }
              ]
            }
          ]
        }
        """

        let rows = try RxNavResponseParser.parseInteractions(from: Data(json.utf8))
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].drug1Name, "warfarin")
        XCTAssertEqual(rows[0].drug2Name, "aspirin")
        XCTAssertEqual(rows[0].severity, .high)
        XCTAssertEqual(rows[0].clinicalDescription, "Increased bleeding risk.")
    }

    func testParseInteractions_returnsEmptyWhenKeyMissing() throws {
        let json = "{}"
        let rows = try RxNavResponseParser.parseInteractions(from: Data(json.utf8))
        XCTAssertTrue(rows.isEmpty)
    }
}
