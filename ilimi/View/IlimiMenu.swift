//
//  IlimiMenu.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/10.
//

import Foundation

extension Bool {
    fileprivate var state: NSControl.StateValue {
        self ? .on : .off
    }
}

extension IlimiInputController {
    @objc func reloadJson() {
        DataInitilizer.shared.reloadAllData()
    }

    @objc func toggleTradToSim() {
        InputContext.shared.isTradToSim.toggle()
    }

    @objc func openDataFolder() {
        NSWorkspace.shared.open(URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true))
    }

    @objc func toggleGetZhuyinPanel() {
        (NSApp.delegate as? AppDelegate)?.showQueryWindow()
    }
    
    @objc func toggleSettingView() {
        (NSApp.delegate as? AppDelegate)?.showSettingsWindow()
    }

    override func menu() -> NSMenu! {
        let menu = NSMenu(title: "Ilimi Menu")
        let openDataFolderItem = NSMenuItem(title: "開啟使用者設定目錄", action: #selector(openDataFolder), keyEquivalent: "")
        let reloadJsonItem = NSMenuItem(title: "匯入字檔", action: #selector(reloadJson), keyEquivalent: "")
        let getZhuyinItem = NSMenuItem(title: "反查注音/查碼", action: #selector(toggleGetZhuyinPanel), keyEquivalent: "")
        let toggleTradToSimItem = NSMenuItem(title: "打繁出簡模式", action: #selector(toggleTradToSim), keyEquivalent: "")
        // 開啟打繁出簡模式後，在MenuItem上顯示勾符號
        toggleTradToSimItem.state = InputContext.shared.isTradToSim.state
        menu.addItem(openDataFolderItem)
        menu.addItem(reloadJsonItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(getZhuyinItem)
        menu.addItem(toggleTradToSimItem)
        menu.addItem(NSMenuItem.separator())
        let openSettingItem = NSMenuItem(title: "設定", action: #selector(toggleSettingView), keyEquivalent: "")
        menu.addItem(openSettingItem)
        return menu
    }
}
