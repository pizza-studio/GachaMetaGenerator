// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

import Foundation

extension GachaMetaDB {
    public enum GachaDictLang: String, CaseIterable, Sendable, Identifiable {
        case langCHS
        case langCHT
        case langDE
        case langEN
        case langES
        case langFR
        case langID
        case langIT
        case langJP
        case langKR
        case langPT
        case langRU
        case langTH
        case langTR
        case langVI

        // MARK: Public

        public var id: String { langID }

        public var langID: String {
            switch self {
            case .langCHS: "zh-cn"
            case .langCHT: "zh-tw"
            case .langDE: "de-de"
            case .langEN: "en-us"
            case .langES: "es-es"
            case .langFR: "fr-fr"
            case .langID: "id-id"
            case .langIT: "it-it"
            case .langJP: "ja-jp"
            case .langKR: "ko-kr"
            case .langPT: "pt-pt"
            case .langRU: "ru-ru"
            case .langTH: "th-th"
            case .langTR: "tr-tr"
            case .langVI: "vi-vn"
            }
        }

        public static func allCases(for game: GachaMetaDB.SupportedGame) -> [Self] {
            switch game {
            case .genshinImpact: return casesForGenshin
            case .starRail: return casesForHSR
            }
        }

        // MARK: Internal

        var filename: String {
            rawValue.replacingOccurrences(of: "lang", with: "TextMap").appending(".json")
        }

        // MARK: Private

        private static let casesForGenshin: [Self] = Self.allCases

        private static let casesForHSR: [Self] = Self.allCases.filter {
            ![Self.langIT, Self.langTR].contains($0)
        }
    }
}
