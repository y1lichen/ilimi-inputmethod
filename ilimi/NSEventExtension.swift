//
//  NSEventExtension.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/20.
//

import Foundation

extension NSEvent {
    func reinitiate(
        with type: NSEvent.EventType? = nil,
        location: NSPoint? = nil,
        modifierFlags: NSEvent.ModifierFlags? = nil,
        timestamp: TimeInterval? = nil,
        windowNumber: Int? = nil,
        characters: String? = nil,
        charactersIgnoringModifiers: String? = nil,
        isARepeat: Bool? = nil,
        keyCode: UInt16? = nil
    ) -> NSEvent? {
        let oldChars: String = {
            if self.type == .flagsChanged { return "" }
            return self.characters ?? ""
        }()
        return NSEvent.keyEvent(
            with: type ?? self.type,
            location: location ?? locationInWindow,
            modifierFlags: modifierFlags ?? self.modifierFlags,
            timestamp: timestamp ?? self.timestamp,
            windowNumber: windowNumber ?? self.windowNumber,
            context: nil,
            characters: characters ?? oldChars,
            charactersIgnoringModifiers: charactersIgnoringModifiers ?? characters ?? oldChars,
            isARepeat: isARepeat ?? self.isARepeat,
            keyCode: keyCode ?? self.keyCode
        )
    }
}
