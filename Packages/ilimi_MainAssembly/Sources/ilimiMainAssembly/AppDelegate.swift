// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import Cocoa
import InputMethodKit
import SwiftUI
import UserNotifications

public class AppDelegate: NSObject, NSApplicationDelegate {
	// MARK: Public
	
	public static var shared = AppDelegate()
	
	public func applicationDidFinishLaunching(_ notification: Notification) {
		// Insert code here to initialize your application
		DataInitializer.shared.initDataWhenStart()
		doOnFirstRun()
		// regist UserDefaluts
		registUserDefaultsSetting()
		// notification
		userNotificationCenter.delegate = self
		requestNotificationAuthorization()
		// 用程式碼方法補上MainMenu.xib
		NSApplication.shared.mainMenu = MainMenu()
		//        NSLog("connection tried")
	}
	
	public func applicationWillTerminate(_ notification: Notification) {
		// Insert code here to tear down your application
	}
	
	// MARK: Internal

	func doOnFirstRun() {
		let firstRun = UserDefaults.standard.bool(forKey: "firstRun") as Bool
		if !firstRun {
			CustomPhraseHelper.shared.setDefaultCustomPhrase()
			UserDefaults.standard.setValue(true, forKey: "firstRun")
		}
	}
	
	var queryWindow: NSWindow?
	var settingsWindow: NSWindow?
	let userNotificationCenter = UNUserNotificationCenter.current()
	
	func registUserDefaultsSetting() {
		UserDefaults.standard.register(defaults: ["isHorizontalCandidatesPanel": true])
		UserDefaults.standard.register(defaults: ["limitInputWhenNoCandidate": false])
		UserDefaults.standard.register(defaults: ["showLiuKeyAfterZhuyin": true])
		UserDefaults.standard.register(defaults: ["silentMode": false])
		UserDefaults.standard.register(defaults: ["selectCandidateBy1to8": true])
	}
	
	// request the authorization for pushing local notification
	func requestNotificationAuthorization() {
		userNotificationCenter.requestAuthorization(options: [.alert, .badge]) {
			_, _ in
		}
	}
	
	// 設定視窗
	func showSettingsWindow(_ tabIndex: Int = 0) {
		if let settingsWindow = settingsWindow {
			if settingsWindow.isVisible {
				switch tabIndex {
				case 1:
					settingsWindow.contentView = NSHostingView(rootView: AddCustomPhraseView())
					
				default:
					settingsWindow.contentView = NSHostingView(rootView: GeneralSettingsView())
				}
				settingsWindow.makeKeyAndOrderFront(self)
				settingsWindow.orderFrontRegardless()
				NSApp.activate(ignoringOtherApps: true)
				return
			}
		}
		settingsWindow = NSWindow(
			contentRect: NSRect(x: 0, y: 0, width: 400, height: 250),
			styleMask: [.closable, .resizable, .miniaturizable, .titled],
			backing: .buffered,
			defer: false
		)
		settingsWindow?.toolbarStyle = NSWindow.ToolbarStyle.preference
		NSToolbar.settingsViewToolBar.delegate = self
		settingsWindow?.toolbar = NSToolbar.settingsViewToolBar
		switch tabIndex {
		case 1:
			settingsWindow?.contentView = NSHostingView(rootView: AddCustomPhraseView())
			
		default:
			settingsWindow?.contentView = NSHostingView(rootView: GeneralSettingsView())
		}
		settingsWindow?.center()
		settingsWindow?.makeKeyAndOrderFront(self)
		settingsWindow?.orderFrontRegardless()
		settingsWindow?.isReleasedWhenClosed = false
		NSApp.activate(ignoringOtherApps: true)
	}
	
	// 查碼視窗
	func showQueryWindow() {
		if let queryWindow = queryWindow {
			if queryWindow.isVisible {
				queryWindow.makeKeyAndOrderFront(self)
				queryWindow.orderFrontRegardless()
				return
			}
		}
		queryWindow = NSWindow(
			contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
			styleMask: [.closable, .resizable, .miniaturizable, .titled],
			backing: .buffered,
			defer: false
		)
		queryWindow?.collectionBehavior = [.stationary, .canJoinAllSpaces, .fullScreenAuxiliary]
		let queryView = QueryView()
		queryWindow?.center()
		queryWindow?.contentView = NSHostingView(rootView: queryView)
		queryWindow?.makeKeyAndOrderFront(self)
		queryWindow?.orderFrontRegardless()
		queryWindow?.isReleasedWhenClosed = false
		NSApp.setActivationPolicy(.accessory)
	}
}
