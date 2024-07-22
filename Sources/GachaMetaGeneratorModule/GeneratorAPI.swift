// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

import Foundation

// MARK: - GachaMetaDB

public enum GachaMetaDB {}

extension GachaMetaDB {
    public typealias CompilationResult = [String: GachaItemMeta]

    public static func fetchAndCompile(
        for game: SupportedGame, lang: [GachaDictLang]? = nil
    ) async throws
        -> CompilationResult {
        var lang = lang ?? []
        if lang.isEmpty {
            lang = GachaDictLang.allCases(for: game)
        }

        // MARK: Collecting Items from ExcelConfigData.

        let items = try await withThrowingTaskGroup(
            of: [GachaItemMeta].self, returning: [GachaItemMeta].self
        ) { taskGroup in
            taskGroup.addTask { try await game.fetchExcelConfigData(for: .characterData) }
            taskGroup.addTask { try await game.fetchExcelConfigData(for: .weaponData) }
            var images = [GachaItemMeta]()
            for try await result in taskGroup {
                images.append(contentsOf: result)
            }
            return images
        }

        // MARK: Get Raw Translation Data for Matched Languages.

        let neededHashIDs = Set<String>(items.map(\.nameTextMapHash.description))
        let dictAll = try await game.fetchRawLangData(lang: lang, neededHashIDs: neededHashIDs)

        // MARK: Apply translations.

        items.forEach { currentItem in
            GachaDictLang.allCases.forEach { localeID in
                let hashKey = currentItem.nameTextMapHash.description
                guard let dict = dictAll[localeID.langID]?[hashKey] else { return }
                if currentItem.l10nMap == nil { currentItem.l10nMap = [:] }
                currentItem.l10nMap?[localeID.langID] = dict
            }
        }

        // MARK: Prepare Dictionary.

        var dict: [String: GachaItemMeta] = [:]

        items.forEach { item in
            if game == .genshinImpact {
                // Filtering test roles of Genshin Impact.
                guard item.id < 11_000_000 else { return }
            }
            guard let desc = item.l10nMap?.description else { return }
            guard !desc.contains("测试") else { return }
            let key = item.id.description
            if let matchedProtagonist = Protagonist(against: item) {
                item.l10nMap = matchedProtagonist.nameTranslationDict
            }
            dict[key] = item
        }

        return dict
    }
}
