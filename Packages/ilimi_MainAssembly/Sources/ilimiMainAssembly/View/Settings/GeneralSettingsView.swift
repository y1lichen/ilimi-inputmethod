// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import Foundation
import SwiftUI

struct GeneralSettingsView: View {
    // 預設字體大小 22
    @AppStorage("fontSize")
    private var fontSize = 22
    // 預設橫排選字窗
    @AppStorage("isHorizontalCandidatesPanel")
    private var isHorizontalCandidatesPanel = true
    // 預設不在沒有候選字時限制輸入
    @AppStorage("limitInputWhenNoCandidate")
    private var limitInputWhenNoCandidate = false
	// 預設使用注音輸入後提示拆碼
	@AppStorage("showLiuKeyAfterZhuyin")
	private var showLiuKeyAfterZhuyin = true
    // 靜音模式
    @AppStorage("silentMode")
    private var silentMode = false

    let fontSizeValues = [14, 16, 18, 20, 22, 24, 28, 32]

    func killApplicationToReload() {
        NSApp.terminate(self)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Picker("字體大小", selection: $fontSize) {
                fontPickerContent()
            }.onChange(of: fontSize) { _ in
                killApplicationToReload()
            }
            Picker("選字窗排列", selection: $isHorizontalCandidatesPanel) {
                Text("橫式").tag(true)
                Text("直式").tag(false)
            }.onChange(of: isHorizontalCandidatesPanel) { _ in
                killApplicationToReload()
            }
            .pickerStyle(RadioGroupPickerStyle())
            Picker("在沒有候選字時限制輸入", selection: $limitInputWhenNoCandidate) {
                Text("是").tag(true)
                Text("否").tag(false)
            }
            .pickerStyle(RadioGroupPickerStyle())
            .horizontalRadioGroupLayout()
			Picker("使用注音輸入後提示拆碼", selection: $showLiuKeyAfterZhuyin) {
				Text("是").tag(true)
				Text("否").tag(false)
			}
			.pickerStyle(RadioGroupPickerStyle())
			.horizontalRadioGroupLayout()
            Picker("靜音模式", selection: $silentMode) {
                Text("是").tag(true)
                Text("否").tag(false)
            }
            .pickerStyle(RadioGroupPickerStyle())
            .horizontalRadioGroupLayout()
        }.frame(width: 250)
    }

    @ViewBuilder
    func fontPickerContent() -> some View {
        ForEach(fontSizeValues, id: \.self) {
            Text("\($0)")
        }
    }
}
