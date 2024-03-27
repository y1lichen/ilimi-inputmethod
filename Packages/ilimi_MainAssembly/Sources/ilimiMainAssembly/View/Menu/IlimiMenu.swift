// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import AppKit
import Foundation

extension Bool {
    fileprivate var state: NSControl.StateValue {
        self ? .on : .off
    }
}

extension IlimiInputController {
    @objc
    func reloadJson() {
        DataInitializer.shared.reloadAllData()
    }

    @objc
    func toggleTradToSim() {
        InputContext.shared.isTradToSim.toggle()
    }

    @objc
    func openDataFolder() {
        NSWorkspace.shared.open(DataInitializer.appSupportURL)
    }

    @objc
    func toggleGetZhuyinPanel() {
        (NSApp.delegate as? AppDelegate)?.showQueryWindow()
    }

    @objc
    func toggleSettingView() {
        (NSApp.delegate as? AppDelegate)?.showSettingsWindow()
    }

    @objc
    func reloadApp() {
        NSApp.terminate(self)
    }
	
	// 在輸入法上的menu
    override public func menu() -> NSMenu! {
        let menu = NSMenu(title: "Ilimi Menu")
        let openDataFolderItem = NSMenuItem(title: "開啟使用者設定目錄", action: #selector(openDataFolder), keyEquivalent: "")
        let reloadJsonItem = NSMenuItem(title: "匯入字檔", action: #selector(reloadJson), keyEquivalent: "")
        let getZhuyinItem = NSMenuItem(title: "反查注音/查碼", action: #selector(toggleGetZhuyinPanel), keyEquivalent: "")
        let toggleTradToSimItem = NSMenuItem(title: "打繁出簡模式", action: #selector(toggleTradToSim), keyEquivalent: "")
        let openSettingItem = NSMenuItem(title: "設定", action: #selector(toggleSettingView), keyEquivalent: "")
        let reloadAppItem = NSMenuItem(title: "重啟輸入法", action: #selector(reloadApp), keyEquivalent: "")
        // 開啟打繁出簡模式後，在MenuItem上顯示勾符號
        toggleTradToSimItem.state = InputContext.shared.isTradToSim.state
        menu.addItem(getZhuyinItem)
        menu.addItem(toggleTradToSimItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(openSettingItem)
        menu.addItem(openDataFolderItem)
        menu.addItem(reloadJsonItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(reloadAppItem)
        return menu
    }
}
