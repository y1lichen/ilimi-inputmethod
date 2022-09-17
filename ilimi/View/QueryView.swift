//
//  GetZhuyinView.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/16.
//

import SwiftUI

struct QueryView: View {
    var body: some View {
        VStack {
            Text("hello world")
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

class QueryWindowController: NSWindowController, NSWindowDelegate {
    override init(window: NSWindow?) {
        super.init(window: window)
        self.window?.isReleasedWhenClosed = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.delegate = self
        self.window?.makeKeyAndOrderFront(nil)
        self.window?.orderFrontRegardless()
        self.window?.level = .floating
        self.window?.contentView = NSHostingView(rootView: QueryView())
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func windowWillClose(_ notification: Notification) {
        let delegate = (NSApplication.shared.delegate) as! AppDelegate
        delegate.queryWindow = nil
    }
}
