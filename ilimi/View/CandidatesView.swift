//
//  CandidatesView.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/6.
//

import Foundation
import SwiftUI

class CandidatesView: NSView {

	override func draw(_ dirtyRect: NSRect) {

		let bounds: NSRect = self.bounds
		UISettings.TextBackground.set()
		NSBezierPath.fill(bounds)

		let numberedCandidates = InputContext.shared.numberedCandidates
		let text = numberedCandidates.joined(separator: " ")
		let textToPaint: NSMutableAttributedString = NSMutableAttributedString.init(string: text)

		let globalAttributes: [NSAttributedString.Key: Any] = [
			NSAttributedString.Key.font: UISettings.Font,
			NSAttributedString.Key.foregroundColor: UISettings.TextColor,
		]
		var start = 0
		let currentIndex = InputContext.shared.currentIndex
		if currentIndex > 0 {
			start = numberedCandidates.prefix(currentIndex).joined(separator: " ").count + 1
		}

		let selection = InputContext.shared.currentNumberedCandidate

		let selectionAttributes: [NSAttributedString.Key: Any] = [
			NSAttributedString.Key.backgroundColor: UISettings.SelectionBackground
		]

		textToPaint.addAttributes(globalAttributes, range: NSMakeRange(0, text.count))
		textToPaint.addAttributes(
			selectionAttributes, range: NSMakeRange(start, selection.count))
		let textBounds = NSMakeRect(
			bounds.origin.x + UISettings.WindowPaddingX,
			bounds.origin.y + UISettings.WindowPaddingY,
			bounds.width - UISettings.WindowPaddingX * 2,
			bounds.height - UISettings.WindowPaddingY * 2)
		textToPaint.draw(in: textBounds)
	}
}
