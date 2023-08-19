//
//  GeneralSettingsView.swift
//  ilimi
//
//  Created by 陳奕利 on 2023/1/14.
//

import Foundation
import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage("fontSize") private var fontSize = 24
    let fontSizeValues = [14, 16, 18, 20, 22, 24, 28, 32]
    
    var body: some View {
        VStack {
            Picker("字體大小", selection: $fontSize) {
                fontPickerContent()
            }.onChange(of: fontSize) { _ in
                NSApp.terminate(self)
            }
        }.frame(width: 250)
    }
    
    @ViewBuilder
    func fontPickerContent() -> some View {
        ForEach(fontSizeValues, id: \.self) {
            Text("\($0)")
        }
    }
}
