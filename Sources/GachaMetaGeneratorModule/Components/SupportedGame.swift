// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - GachaMetaGenerator.SupportedGame

extension GachaMetaGenerator {
    public enum SupportedGame: CaseIterable {
        case genshinImpact
        case starRail

        // MARK: Lifecycle

        /// Initialize this enum using given commandline argument.
        public init?(arg: String) {
            switch arg.lowercased() {
            case "-gi", "-gid", "genshin", "genshinimpact", "gi": self = .genshinImpact
            case "-hsr", "-hsrd", "-sr", "-srd", "hsr", "sr", "starrail": self = .starRail
            default: return nil
            }
        }

        // MARK: Internal

        enum DataURLType: CaseIterable {
            case weaponData
            case characterData
        }
    }
}

// MARK: - Dealing with Yatta.moe API Results.

extension GachaMetaGenerator.SupportedGame {
    /// Only used for dealing with Yatta.moe API Results.
    ///
    /// If the lang is given null, then the parameter raw value will be `static`.
    /// This will let the `name` field become `nameTextMapHash`.
    func getYattaAPIURL(for type: DataURLType, lang: GachaMetaGenerator.GachaDictLang?) -> URL {
        var langTag = lang.yattaLangID
        if lang == .langCHS, self == .starRail { langTag = "cn" }
        var result = ""
        switch (self, type) {
        case (.genshinImpact, .weaponData): result += "https://gi.yatta.moe/api/v2/\(langTag)/weapon"
        case (.genshinImpact, .characterData): result += "https://gi.yatta.moe/api/v2/\(langTag)/avatar"
        case (.starRail, .weaponData): result += "https://sr.yatta.moe/api/v2/\(langTag)/equipment"
        case (.starRail, .characterData): result += "https://sr.yatta.moe/api/v2/\(langTag)/avatar"
        }
        return URL(string: result)!
    }

    /// Only used for dealing with Yatta.moe API Results.
    ///
    /// If the lang is given null, then the parameter raw value will be `static`.
    /// This will fetch the `nameTextMapHash`.
    func fetchYattaData(
        lang: [GachaMetaGenerator.GachaDictLang?]? = nil
    ) async throws
        -> [GachaMetaGenerator.GachaItemMeta] {
        var lang = lang ?? []
        if lang.isEmpty {
            lang = GachaMetaGenerator.GachaDictLang?.allCases(for: self)
        }
        var buffer = [(items: [GachaMetaGenerator.YattaFetchedItem], lang: GachaMetaGenerator.GachaDictLang?)]()
        for dataType in GachaMetaGenerator.SupportedGame.DataURLType.allCases {
            for locale in lang {
                let url = getYattaAPIURL(for: dataType, lang: locale)
                try await Task.sleep(nanoseconds: UInt64(0.4 * Double(1_000_000_000)))
                let (data, _) = try await URLSession.shared.asyncData(from: url)
                do {
                    let jsonParsed = try JSONDecoder().decode(GachaMetaGenerator.YattaResponse.self, from: data)
                    var rawStack = jsonParsed.items
                    if locale == .langJP {
                        rubyTest: for i in 0 ..< rawStack.count {
                            guard rawStack[i].name.contains("{RUBY") else { continue rubyTest }
                            rawStack[i].name = rawStack[i].name.replacingOccurrences(
                                of: #"\{RUBY.*?\}"#,
                                with: "",
                                options: .regularExpression
                            )
                        }
                    }
                    buffer.append((items: rawStack, lang: locale))
                } catch {
                    // print(error.localizedDescription)
                    // print(String(data: data, encoding: .utf8)!)
                    throw (error)
                }
            }
        }
        var results = [GachaMetaGenerator.GachaDictLang?: [GachaMetaGenerator.YattaFetchedItem]]()
        for result in buffer {
            results[result.lang, default: []].append(contentsOf: result.items)
        }
        return results.assemble() ?? []
    }
}

// MARK: - Dealing with data from Dimbreath's Repository.

