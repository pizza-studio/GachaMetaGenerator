// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

@testable import GachaMetaDB
import XCTest

final class GachaMetaDBTests: XCTestCase {
    func testJSONAccess() throws {
        let jsonGI = try GachaMetaDB.getBundledDefault(for: .genshinImpact)
        let jsonHSR = try GachaMetaDB.getBundledDefault(for: .starRail)
        XCTAssertNotNil(jsonGI)
        XCTAssertNotNil(jsonHSR)
    }

    func testReverseTableGeneration() throws {
        let jsonGI = try GachaMetaDB.getBundledDefault(for: .genshinImpact)
        let reverseTableGI = jsonGI?.generateHotReverseQueryDict(for: "en-US")
        XCTAssertNotNil(reverseTableGI)
    }
}
