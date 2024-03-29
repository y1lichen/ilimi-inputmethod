// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import AppKit
import Foundation
import ilimiMainAssembly
import IMKUtils
import InputMethodKit

let cmdParameters = CommandLine.arguments.dropFirst(1)

switch cmdParameters.count {
case 0: break

case 1:
    switch cmdParameters.first?.lowercased() {
    case "install":
        let exitCode = IMKHelper.registerInputMethod()
        exit(exitCode)
    default: break
    }
    exit(0)
default: exit(0)
}

guard let server = IMKServer(name: Bundle.main.infoDictionary?["InputMethodConnectionName"] as? String, bundleIdentifier: Bundle.main.bundleIdentifier) else {
    NSLog(
        "ilimiDebug: Fatal error: Cannot initialize input method server with connection name retrieved from the plist, nor there's no connection name in the plist."
    )
    exit(-1)
}

public let theServer = server

AppDelegate.shared.server = theServer

NSApplication.shared.delegate = AppDelegate.shared
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
