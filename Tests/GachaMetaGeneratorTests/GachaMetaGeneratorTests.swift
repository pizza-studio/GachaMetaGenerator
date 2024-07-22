@testable import GachaMetaGeneratorModule
import XCTest

final class GachaMetaGeneratorTests: XCTestCase {
    func testURLGeneration() throws {
        GachaMetaDB.SupportedGame.allCases.forEach { game in
            GachaMetaDB.SupportedGame.DataURLType.allCases.forEach { dataType in
                print(game.getExcelConfigDataURL(for: dataType).absoluteString)
            }
            GachaMetaDB.GachaDictLang.allCases(for: game).forEach { lang in
                print(game.getLangDataURL(for: lang).absoluteString)
            }
        }
    }
}
