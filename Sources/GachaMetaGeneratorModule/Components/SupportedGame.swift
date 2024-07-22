// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

import Foundation

extension GachaMetaDB {
    public enum SupportedGame: CaseIterable {
        case genshinImpact
        case starRail

        // MARK: Lifecycle

        /// Initialize this enum using given commandline argument.
        public init?(arg: String) {
            switch arg.lowercased() {
            case "-gi", "genshin", "genshinimpact", "gi": self = .genshinImpact
            case "-hsr", "hsr", "starrail": self = .starRail
            default: return nil
            }
        }

        // MARK: Internal

        enum DataURLType: CaseIterable {
            case weaponData
            case characterData
        }

        func fetchExcelConfigData(for type: DataURLType) async throws -> [GachaMetaDB.GachaItemMeta] {
            switch (self, type) {
            case (.genshinImpact, .weaponData):
                let (data, _) = try await URLSession.shared.data(from: getExcelConfigDataURL(for: .weaponData))
                let response = try JSONDecoder().decode([GachaMetaDB.GenshinRawItem].self, from: data)
                return response.map { $0.toGachaItemMeta() }
            case (.genshinImpact, .characterData):
                let (data, _) = try await URLSession.shared.data(from: getExcelConfigDataURL(for: .characterData))
                let response = try JSONDecoder().decode([GachaMetaDB.GenshinRawItem].self, from: data)
                return response.map { $0.toGachaItemMeta() }
            case (.starRail, .weaponData):
                let (data, _) = try await URLSession.shared.data(from: getExcelConfigDataURL(for: .weaponData))
                let response = try JSONDecoder().decode([String: GachaMetaDB.WeaponRawItem].self, from: data)
                return response.map { $0.value.toGachaItemMeta() }
            case (.starRail, .characterData):
                let (data, _) = try await URLSession.shared.data(from: getExcelConfigDataURL(for: .characterData))
                let response = try JSONDecoder().decode([String: GachaMetaDB.AvatarRawItem].self, from: data)
                return response.map { $0.value.toGachaItemMeta() }
            }
        }

        func fetchRawLangData(
            lang: [GachaDictLang]? = nil,
            neededHashIDs: Set<String>
        ) async throws
            -> [String: [String: String]] {
            try await withThrowingTaskGroup(
                of: (subDict: [String: String], lang: GachaDictLang).self,
                returning: [String: [String: String]].self
            ) { taskGroup in
                lang?.forEach { locale in
                    taskGroup.addTask {
                        let url = getLangDataURL(for: locale)
                        let (data, _) = try await URLSession.shared.data(from: url)
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
                        return (subDict: dict, lang: locale)
                    }
                }
                var results = [String: [String: String]]()
                for try await result in taskGroup {
                    results[result.lang.langID] = result.subDict
                }
                return results
            }
        }

        func getExcelConfigDataURL(for type: DataURLType) -> URL {
            var result = Self.repoHeader + repoName
            switch (self, type) {
            case (.genshinImpact, .weaponData): result += "ExcelBinOutput/WeaponExcelConfigData.json"
            case (.genshinImpact, .characterData): result += "ExcelBinOutput/AvatarExcelConfigData.json"
            case (.starRail, .weaponData): result += "ExcelOutput/EquipmentConfig.json"
            case (.starRail, .characterData): result += "ExcelOutput/AvatarConfig.json"
            }
            return URL(string: result)!
        }

        func getLangDataURL(for lang: GachaDictLang) -> URL {
            URL(string: Self.repoHeader + repoName + "TextMap/\(lang.filename)")!
        }

        // MARK: Private

        private static let repoHeader = """
        https://raw.githubusercontent.com/
        """

        private var repoName: String {
            switch self {
            case .genshinImpact: return "DimbreathBot/AnimeGameData/master/"
            case .starRail: return "Dimbreath/StarRailData/master/"
            }
        }
    }
}
