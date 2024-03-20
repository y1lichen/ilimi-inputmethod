// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import Foundation
import SwiftUI

extension NSToolbarItem.Identifier {
    static let general = NSToolbarItem.Identifier(rawValue: "general")
}

extension NSToolbar {
    static let settingsViewToolBar: NSToolbar = {
        let toolbar = NSToolbar(identifier: "SettingsViewToolbar")
        toolbar.displayMode = .iconAndLabel
        return toolbar
    }()
}

// MARK: - AppDelegate + NSToolbarDelegate

extension AppDelegate: NSToolbarDelegate {
    @objc
    func openGeneralSettings() {}

    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.general]
    }

    public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.general]
    }

    public func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    )
        -> NSToolbarItem? {
        switch itemIdentifier {
        case .general:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = "一般"
            let button = NSButton(
                image: NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil)!,
                target: nil,
                action: nil
            )
            button.bezelStyle = .recessed
            item.view = button
            return item

        default:
            return nil
        }
    }
}
