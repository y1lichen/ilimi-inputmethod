//
//  File.swift
//
//
//  Created by 陳奕利 on 2024/3/27.
//

import Foundation
import AppKit

class MainMenu: NSMenu {
	override init(title: String) {
		super.init(title: title)
		let editMenu = NSMenuItem()
		editMenu.submenu = NSMenu(title: "Edit")
		editMenu.submenu?.items = [
			NSMenuItem(title: "Undo", action: #selector(UndoManager.undo), keyEquivalent: "z"),
			NSMenuItem(title: "Redo", action: #selector(UndoManager.redo), keyEquivalent: "Z"),
			NSMenuItem.separator(),
			NSMenuItem(title: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x"),
			NSMenuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c"),
			NSMenuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v"),
			NSMenuItem.separator(),
			NSMenuItem(title: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"),
			NSMenuItem.separator(),
			NSMenuItem(title: "Duplicate", action: #selector(NSApplication.copy), keyEquivalent: "d"),
		]
		items = [editMenu]
	}
	
	required init(coder: NSCoder) {
		super.init(coder: coder)
	}
}
