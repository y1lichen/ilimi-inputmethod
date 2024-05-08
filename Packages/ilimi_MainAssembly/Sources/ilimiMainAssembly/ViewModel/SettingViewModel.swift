//
//  File.swift
//
//
//  Created by 陳奕利 on 2024/5/1.
//

import Foundation
import SwiftUI

class SettingViewModel: ObservableObject {
    static let shared = SettingViewModel()

    // 預設字體大小 22
    @AppStorage("fontSize")
    var fontSize = 22
    // 預設橫排選字窗
    @AppStorage("isHorizontalCandidatesPanel")
    var isHorizontalCandidatesPanel = true
    // 預設不在沒有候選字時限制輸入
    @AppStorage("limitInputWhenNoCandidate")
    var limitInputWhenNoCandidate = false
    // 預設只顯示完全匹配字碼的字元
    @AppStorage("showOnlyExactlyMatch")
    var showOnlyExactlyMatch = true
    // 預設使用注音輸入後提示拆碼
    @AppStorage("showLiuKeyAfterZhuyin")
    var showLiuKeyAfterZhuyin = true
    // 預設使用1-9選字
    @AppStorage("selectCandidateBy1to8")
    var selectCandidateBy1to8 = true
    // 靜音模式
    @AppStorage("silentMode")
    var silentMode = false
	// 自動檢查
	@AppStorage("autoCheckUpdate")
	var autoCheckUpdate = true

    let fontSizeValues = [14, 16, 18, 20, 22, 24, 28, 32]

    func killApplicationToReload() {
        NSApp.terminate(self)
    }
}
