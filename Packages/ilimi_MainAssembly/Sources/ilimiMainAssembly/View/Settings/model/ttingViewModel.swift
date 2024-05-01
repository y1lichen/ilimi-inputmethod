//
//  File.swift
//  
//
//  Created by 陳奕利 on 2024/5/1.
//

import Foundation
import SwiftUI

class SettingViewModel: ObservableObject {
	// 預設字體大小 22
	@AppStorage("fontSize")
	var fontSize = 22
	// 預設橫排選字窗
	@AppStorage("isHorizontalCandidatesPanel")
	var isHorizontalCandidatesPanel = true
	// 預設不在沒有候選字時限制輸入
	@AppStorage("limitInputWhenNoCandidate")
	var limitInputWhenNoCandidate = false
	// 預設使用注音輸入後提示拆碼
	@AppStorage("showLiuKeyAfterZhuyin")
	var showLiuKeyAfterZhuyin = true
	// 預設使用1-9選字
	@AppStorage("selectCandidateBy1to8")
	var selectCandidateBy1to8 = true
	// 候選字數
	@AppStorage("candidatesNum")
	var candidatesNum = 8
	// 靜音模式
	@AppStorage("silentMode")
	var silentMode = false
	
	var candidatesNumForBind: Int {
		get {
			candidatesNum
		}
		set {
			if newValue >= 1 && newValue <= 9 {
				candidatesNum = newValue
			}
		}
	}

	let fontSizeValues = [14, 16, 18, 20, 22, 24, 28, 32]

	func killApplicationToReload() {
		NSApp.terminate(self)
	}
}