extension GachaMetaGenerator.SupportedGame {
    /// Only used for dealing with Dimbreath's repos.
    func fetchExcelConfigData(for type: DataURLType) async throws -> [GachaMetaGenerator.GachaItemMeta] {
        switch (self, type) {
        case (.genshinImpact, .weaponData):
            let (data, _) = try await URLSession.shared.asyncData(from: getExcelConfigDataURL(for: .weaponData))
            let response = try JSONDecoder().decode([GachaMetaGenerator.GenshinRawItem].self, from: data)
            return response.map { $0.toGachaItemMeta() }
        case (.genshinImpact, .characterData):
            let (data, _) = try await URLSession.shared.asyncData(from: getExcelConfigDataURL(for: .characterData))
            let response = try JSONDecoder().decode([GachaMetaGenerator.GenshinRawItem].self, from: data)
            return response.map { $0.toGachaItemMeta() }
        case (.starRail, .weaponData):
            let (data, _) = try await URLSession.shared.asyncData(from: getExcelConfigDataURL(for: .weaponData))
            let response = try JSONDecoder().decode([GachaMetaGenerator.HSRWeaponRawItem].self, from: data)
            return response.filter(\.isValid).map { $0.toGachaItemMeta() }
        case (.starRail, .characterData):
            let (data, _) = try await URLSession.shared.asyncData(from: getExcelConfigDataURL(for: .characterData))
            let response = try JSONDecoder().decode([GachaMetaGenerator.HSRAvatarRawItem].self, from: data)
            return response.filter(\.isValid).map { $0.toGachaItemMeta() }
        }
    }

    /// Only used for dealing with Dimbreath's repos.
    func fetchRawLangData(
        lang: [GachaMetaGenerator.GachaDictLang]? = nil,
        neededHashIDs: Set<String>
    ) async throws
        -> [String: [String: String]] {
        try await withThrowingTaskGroup(
            of: (subDict: [String: String], lang: GachaMetaGenerator.GachaDictLang).self,
            returning: [String: [String: String]].self
        ) { taskGroup in
            lang?.forEach { locale in
                taskGroup.addTask {
                    let urls = getLangDataURLs(for: locale)
                    var finalDict = [String: String]()
                    for url in urls {
                        let (data, _) = try await URLSession.shared.asyncData(from: url)
                        var dict = try JSONDecoder().decode([String: String].self, from: data)
                        let keysToRemove = Set<String>(dict.keys).subtracting(neededHashIDs)
                        keysToRemove.forEach { dict.removeValue(forKey: $0) }
                        if locale == .langJP {
                            dict.keys.forEach { theKey in
                                guard dict[theKey]?.contains("{RUBY") ?? false else { return }
                                if let rawStrToHandle = dict[theKey], rawStrToHandle.contains("{") {
                                    dict[theKey] = rawStrToHandle.replacingOccurrences(
                                        of: #"\{RUBY.*?\}"#,
                                        with: "",
                                        options: .regularExpression
                                    )
                                }
                            }
                        }
                        dict.forEach { key, value in
                            finalDict[key] = value
                        }
                    }
                    return (subDict: finalDict, lang: locale)
                }
            }
            var results = [String: [String: String]]()
            for try await result in taskGroup {
                results[result.lang.langTag] = result.subDict
            }
            return results
        }
    }

    /// Only used for dealing with Dimbreath's repos.
    func getExcelConfigDataURL(for type: DataURLType) -> URL {
        var result = repoHeader + repoName
        switch (self, type) {
        case (.genshinImpact, .weaponData): result += "ExcelBinOutput/WeaponExcelConfigData.json"
        case (.genshinImpact, .characterData): result += "ExcelBinOutput/AvatarExcelConfigData.json"
        case (.starRail, .weaponData): result += "ExcelOutput/EquipmentConfig.json"
        case (.starRail, .characterData): result += "ExcelOutput/AvatarConfig.json"
        }
        return URL(string: result)!
    }

    /// Only used for dealing with Dimbreath's repos.
    func getLangDataURLs(for lang: GachaMetaGenerator.GachaDictLang) -> [URL] {
        lang.filenamesForChunks(for: self).map { filename in
            URL(string: repoHeader + repoName + "TextMap/\(filename)")!
        }
    }

    // MARK: Private

    /// Only used for dealing with Dimbreath's repos.
    private var repoHeader: String {
        switch self {
        case .genshinImpact: return "https://gitlab.com/"
        case .starRail: return "https://gitlab.com/"
        }
    }

    /// Only used for dealing with Dimbreath's repos.
    private var repoName: String {
        switch self {
        case .genshinImpact: return "Dimbreath/AnimeGameData/-/raw/master/"
        case .starRail: return "Dimbreath/TurnBasedGameData/-/raw/main/"
        }
    }
}
