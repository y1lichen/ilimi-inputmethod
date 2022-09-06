//
//  UISettings.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/6.
//

import Foundation
import SwiftUI

class UISettings {
	
	static let SystemUI = true

	static let WindowPaddingX: CGFloat = 4
	static let WindowPaddingY: CGFloat = 6

	static let TextColor = NSColor.white
	static let TextBackground = NSColor.black
	static let SelectionBackground = NSColor.systemBlue

	static let FontSize: CGFloat = 22
	static let FontWeight = NSFont.Weight.regular
	static let Font = NSFont.systemFont(ofSize: FontSize, weight: FontWeight)
}
