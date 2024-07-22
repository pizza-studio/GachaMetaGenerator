// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

import Foundation

extension GachaMetaGenerator {
    // MARK: - GachaItemMeta

    public struct GachaItemMeta: Codable, Identifiable, Sendable {
        // MARK: Lifecycle

        public init(id: Int, rank: Int, nameTextMapHash: Int) {
            self.id = id
            self.rank = rank
            self.nameTextMapHash = nameTextMapHash
        }

        // MARK: Public

        public let id: Int
        public let rank: Int
        public let nameTextMapHash: Int
        public var l10nMap: [String: String]?

        public func isCharacter(for game: SupportedGame) -> Bool {
            switch game {
            case .genshinImpact: return id > 114514
            case .starRail: return id <= 9999
            }
        }
    }
}
