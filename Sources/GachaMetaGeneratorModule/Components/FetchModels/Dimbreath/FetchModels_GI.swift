// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

import Foundation

extension GachaMetaGenerator {
    class GenshinRawItem: Codable {
        // MARK: Lifecycle

        init(id: Int, rank: Int, nameTextMapHash: UInt) {
            self.id = id
            self.rankLevel = rank
            self.nameTextMapHash = nameTextMapHash
        }

        required init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys505.self)
            self.id = try (
                container.decodeIfPresent(Int.self, forKey: .idCharacter)
                    ?? container.decode(Int.self, forKey: .idWeapon)
            )
            let maybeRankLevel: Int? = try? container.decode(Int.self, forKey: .rankLevel)
            let maybeQualityType = try? container.decodeIfPresent(GIQualityType.self, forKey: .qualityType)
            if let maybeQualityType {
                self.rankLevel = maybeQualityType.asRankLevel
            } else {
                self.rankLevel = maybeRankLevel ?? 0
            }
            self.qualityType = try container.decodeIfPresent(GIQualityType.self, forKey: .qualityType)
            self.nameTextMapHash = try container.decode(UInt.self, forKey: .nameTextMapHash)
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

        enum CodingKeys505: String, CodingKey {
            case idWeapon = "DGMGGMHAGOA"
            case idCharacter = "ELKKIAIGOBK"
            case rankLevel = "IMNCLIODOBL"
            case nameTextMapHash = "DNINKKHEILA"
            case qualityType = "ADLDGBEKECJ"
        }

        let id: Int
        let rankLevel: Int
        let nameTextMapHash: UInt
        var l10nMap: [String: String]?

        var isCharacter: Bool {
            id > 114514
        }

        var isValid: Bool {
            guard !Self.forbiddenNameTextMapHashes.contains(nameTextMapHash) else { return false }
            if isCharacter {
                guard id.description.prefix(2) != "11" else { return false }
                guard id < 10000900 else { return false }
                return true
            } else {
                return true // Temporarily assume that all weapons are vaid.
            }
        }

        func toGachaItemMeta() -> GachaMetaGenerator.GachaItemMeta {
            .init(id: id, rank: rankLevel, nameTextMapHash: nameTextMapHash)
        }

        // MARK: Fileprivate

        /// This variable is only useful during decoding process.
        fileprivate var qualityType: GIQualityType?

        // MARK: Private

        private static let forbiddenNameTextMapHashes: [UInt] = [
            1499745907, 1538092267, 3464027035, 594850707,
            231836963, 3780343147, 1516554699, 977648923,
            2597527627, 500612819, 3532343811, 302691299,
            452043283, 2242027395, 565329475, 1994081075,
            2824690859, 1857915418, 3293134650, 853394138,
        ]
    }
}
