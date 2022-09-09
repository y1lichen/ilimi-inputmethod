//
//  IlimiMenu.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/10.
//

import Foundation

extension IlimiInputController {
    @objc func reloadLiuJson() {
        PhraseInitilizer.shared.loadLiuJson()
    }

    override func menu() -> NSMenu! {
        let menu = NSMenu(title: "Ilimi Menu")
        let reloadJsonItem = NSMenuItem(title: "Reload liu.json", action: #selector(reloadLiuJson), keyEquivalent: "")
        menu.addItem(reloadJsonItem)
        return menu
    }
}
