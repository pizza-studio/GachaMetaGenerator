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
}
