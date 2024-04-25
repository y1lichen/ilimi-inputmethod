// (c) 2021 and onwards The vChewing Project (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)
// ... with NTL restriction stating that:
// No trademark license is granted to use the trade names, trademarks, service
// marks, or product names of Contributor, except as required to fulfill notice
// requirements defined in MIT License.

import AppKit

// MARK: - NSEvent Extension - Modified Flags

extension NSEvent {
    public var keyModifierFlags: ModifierFlags {
        modifierFlags.intersection(.deviceIndependentFlagsMask).subtracting(.capsLock)
    }

    public var commonKeyModifierFlags: ModifierFlags {
        keyModifierFlags.subtracting([.function, .numericPad, .help])
    }
}

// MARK: - NSEvent Extension - Reconstructors

extension NSEvent {
    public func reinitiate(
        with type: NSEvent.EventType? = nil,
        location: NSPoint? = nil,
        modifierFlags: NSEvent.ModifierFlags? = nil,
        timestamp: TimeInterval? = nil,
        windowNumber: Int? = nil,
        characters: String? = nil,
        charactersIgnoringModifiers: String? = nil,
        isARepeat: Bool? = nil,
        keyCode: UInt16? = nil
    )
        -> NSEvent? {
        let oldChars: String = type == .flagsChanged ? "" : characters ?? ""
        var characters = characters
        checkSpecialKey: if let matchedKey = KeyCode(rawValue: keyCode ?? self.keyCode) {
            let scalar = matchedKey.correspondedSpecialKeyScalar(flags: modifierFlags ?? self.modifierFlags)
            guard let scalar = scalar else { break checkSpecialKey }
            characters = .init(scalar)
        }

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

// MARK: - KeyCode

// Use KeyCodes as much as possible since its recognition won't be affected by macOS Base Keyboard Layouts.
// KeyCodes: https://eastmanreference.com/complete-list-of-applescript-key-codes
// Also: HIToolbox.framework/Versions/A/Headers/Events.h
public enum KeyCode: UInt16 {
    case kNone = 0
    case kCarriageReturn = 36 // Renamed from "kReturn" to avoid nomenclatural confusions.
    case kTab = 48
    case kSpace = 49
    case kSymbolMenuPhysicalKeyIntl = 50 // vChewing Specific (Non-JIS)
    case kBackSpace = 51 // Renamed from "kDelete" to avoid nomenclatural confusions.
    case kEscape = 53
    case kCommand = 55
    case kShift = 56
    case kCapsLock = 57
    case kOption = 58
    case kControl = 59
    case kRightShift = 60
    case kRightOption = 61
    case kRightControl = 62
    case kFunction = 63
    case kF17 = 64
    case kVolumeUp = 72
    case kVolumeDown = 73
    case kMute = 74
    case kLineFeed = 76 // Another keyCode to identify the Enter Key, typable by Fn+Enter.
    case kF18 = 79
    case kF19 = 80
    case kF20 = 90
    case kYen = 93
    case kSymbolMenuPhysicalKeyJIS = 94 // vChewing Specific (JIS)
    case kJISNumPadComma = 95
    case kF5 = 96
    case kF6 = 97
    case kF7 = 98
    case kF3 = 99
    case kF8 = 100
    case kF9 = 101
    case kJISAlphanumericalKey = 102
    case kF11 = 103
    case kJISKanaSwappingKey = 104
    case kF13 = 105 // PrtSc
    case kF16 = 106
    case kF14 = 107
    case kF10 = 109
    case kContextMenu = 110
    case kF12 = 111
    case kF15 = 113
    case kHelp = 114 // Insert
    case kHome = 115
    case kPageUp = 116
    case kWindowsDelete = 117 // Renamed from "kForwardDelete" to avoid nomenclatural confusions.
    case kF4 = 118
    case kEnd = 119
    case kF2 = 120
    case kPageDown = 121
    case kF1 = 122
    case kLeftArrow = 123
    case kRightArrow = 124
    case kDownArrow = 125
    case kUpArrow = 126

    // MARK: Public

    public func correspondedSpecialKeyScalar(flags: NSEvent.ModifierFlags) -> Unicode.Scalar? {
        var rawData: NSEvent.SpecialKey? {
            switch self {
            case .kNone: return nil
            case .kCarriageReturn: return .carriageReturn
            case .kTab: return flags.contains(.shift) ? .backTab : .tab
            case .kSpace: return nil
            case .kSymbolMenuPhysicalKeyIntl: return nil
            case .kBackSpace: return .backspace
            case .kEscape: return nil
            case .kCommand: return nil
            case .kShift: return nil
            case .kCapsLock: return nil
            case .kOption: return nil
            case .kControl: return nil
            case .kRightShift: return nil
            case .kRightOption: return nil
            case .kRightControl: return nil
            case .kFunction: return nil
            case .kF17: return .f17
            case .kVolumeUp: return nil
            case .kVolumeDown: return nil
            case .kMute: return nil
            case .kLineFeed: return nil // TODO: return 待釐清
            case .kF18: return .f18
            case .kF19: return .f19
            case .kF20: return .f20
            case .kYen: return nil
            case .kSymbolMenuPhysicalKeyJIS: return nil
            case .kJISNumPadComma: return nil
            case .kF5: return .f5
            case .kF6: return .f6
            case .kF7: return .f7
            case .kF3: return .f7
            case .kF8: return .f8
            case .kF9: return .f9
            case .kJISAlphanumericalKey: return nil
            case .kF11: return .f11
            case .kJISKanaSwappingKey: return nil
            case .kF13: return .f13
            case .kF16: return .f16
            case .kF14: return .f14
            case .kF10: return .f10
            case .kContextMenu: return .menu
            case .kF12: return .f12
            case .kF15: return .f15
            case .kHelp: return .help
            case .kHome: return .home
            case .kPageUp: return .pageUp
            case .kWindowsDelete: return .deleteForward
            case .kF4: return .f4
            case .kEnd: return .end
            case .kF2: return .f2
            case .kPageDown: return .pageDown
            case .kF1: return .f1
            case .kLeftArrow: return .leftArrow
            case .kRightArrow: return .rightArrow
            case .kDownArrow: return .downArrow
            case .kUpArrow: return .upArrow
            }
        }
        return rawData?.unicodeScalar
    }
}
