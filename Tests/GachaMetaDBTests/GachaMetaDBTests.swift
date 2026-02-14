// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

import Foundation
@testable import GachaMetaDB
import Testing

@Suite(.serialized)
struct GachaMetaDBTests {
    @Test
    func testJSONAccess() throws {
        let jsonGI = try GachaMeta.MetaDB.getBundledDefault(for: .genshinImpact)
        let jsonHSR = try GachaMeta.MetaDB.getBundledDefault(for: .starRail)
        #expect(nil != jsonGI)
        #expect(nil != jsonHSR)
    }

    @Test
    func testReverseTableGeneration() throws {
        let jsonGI = try GachaMeta.MetaDB.getBundledDefault(for: .genshinImpact)
        let reverseTableGI = jsonGI?.generateHotReverseQueryDict(for: "en-US")
        #expect(nil != reverseTableGI)
    }
}
