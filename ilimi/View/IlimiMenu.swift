//
//  IlimiMenu.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/10.
//

import Foundation

extension IlimiInputController {
    @objc func reloadLiuJson() {
        DataInitilizer.shared.loadLiuJson()
    }

    @objc func toggleTradToSim() {
        InputContext.shared.isTradToSim.toggle()
    }

    @objc func openDataFolder() {
        NSWorkspace.shared.open(URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true))
    }

    @objc func toggleGetZhuyinPanel() {
        (NSApp.delegate as? AppDelegate)?.showQueryWindow()
        NSApp.activate(ignoringOtherApps: true)
    }

    override func menu() -> NSMenu! {
        let menu = NSMenu(title: "Ilimi Menu")
        let openDataFolderItem = NSMenuItem(title: "開啟使用者設定目錄", action: #selector(openDataFolder), keyEquivalent: "")
        let reloadJsonItem = NSMenuItem(title: "匯入liu.json", action: #selector(reloadLiuJson), keyEquivalent: "")
        let getZhuyinItem = NSMenuItem(title: "反查注音/查碼", action: #selector(toggleGetZhuyinPanel), keyEquivalent: "")
        let toggleTradToSimItem = NSMenuItem(title: "打繁出簡模式", action: #selector(toggleTradToSim), keyEquivalent: "")
        menu.addItem(openDataFolderItem)
        menu.addItem(reloadJsonItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(getZhuyinItem)
        menu.addItem(toggleTradToSimItem)
        return menu
    }
}
