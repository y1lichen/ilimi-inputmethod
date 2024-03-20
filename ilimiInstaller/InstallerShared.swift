// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import AppKit
import InputMethodKit
import SwiftUI

public let kTargetBin = "ilimi"
public let kTargetBinPhraseEditor = "ilimiPhraseEditor"
public let kTargetType = "app"
public let kTargetBundle = "ilimi.app"
public let kTargetBundleWithComponents = "Library/Input%20Methods/ilimi.app"
public let kTISInputSourceID = "org.atelierInmu.inputmethod.ilimi"

let imeURLInstalled = realHomeDir.appendingPathComponent("Library/Input Methods/ilimi.app")

public let realHomeDir = URL(
    fileURLWithFileSystemRepresentation: getpwuid(getuid()).pointee.pw_dir, isDirectory: true, relativeTo: nil
)
public let urlDestinationPartial = realHomeDir.appendingPathComponent("Library/Input Methods")
public let urlTargetPartial = realHomeDir.appendingPathComponent(kTargetBundleWithComponents)
public let urlTargetFullBinPartial = urlTargetPartial.appendingPathComponent("Contents/MacOS")
    .appendingPathComponent(kTargetBin)

public let kDestinationPartial = urlDestinationPartial.path
public let kTargetPartialPath = urlTargetPartial.path
public let kTargetFullBinPartialPath = urlTargetFullBinPartial.path

public let kTranslocationRemovalTickInterval: TimeInterval = 0.5
public let kTranslocationRemovalDeadline: TimeInterval = 60.0

public let installingVersion = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? "BAD_INSTALLING_VER"
public let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "BAD_VER_STR"
public let copyrightLabel = Bundle.main.localizedInfoDictionary?["NSHumanReadableCopyright"] as? String ?? "BAD_COPYRIGHT_LABEL"
public let eulaContent = Bundle.main.localizedInfoDictionary?["CFEULAContent"] as? String ?? "BAD_EULA_CONTENT"

public var mainWindowTitle: String {
    "i18n:installer.INSTALLER_APP_TITLE_FULL".i18n + " (v\(versionString), Build \(installingVersion))"
}

var allRegisteredInstancesOfThisInputMethod: [TISInputSource] {
    guard let components = Bundle(url: imeURLInstalled)?.infoDictionary?["ComponentInputModeDict"] as? [String: Any],
          let tsInputModeListKey = components["tsInputModeListKey"] as? [String: Any]
    else {
        return []
    }
    return TISInputSource.match(modeIDs: tsInputModeListKey.keys.map(\.description))
}

// MARK: - NSApp Activation Helper

// This is to deal with changes brought by macOS 14.

public extension NSApplication {
    func popup() {
        #if compiler(>=5.9) && canImport(AppKit, _version: "14.0")
            if #available(macOS 14.0, *) {
                NSApp.activate()
            } else {
                NSApp.activate(ignoringOtherApps: true)
            }
        #else
            NSApp.activate(ignoringOtherApps: true)
        #endif
    }
}

// MARK: - KeyWindow Finder

public extension NSApplication {
    var keyWindows: [NSWindow] {
        NSApp.windows.filter(\.isKeyWindow)
    }
}

// MARK: - NSApp End With Delay

public extension NSApplication {
    func terminateWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
            if let this = self {
                this.terminate(this)
            }
        }
    }
}

// MARK: - Alert Message & Title Structure

public struct AlertIntel {}

public enum AlertType: String, Identifiable {
    public var id: String { rawValue }
    case nothing, installationFailed, missingAfterRegistration, postInstallAttention, postInstallWarning, postInstallOK

    var title: LocalizedStringKey {
        switch self {
        case .nothing: return ""
        case .installationFailed: return "Install Failed"
        case .missingAfterRegistration: return "Fatal Error"
        case .postInstallAttention: return "Attention"
        case .postInstallWarning: return "Warning"
        case .postInstallOK: return "Installation Successful"
        }
    }

    var message: String {
        switch self {
        case .nothing: return ""
        case .installationFailed:
            return "Cannot copy the file to the destination.".i18n

        case .missingAfterRegistration:
            return String(
                format: "Cannot find input source %@ after registration.".i18n,
                kTISInputSourceID
            )

        case .postInstallAttention:
            return "ilimi is upgraded, but please log out or reboot for the new version to be fully functional.".i18n

        case .postInstallWarning:
            return "Input method may not be fully enabled. Please enable it through System Preferences > Keyboard > Input Sources.".i18n

        case .postInstallOK:
            return "ilimi is ready to use. \n\nPlease relogin if this is the first time you install it in this user account.".i18n
        }
    }
}

private extension StringLiteralType {
    var i18n: String { NSLocalizedString(description, comment: "") }
}

// MARK: - Shell

public extension NSApplication {
    func shell(_ command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        if #available(macOS 10.13, *) {
            task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        } else {
            task.launchPath = "/bin/zsh"
        }
        task.standardInput = nil

        if #available(macOS 10.13, *) {
            try task.run()
        } else {
            task.launch()
        }

        var output = ""
        do {
            let data = try pipe.fileHandleForReading.readToEnd()
            if let data = data, let str = String(data: data, encoding: .utf8) {
                output.append(str)
            }
        } catch {
            return ""
        }
        return output
    }
}
