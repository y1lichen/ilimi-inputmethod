//
//  CandidatesWindow.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/6.
//

import InputMethodKit
import SwiftUI

class CandidatesWindow: NSWindow {
    static let shared = CandidatesWindow()

    var _view: CandidatesView

    override init(
        contentRect: NSRect, styleMask style: NSWindow.StyleMask,
        backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool
    ) {
        _view = CandidatesView()

        super.init(
            contentRect: contentRect, styleMask: NSWindow.StyleMask.borderless,
            backing: backingStoreType, defer: flag)

        isOpaque = false
        level = NSWindow.Level.floating
        backgroundColor = NSColor.clear

        _view = CandidatesView(frame: frame)
        contentView = _view
        orderFront(nil)
    }

    func update(sender: IMKTextInput) {
        let caretPosition = getCaretPosition(sender: sender)

        let numberedCandidates = InputContext.shared.numberedCandidates
        let text = numberedCandidates.joined(separator: " ")
        let textToPaint: NSMutableAttributedString = NSMutableAttributedString(string: text)
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UISettings.Font,
        ]
        textToPaint.addAttributes(attributes, range: NSMakeRange(0, text.count))
        var rect: NSRect = NSZeroRect
        if text.count > 0 {
            rect = NSMakeRect(
                caretPosition.x,
                caretPosition.y - textToPaint.size().height - UISettings.WindowPaddingY * 2,
                textToPaint.size().width + UISettings.WindowPaddingX * 2,
                textToPaint.size().height + UISettings.WindowPaddingY * 2)
        }
        setFrame(rect, display: true)
        _view.setNeedsDisplay(rect)
    }

    func getCaretPosition(sender: IMKTextInput) -> NSPoint {
        var pos: NSPoint
        let lineHeightRect: UnsafeMutablePointer<NSRect> = UnsafeMutablePointer<NSRect>.allocate(
            capacity: 1)

        sender.attributes(forCharacterIndex: 0, lineHeightRectangle: lineHeightRect)

        let rect = lineHeightRect.pointee
        pos = NSMakePoint(rect.origin.x, rect.origin.y)

        return pos
    }

    func show() {
        setIsVisible(true)
    }

    func hide() {
        setIsVisible(false)
    }
}
