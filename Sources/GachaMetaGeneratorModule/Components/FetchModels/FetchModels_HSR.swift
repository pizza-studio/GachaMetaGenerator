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
    public class AvatarRawItem: Codable, RawItemFetchModelProtocol {
        // MARK: Lifecycle

        public required init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: .id)
            self.nameTextMapHash = (try container.decode(NameHashUnit.self, forKey: .nameTextMapHash)).hash
            let rawRarityText = try container.decode(String.self, forKey: .rarity)
            self.rarity = Int(rawRarityText.last?.description ?? "3") ?? 3
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case id = "AvatarID"
            case nameTextMapHash = "AvatarName"
            case rarity = "Rarity"
        }

        public let id: Int
        public let nameTextMapHash: Int
        public let rarity: Int
    }

    /// Starrail only.
    public class WeaponRawItem: Codable, RawItemFetchModelProtocol {
        // MARK: Lifecycle

        public required init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: .id)
            self.nameTextMapHash = (try container.decode(NameHashUnit.self, forKey: .nameTextMapHash)).hash
            let rawRarityText = try container.decode(String.self, forKey: .rarity)
            self.rarity = Int(rawRarityText.last?.description ?? "3") ?? 3
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case id = "EquipmentID"
            case nameTextMapHash = "EquipmentName"
            case rarity = "Rarity"
        }

        public let id: Int
        public let nameTextMapHash: Int
        public let rarity: Int
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
