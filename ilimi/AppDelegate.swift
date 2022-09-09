//
//  AppDelegate.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/5.
//
// AppDelegate.swift

import Cocoa
import InputMethodKit

// necessary to launch this app
class NSManualApplication: NSApplication {
	private let appDelegate = AppDelegate()

	override init() {
		super.init()
		self.delegate = appDelegate
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
	var server = IMKServer()
	var candidatesWindow = IMKCandidates()

	func applicationDidFinishLaunching(_ notification: Notification) {
		// Insert code here to initialize your application
		server = IMKServer(name: Bundle.main.infoDictionary?["InputMethodConnectionName"] as? String, bundleIdentifier: Bundle.main.bundleIdentifier)
		candidatesWindow = IMKCandidates(server: server, panelType: kIMKSingleRowSteppingCandidatePanel, styleType: kIMKMain)
		PhraseInitilizer.shared.initPhraseWhenStart()
		NSLog("tried connection")
	}

	func applicationWillTerminate(_ notification: Notification) {
		// Insert code here to tear down your application
	}
	
}
