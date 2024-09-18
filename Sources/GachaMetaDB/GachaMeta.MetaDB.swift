// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

import Foundation
import GachaMetaGeneratorModule

// MARK: - GachaMetaDB

public typealias GachaItemMetadata = GachaMetaGenerator.GachaItemMeta
public typealias GachaMetaDB = GachaMeta.MetaDB // Old API Compatibility. Will be removed in Package v3.x update.

// MARK: - GachaMeta

public enum GachaMeta {
    public typealias MetaDB = [String: GachaItemMetadata]
}

// MARK: GachaMetaDB.SupportedGame

/// GachaMetaDB
extension GachaMeta.MetaDB {
    public typealias SupportedGame = GachaMetaGenerator.SupportedGame
    public typealias Lang = GachaMetaGenerator.GachaDictLang

    /// One GachaMetaDB may support only one game, hence the lack of needs of the game parameter.
    public func checkIfExpired(against ids: Set<String>) -> Bool {
        !ids.subtracting(Set<String>(keys)).isEmpty
    }

    public func checkIfLangIDSupported(langTag: String, game: SupportedGame) -> Bool {
        Lang.allCases(for: game).first(where: { $0.langTag == langTag.lowercased() }) != nil
    }

    /// Just query name translations without doing anything else.
    public func plainQueryForNames(itemID: String, langID: String) -> String? {
        self[itemID]?.l10nMap?[langID.lowercased()]
    }

    /// Just query rarity level without doing anything else.
    public func plainQueryForRarity(itemID: String) -> Int? {
        self[itemID]?.rank
    }

    /// Hot Reverse Query.
    ///
    /// This API is performance-hitting. It is recommended to build
    /// a dedicated dictionary using .generateHotReverseQueryDict()
    /// for such query tasks.
    public func reverseQuery(langID: String, itemName: String) -> Int? {
        values.first(where: { $0.l10nMap?[langID.lowercased()] == itemName })?.id
    }

    /// Precompiling the Reverse Query Dict.
    public func generateHotReverseQueryDict(for langID: String) -> [String: Int]? {
        let langID = langID.lowercased()
        var resultContainer = [String: Int]()
        values.forEach { item in
            guard let key = item.l10nMap?[langID] else { return }
            resultContainer[key] = item.id
        }
        return resultContainer.isEmpty ? nil : resultContainer
    }
}

extension GachaMeta.MetaDB {
    public static func getBundledDefault(for game: SupportedGame) throws -> [String: GachaItemMetadata]? {
        guard let url = game.bundledResourceURL else { return nil }
        let data = try Data(contentsOf: url)
        let rawDB = try JSONDecoder().decode(GachaMeta.MetaDB.self, from: data)
        return rawDB
    }

    public static func fetchAndCompileLatestDB(for game: SupportedGame) async throws
        -> GachaMeta.MetaDB {
        try await GachaMetaGenerator.fetchAndCompileFromYatta(for: game)
    }
}

extension GachaMeta.MetaDB.SupportedGame {
    fileprivate var bundledResourceURL: URL? {
        switch self {
        case .starRail:
            Bundle.module.url(forResource: "OUTPUT-HSR", withExtension: "json", subdirectory: nil)
        case .genshinImpact:
            Bundle.module.url(forResource: "OUTPUT-GI", withExtension: "json", subdirectory: nil)
        }
    }
}
