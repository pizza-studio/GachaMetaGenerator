// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

@testable import GachaMetaGeneratorModule
import XCTest

final class GachaMetaGeneratorTests: XCTestCase {
    func testURLGeneration() throws {
        GachaMetaGenerator.SupportedGame.allCases.forEach { game in
            GachaMetaGenerator.SupportedGame.DataURLType.allCases.forEach { dataType in
                print(game.getExcelConfigDataURL(for: dataType).absoluteString)
            }
            GachaMetaGenerator.GachaDictLang.allCases(for: game).forEach { lang in
                print(game.getLangDataURL(for: lang).absoluteString)
            }
        }
    }

    func testGeneratingHSR() async throws {
        let dict = try await GachaMetaGenerator.fetchAndCompile(for: .starRail)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        if let encoded = String(data: try encoder.encode(dict), encoding: .utf8) {
            print(encoded)
            NSLog("All Tasks Done.")
        } else {
            let errText = "!! Error on encoding JSON files."
            print("{\"errMsg\": \"\(errText)\"}\n")
            assertionFailure(errText)
            exit(1)
        }
    }

    func testGeneratingGI() async throws {
        let dict = try await GachaMetaGenerator.fetchAndCompile(for: .genshinImpact)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        if let encoded = String(data: try encoder.encode(dict), encoding: .utf8) {
            print(encoded)
            NSLog("All Tasks Done.")
        } else {
            let errText = "!! Error on encoding JSON files."
            print("{\"errMsg\": \"\(errText)\"}\n")
            assertionFailure(errText)
            exit(1)
        }
    }
}
