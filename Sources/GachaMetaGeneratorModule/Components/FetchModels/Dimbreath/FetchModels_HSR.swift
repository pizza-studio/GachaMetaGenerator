// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

import Foundation

// StarRail has dedicated structs for decoding fetched contents.

extension GachaMetaGenerator {
    struct NameHashUnit: Codable {
        enum CodingKeys: String, CodingKey {
            case hash = "Hash"
        }

        let hash: Int
    }

    /// Starrail only.
    public class HSRAvatarRawItem: Codable, RawItemFetchModelProtocol {
        // MARK: Lifecycle

        public required init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: .id)
            self.nameTextMapHash = (try container.decode(NameHashUnit.self, forKey: .nameTextMapHash)).hash
            let rawRarityText = try container.decode(String.self, forKey: .rarity)
            self.rarity = Int(rawRarityText.last?.description ?? "3") ?? 3
            self.rankIDList = try container.decode([Int].self, forKey: .rankIDList)
            self.skillList = try container.decode([Int].self, forKey: .skillList)
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case id = "AvatarID"
            case nameTextMapHash = "AvatarName"
            case rarity = "Rarity"
            case rankIDList = "RankIDList"
            case skillList = "SkillList"
        }

        public let id: Int
        public let nameTextMapHash: Int
        public let rarity: Int
        public let rankIDList: [Int]
        public let skillList: [Int]

        public var isValid: Bool {
            switch id {
            case 6000 ..< 8000, 8900...: return false
            default: break
            }
            let wrongRankIDs = rankIDList.filter {
                (700000 ..< 800000).contains($0)
            }
            guard wrongRankIDs.isEmpty else { return false }

            let wrongSkills = skillList.filter {
                (7000000 ..< 8000000).contains($0)
            }
            guard wrongSkills.isEmpty else { return false }
            return true
        }
    }

    /// Starrail only.
    public class HSRWeaponRawItem: Codable, RawItemFetchModelProtocol {
        // MARK: Lifecycle

        public required init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: .id)
            self.nameTextMapHash = (try container.decode(NameHashUnit.self, forKey: .nameTextMapHash)).hash
            let rawRarityText = try container.decode(String.self, forKey: .rarity)
            self.rarity = Int(rawRarityText.last?.description ?? "3") ?? 3
            self.skillID = try container.decode(Int.self, forKey: .skillID)
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case id = "EquipmentID"
            case nameTextMapHash = "EquipmentName"
            case rarity = "Rarity"
            case skillID = "SkillID"
        }

        public let id: Int
        public let nameTextMapHash: Int
        public let rarity: Int
        public let skillID: Int

        public var isValid: Bool {
            switch skillID {
            case 7000000 ..< 8000000: false
            default: true
            }
        }
    }
}

// MARK: - RawItemFetchModelProtocol

protocol RawItemFetchModelProtocol {
    var id: Int { get }
    var nameTextMapHash: Int { get }
    var rarity: Int { get }
}

extension RawItemFetchModelProtocol {
    func toGachaItemMeta() -> GachaMetaGenerator.GachaItemMeta {
        .init(id: id, rank: rarity, nameTextMapHash: nameTextMapHash)
    }
}
