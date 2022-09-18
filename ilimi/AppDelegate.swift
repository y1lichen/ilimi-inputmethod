//
//  AppDelegate.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/5.
//
// AppDelegate.swift

import Cocoa
import InputMethodKit
import SwiftUI

// necessary to launch this app
class NSManualApplication: NSApplication {
    private let appDelegate = AppDelegate()

    override init() {
        super.init()
        delegate = appDelegate
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var queryWindow: NSWindow? = nil
    var server = IMKServer()
    var candidatesWindow = IMKCandidates()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Insert code here to initialize your application
        server = IMKServer(name: Bundle.main.infoDictionary?["InputMethodConnectionName"] as? String, bundleIdentifier: Bundle.main.bundleIdentifier)
        candidatesWindow = IMKCandidates(server: server, panelType: kIMKSingleRowSteppingCandidatePanel, styleType: kIMKMain)
        DataInitilizer.shared.initDataWhenStart()
        NSLog("tried connection")
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Insert code here to tear down your application
    }

    func showQueryWindow() {
        if let queryWindow = queryWindow {
            if queryWindow.isVisible {
                queryWindow.makeKeyAndOrderFront(self)
                queryWindow.orderFrontRegardless()
                return
            }
        }
        queryWindow = NSWindow(contentRect: NSMakeRect(0, 0, 400, 300),
                             styleMask: [.closable, .resizable, .miniaturizable, .titled],
                             backing: .buffered,
                             defer: false)
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
