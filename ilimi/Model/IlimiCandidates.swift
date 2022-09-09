//
//  IlimiCandidates.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/9.

import Foundation
import InputMethodKit

class IlimiCandidates: IMKCandidates {
	override init!(server: IMKServer!, panelType: IMKCandidatePanelType) {
		super.init(server: server, panelType: panelType)
		var attr = attributes()
		attr![NSAttributedString.Key.font] = NSFont.systemFont(ofSize: 20)
		setAttributes(attr)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
