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
import UserNotifications

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
    let userNotificationCenter = UNUserNotificationCenter.current()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Insert code here to initialize your application
        server = IMKServer(name: Bundle.main.infoDictionary?["InputMethodConnectionName"] as? String, bundleIdentifier: Bundle.main.bundleIdentifier)
        candidatesWindow = IMKCandidates(server: server, panelType: kIMKSingleRowSteppingCandidatePanel, styleType: kIMKMain)
        DataInitilizer.shared.initDataWhenStart()
        // notification
        userNotificationCenter.delegate = self
        requestNotificationAuthorization()
        // 在IMKInputController沒法正確取得flagsChanged，只得先使用global monitor監控flagsChanged事件
        NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged, handler: capsLockHandler)
    }
    
    func capsLockHandler(with event: NSEvent) {
        if event.keyCode == 57 {
            IlimiInputController.isASCIIMode.toggle()
        }
    }
    
    // request the authorization for pushing local notification
    func requestNotificationAuthorization() {
        userNotificationCenter.requestAuthorization(options: [.alert, .badge]) {
            _, _ in
        }
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
