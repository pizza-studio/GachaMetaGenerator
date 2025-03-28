// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

@testable import GachaMetaGeneratorModule
import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - GachaMetaGeneratorTests

final class GachaMetaGeneratorTests: XCTestCase {
    func testURLGenerationForDimbreathRepos() throws {
        GachaMetaGenerator.SupportedGame.allCases.forEach { game in
            GachaMetaGenerator.SupportedGame.DataURLType.allCases.forEach { dataType in
                print(game.getExcelConfigDataURL(for: dataType).absoluteString)
            }
            GachaMetaGenerator.GachaDictLang.allCases(for: game).forEach { lang in
                print(game.getLangDataURLs(for: lang).map(\.absoluteString))
            }
        }
    }

    func testGeneratingHSRFromDimbreathRepos() async throws {
        let dict = try await GachaMetaGenerator.fetchAndCompileFromDimbreath(for: .starRail)
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

    func testGeneratingGIFromDimbreathRepos() async throws {
        let dict = try await GachaMetaGenerator.fetchAndCompileFromDimbreath(for: .genshinImpact)
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

// MARK: - Ambr Yatta API Tests.

extension GachaMetaGeneratorTests {
    func testGeneratingHSRFromYattaAPI() async throws {
        let dataHSR = try await GachaMetaGenerator.fetchAndCompileFromYatta(for: .starRail)
        print(try dataHSR.encodedJSONString() ?? "FAILED.")
        XCTAssertNotNil(!dataHSR.isEmpty)
    }

    func testGeneratingGIFromYattaAPI() async throws {
        let dataGI = try await GachaMetaGenerator.SupportedGame.genshinImpact.fetchYattaData()
        print(try dataGI.encodedJSONString() ?? "FAILED.")
        XCTAssertNotNil(!dataGI.isEmpty)
    }

    func testDecodingYattaData() async throws {
        for game in GachaMetaGenerator.SupportedGame.allCases {
            for dataType in GachaMetaGenerator.SupportedGame.DataURLType.allCases {
                for lang in GachaMetaGenerator.GachaDictLang?.allCases(for: game) {
                    print("------------------------------------")
                    let url = game.getYattaAPIURL(for: dataType, lang: lang)
                    print(url.absoluteString)
                    let (data, _) = try await URLSession.shared.asyncData(from: url)
                    do {
                        let jsonParsed = try JSONDecoder().decode(GachaMetaGenerator.YattaResponse.self, from: data)
                        XCTAssertFalse(jsonParsed.data?.items?.isEmpty ?? true)
                    } catch {
                        print(error.localizedDescription)
                        print(String(data: data, encoding: .utf8)!)
                    }
                }
            }
        }
    }
}

extension Encodable {
    func encodedJSONString() throws -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        return String(data: try encoder.encode(self), encoding: .utf8)
    }
}
