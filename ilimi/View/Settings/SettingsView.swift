//
//  SettingView.swift
//  ilimi
//
//  Created by 陳奕利 on 2023/1/13.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    var body: some View {
        GeneralSettingsView()
            //            AppearanceSettingsView()
            //                .tabItem {
            //                    Label("外觀", systemImage: "paintpalette")
            //                }

            .frame(width: 450, height: 250)
    }
}
