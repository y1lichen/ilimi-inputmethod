// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import AppKit
import SwiftUI

@main
struct ilimiInstallerApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .center) {
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            Color(red: 0, green: 0, blue: 0xF4 / 255),
                            .black,
                        ]
                    ),
                    startPoint: .top, endPoint: .bottom
                ).overlay(alignment: .topLeading) {
                    Text("ilimi Input Method")
                        .font(.system(size: 30))
                        .italic().bold()
                        .padding()
                        .foregroundStyle(Color.white)
                        .shadow(color: .black, radius: 0, x: 5, y: 5)
                }
                MainView()
                    .shadow(color: .black, radius: 3, x: 0, y: 0)
            }.frame(width: 1000, height: 630)
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
                    NSApp.windows.forEach { window in
                        window.titlebarAppearsTransparent = true
                        window.setContentSize(.init(width: 1000, height: 630))
                        window.standardWindowButton(.closeButton)?.isHidden = true
                        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                        window.standardWindowButton(.zoomButton)?.isHidden = true
                        window.styleMask.remove(.resizable)
                        window.orderFront(self)
                    }
                }
                .onDisappear {
                    NSApp.terminate(self)
                }
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .appInfo) {}
            CommandGroup(replacing: .help) {}
            CommandGroup(replacing: .appVisibility) {}
            CommandGroup(replacing: .systemServices) {}
        }
    }
}
