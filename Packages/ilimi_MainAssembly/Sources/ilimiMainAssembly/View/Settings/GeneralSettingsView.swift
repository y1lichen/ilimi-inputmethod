// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import Foundation
import SwiftUI

struct GeneralSettingsView: View {
    @StateObject
    var settingViewModel = SettingViewModel()

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                Picker("字體大小", selection: $settingViewModel.fontSize) {
                    fontPickerContent()
                }.onChange(of: settingViewModel.fontSize) { _ in
                    settingViewModel.killApplicationToReload()
                }
                Picker("選字窗排列", selection: $settingViewModel.isHorizontalCandidatesPanel) {
                    Text("橫式").tag(true)
                    Text("直式").tag(false)
                }
                .onChange(of: settingViewModel.isHorizontalCandidatesPanel) { _ in
                    settingViewModel.killApplicationToReload()
                }
                .pickerStyle(RadioGroupPickerStyle())
                Picker("在沒有候選字時限制輸入", selection: $settingViewModel.limitInputWhenNoCandidate) {
                    Text("是").tag(true)
                    Text("否").tag(false)
                }
                .pickerStyle(RadioGroupPickerStyle())
                .horizontalRadioGroupLayout()
                Picker("使用注音輸入後提示拆碼", selection: $settingViewModel.showLiuKeyAfterZhuyin) {
                    Text("是").tag(true)
                    Text("否").tag(false)
                }
                .pickerStyle(RadioGroupPickerStyle())
                .horizontalRadioGroupLayout()
                Picker("選字碼", selection: $settingViewModel.selectCandidateBy1to8) {
                    Text("1到9").tag(true)
                    Text("0到8").tag(false)
                }
                .onChange(of: settingViewModel.selectCandidateBy1to8) { _ in
                    settingViewModel.killApplicationToReload()
                }
                .pickerStyle(RadioGroupPickerStyle())
                .horizontalRadioGroupLayout()
                Picker("靜音模式", selection: $settingViewModel.silentMode) {
                    Text("是").tag(true)
                    Text("否").tag(false)
                }
                .pickerStyle(RadioGroupPickerStyle())
                .horizontalRadioGroupLayout()
            }.frame(width: 250)
        }
        .frame(width: 450, height: 250)
    }

    @ViewBuilder
    func fontPickerContent() -> some View {
        ForEach(settingViewModel.fontSizeValues, id: \.self) {
            Text("\($0)")
        }
    }
}
