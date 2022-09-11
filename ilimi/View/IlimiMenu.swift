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

    @objc func toggleTradToSim() {
		InputContext.shared.isTradToSim.toggle()
	}
	
	@objc func openDataFolder() {
		NSWorkspace.shared.open(URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true))
	}

    override func menu() -> NSMenu! {
        let menu = NSMenu(title: "Ilimi Menu")
		let openDataFolderItem = NSMenuItem(title: "開啟使用者設定目錄", action: #selector(openDataFolder), keyEquivalent: "")
		let reloadJsonItem = NSMenuItem(title: "匯入liu.json", action: #selector(reloadLiuJson), keyEquivalent: "")
		let toggleTradToSimItem = NSMenuItem(title: "打繁出簡模式", action: #selector(toggleTradToSim), keyEquivalent: "")
		menu.addItem(openDataFolderItem)
		menu.addItem(reloadJsonItem)
		menu.addItem(toggleTradToSimItem)
        return menu
    }
}
