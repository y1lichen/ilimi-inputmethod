//
//  GeneralSettingsView.swift
//  ilimi
//
//  Created by 陳奕利 on 2023/1/14.
//

import Foundation
import SwiftUI

struct GeneralSettingsView: View {
    // 預設字體大小 22
    // 預設橫排選字窗
    @AppStorage("fontSize") private var fontSize = 22
    @AppStorage("isHorizontalCandidatesPanel") private var isHorizontalCandidatesPanel = true
    let fontSizeValues = [14, 16, 18, 20, 22, 24, 28, 32]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Picker("字體大小", selection: $fontSize) {
                fontPickerContent()
            }.onChange(of: fontSize) { _ in
                NSApp.terminate(self)
            }
            Picker("選字窗排列", selection: $isHorizontalCandidatesPanel) {
                Text("橫式").tag(true)
                Text("直式").tag(false)
            }.pickerStyle(RadioGroupPickerStyle())
        }.frame(width: 250)
    }
    
    @ViewBuilder
    func fontPickerContent() -> some View {
        ForEach(fontSizeValues, id: \.self) {
            Text("\($0)")
        }
    }
}
