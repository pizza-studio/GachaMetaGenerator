// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

import Foundation

extension GachaMetaGenerator {
    class GenshinRawItem: Codable {
        // MARK: Lifecycle

        init(id: Int, rank: Int, nameTextMapHash: Int) {
            self.id = id
            self.rankLevel = rank
            self.nameTextMapHash = nameTextMapHash
        }

        required init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: .id)
            let maybeRankLevel: Int? = try? container.decode(Int.self, forKey: .rankLevel)
            let maybeQualityType = try? container.decodeIfPresent(GIQualityType.self, forKey: .qualityType)
            if let maybeQualityType {
                self.rankLevel = maybeQualityType.asRankLevel
            } else {
                self.rankLevel = maybeRankLevel ?? 0
            }
            self.qualityType = try container.decodeIfPresent(GIQualityType.self, forKey: .qualityType)
            self.nameTextMapHash = try container.decode(Int.self, forKey: .nameTextMapHash)
            self.l10nMap = (try? container.decode([String: String].self, forKey: .l10nMap))
        }

        // MARK: Internal

        enum GIQualityType: String, Codable {
            case v5sp = "QUALITY_ORANGE_SP"
            case v5 = "QUALITY_ORANGE"
            case v4 = "QUALITY_PURPLE"
            case v3 = "QUALITY_BLUE"
            case v2 = "QUALITY_GREEN"
            case v1 = "QUALITY_GRAY"

            // MARK: Internal

            var asRankLevel: Int {
                switch self {
                case .v5, .v5sp: return 5
                case .v4: return 4
                case .v3: return 3
                case .v2: return 2
                case .v1: return 1
                }
            }
        }

        let id: Int
        let rankLevel: Int
        let nameTextMapHash: Int
        var l10nMap: [String: String]?

        func isCharacter(for game: SupportedGame) -> Bool {
            switch game {
            case .genshinImpact: return id > 114514
            case .starRail: return id <= 9999
            }
        }

        func toGachaItemMeta() -> GachaMetaGenerator.GachaItemMeta {
            .init(id: id, rank: rankLevel, nameTextMapHash: nameTextMapHash)
        }

        // MARK: Fileprivate

        /// This variable is only useful during decoding process.
        fileprivate var qualityType: GIQualityType?
    }
}
