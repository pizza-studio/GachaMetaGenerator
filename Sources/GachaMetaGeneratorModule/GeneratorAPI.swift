// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

import Foundation

// MARK: - GachaMetaGenerator

public enum GachaMetaGenerator {}

extension GachaMetaGenerator {
    public typealias CompilationResult = [String: GachaItemMeta]

    public static func fetchAndCompileFromAmbrYatta(
        for game: SupportedGame, lang: [GachaDictLang?]? = nil
    ) async throws
        -> CompilationResult {
        var lang = lang ?? []
        if lang.isEmpty {
            lang = GachaDictLang?.allCases(for: game)
        }
        if !lang.contains(nil) {
            lang.append(nil)
        }

        var result = CompilationResult()
        try await game.fetchAmbrYattaData(lang: lang).forEach {
            result[$0.id.description] = $0
        }
        return result
    }

    public static func fetchAndCompileFromDimbreath(
        for game: SupportedGame, lang: [GachaDictLang]? = nil
    ) async throws
        -> CompilationResult {
        var lang = lang ?? []
        if lang.isEmpty {
            lang = GachaDictLang.allCases(for: game)
        }

        // MARK: Collecting Items from ExcelConfigData.

        var items = try await withThrowingTaskGroup(
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

        for theIndex in 0 ..< items.count {
            var currentItem = items[theIndex]
            GachaDictLang.allCases.forEach { localeID in
                let hashKey = currentItem.nameTextMapHash.description
                guard let dict = dictAll[localeID.langTag]?[hashKey] else { return }
                if currentItem.l10nMap == nil { currentItem.l10nMap = [:] }
                currentItem.l10nMap?[localeID.langTag] = dict
                if let matchedProtagonist = Protagonist(rawValue: currentItem.id) {
                    currentItem.l10nMap = matchedProtagonist.nameTranslationDict
                }
                items[theIndex] = currentItem
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
            dict[key] = item
        }

        return dict
    }
}
