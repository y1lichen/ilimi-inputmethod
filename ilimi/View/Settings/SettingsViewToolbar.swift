//
//  SettingsViewToolbar.swift
//  ilimi
//
//  Created by 陳奕利 on 2023/1/14.
//

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

extension AppDelegate: NSToolbarDelegate {
    
    @objc func openGeneralSettings() {
        
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.general]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.general]
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        
        switch itemIdentifier {
        case .general:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = "一般"
            let button = NSButton(image: NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil)!, target: nil, action: nil)
            button.bezelStyle = .recessed
            item.view = button
            return item
        default:
         return nil
        }
    }
}
