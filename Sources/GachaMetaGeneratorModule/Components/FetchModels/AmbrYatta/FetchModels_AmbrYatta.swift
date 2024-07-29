// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

import Foundation

extension GachaMetaGenerator {
    typealias AmbrYattaFetchedItem = AmbrYattaResponse.FetchedModel.FetchedItem

    struct AmbrYattaResponse: Codable {
        struct FetchedModel: Codable {
            /// We use this shared struct for both sides
            /// since only these 3 fields are useful in this project.
            struct FetchedItem: Codable {
                // MARK: Lifecycle

                init(from decoder: any Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    if var idStr = (try? container.decode(String.self, forKey: CodingKeys.id)) {
                        while Int(idStr) == nil {
                            idStr = idStr.dropLast(1).description
                        }
                        if let newID = Int(idStr) {
                            self.id = newID
                        } else {
                            throw DecodingError.valueNotFound(
                                Int.self,
                                .init(
                                    codingPath: [CodingKeys.id],
                                    debugDescription: "Cannot extract values from the discovered string."
                                )
                            )
                        }
                    } else {
                        self.id = (try? container.decode(Int.self, forKey: CodingKeys.id)) ?? -1145141919810
                    }
                    self.rank = try container.decode(Int.self, forKey: CodingKeys.rank)
                    self.nameTextMapHash = nil
                    let integerName = try? container.decodeIfPresent(Int.self, forKey: CodingKeys.name)
                    if let integerName {
                        self.nameTextMapHash = integerName
                        self.name = integerName.description
                    } else {
                        self.name = try container.decode(String.self, forKey: CodingKeys.name)
                    }
                }

                // MARK: Internal

                let id: Int
                let rank: Int
                var name: String
                var nameTextMapHash: Int?

                var isValid: Bool { id != -1145141919810 }
            }

            let items: [String: FetchedItem]?
        }

        let response: Int
        let data: FetchedModel?
    }
}

extension GachaMetaGenerator.AmbrYattaResponse {
    var items: [GachaMetaGenerator.AmbrYattaFetchedItem] {
        Array((data?.items ?? [:]).values).sorted {
            $0.id < $1.id
        }
    }
}

extension GachaMetaGenerator.AmbrYattaFetchedItem {
    func toGachaItemMeta() -> GachaMetaGenerator.GachaItemMeta {
        .init(id: id, rank: rank, nameTextMapHash: nameTextMapHash ?? -114514)
    }
}

extension [GachaMetaGenerator.GachaDictLang?: [GachaMetaGenerator.AmbrYattaFetchedItem]] {
    /// 这里假设所有语言下的 FetchedItem 都是雷同的，且必须有 static 的查询结果。
    func assemble() -> [GachaMetaGenerator.GachaItemMeta]? {
        guard let staticStack = self[nil] else { return nil }
        var result = [GachaMetaGenerator.GachaItemMeta]()
        staticStack.enumerated().forEach { theIndex, _ in
            let staticEntry = staticStack[theIndex]
            guard let nameHash = staticEntry.nameTextMapHash else { return }
            var newEntry = GachaMetaGenerator.GachaItemMeta(
                id: staticEntry.id, rank: staticEntry.rank, nameTextMapHash: nameHash
            )
            newEntry.l10nMap = [:]
            GachaMetaGenerator.GachaDictLang.allCases.forEach { lang in
                guard let matchedLocalizedRawStack = self[lang] else { return }
                let matchedLocalizedRawItem = matchedLocalizedRawStack[theIndex]
                newEntry.l10nMap?[lang.langTag] = matchedLocalizedRawItem.name
            }
            if let matchedProtagonist = GachaMetaGenerator.Protagonist(rawValue: staticEntry.id) {
                newEntry.l10nMap = matchedProtagonist.nameTranslationDict
            }
            result.append(newEntry)
        }
        return result
    }
}
