// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation
import GachaMetaGeneratorModule

let cmdParameters = CommandLine.arguments.dropFirst(1)

switch cmdParameters.count {
case 1, 2:
    guard let firstArgument = cmdParameters.first,
          let game = GachaMetaGenerator.SupportedGame(arg: firstArgument)
    else {
        let errText = "!! Please give only one argument among `-GI`, `-HSR`, `-GID`, `-HSRD`."
        print("{\"errMsg\": \"\(errText)\"}\n")
        assertionFailure(errText)
        exit(1)
    }
    do {
        let useDimBreath: Bool = firstArgument.suffix(1).lowercased() == "d"
        let dict = useDimBreath
            ? try await GachaMetaGenerator.fetchAndCompileFromDimbreath(for: game)
            : try await GachaMetaGenerator.fetchAndCompileFromYatta(for: game)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        if let encoded = String(data: try encoder.encode(dict), encoding: .utf8) {
            print(encoded)
            NSLog("All Tasks Done.")
        } else {
            let errText = "!! Error on encoding JSON files."
            print("{\"errMsg\": \"\(errText)\"}\n")
            assertionFailure(errText)
            exit(1)
        }
    } catch {
        print("{\"errMsg\": \"\(error)\"}\n")
        throw (error)
    }
default:
    let errText = "!! Wrong number of arguments. Please give only one argument among `-GI`, `-HSR`, `-GID`, `-HSRD`."
    print("{\"errMsg\": \"\(errText)\"}\n")
    assertionFailure(errText)
    exit(1)
}
