// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

import Foundation

extension GachaMetaGenerator {
    public enum Protagonist {
        // Male Protagonist in HSR
        case ofCaelus
        // Female Protagonist in HSR
        case ofStelle
        // Male Protagonist in Genshin Impact, a.k.a. Sora.
        case ofAether
        // Female Protagonist in Genshin Impact, a.k.a. Hotaru.
        case ofLumine

        // MARK: Lifecycle

        public init?(rawValue: Int) {
            switch rawValue {
            case 10000005: self = .ofAether
            case 10000007: self = .ofLumine
            case 8001 ... 9000:
                self = (rawValue % 2 == 0) ? .ofStelle : .ofCaelus
            default: return nil
            }
        }

        public init?(against target: GachaItemMeta) {
            // Genshin Impact Protagonist Scenario.
            if target.id > 114514, let genshinProtagonist = Self(rawValue: target.id) {
                self = genshinProtagonist
            }
            guard let map = target.l10nMap else { return nil }
            // The rest must be either HSR protagonist or nothing.
            guard map.description.contains(#"{NICKNAME}"#)
                || map.description.contains("Trailblazer")
            else { return nil }
            self = (target.id % 2 == 0) ? .ofStelle : .ofCaelus
        }

        // MARK: Public

        public var nameTranslationDict: [String: String] {
            switch self {
            case .ofCaelus: return [
                    "de-de": "Caelus",
                    "en-us": "Caelus",
                    "es-es": "Caelus",
                    "fr-fr": "Caelus",
                    "id-id": "Caelus",
                    "ja-jp": "穹",
                    "ko-kr": "카일루스",
                    "pt-pt": "Caelus",
                    "ru-ru": "Келус",
                    "th-th": "Caelus",
                    "vi-vn": "Caelus",
                    "zh-cn": "穹",
                    "zh-tw": "穹",
                ]
            case .ofStelle: return [
                    "de-de": "Stella",
                    "en-us": "Stelle",
                    "es-es": "Estela",
                    "fr-fr": "Stelle",
                    "id-id": "Stelle",
                    "ja-jp": "星",
                    "ko-kr": "스텔레",
                    "pt-pt": "Stelle",
                    "ru-ru": "Стелла",
                    "th-th": "Stelle",
                    "vi-vn": "Stelle",
                    "zh-cn": "星",
                    "zh-tw": "星",
                ]
            case .ofAether: return [
                    "de-de": "Aether",
                    "en-us": "Aether",
                    "es-es": "Éter",
                    "fr-fr": "Aether",
                    "id-id": "Aether",
                    "it-it": "Aether",
                    "ja-jp": "空",
                    "ko-kr": "아이테르",
                    "pt-pt": "Aether",
                    "ru-ru": "Итэр",
                    "th-th": "Aether",
                    "tr-tr": "Aether",
                    "vi-vn": "Aether",
                    "zh-cn": "空",
                    "zh-tw": "空",
                ]
            case .ofLumine: return [
                    "de-de": "Lumine",
                    "en-us": "Lumine",
                    "es-es": "Lumina",
                    "fr-fr": "Lumine",
                    "id-id": "Lumine",
                    "it-it": "Lumine",
                    "ja-jp": "蛍",
                    "ko-kr": "루미네",
                    "pt-pt": "Lumine",
                    "ru-ru": "Люмин",
                    "th-th": "Lumine",
                    "tr-tr": "Lumine",
                    "vi-vn": "Lumine",
                    "zh-cn": "荧",
                    "zh-tw": "熒",
                ]
            }
        }
    }
}
