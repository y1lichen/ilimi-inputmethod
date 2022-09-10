//
//  IlimiInputController.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/5.
//

import Cocoa
import InputMethodKit
import SwiftUI

@objc(IMKitSampleInputController)
class IlimiInputController: IMKInputController {
    private let candidates: IMKCandidates

    override init!(server: IMKServer!, delegate: Any!, client inputClient: Any!) {
        // 橫式候選字窗
		self.candidates = IMKCandidates(server: server, panelType: kIMKScrollingGridCandidatePanel)
		var attributes = self.candidates.attributes()
		let font = NSFont.systemFont(ofSize: 22)
		attributes?[NSAttributedString.Key.font] = font
		self.candidates.setFontSize(font.pointSize)
        super.init(server: server, delegate: delegate, client: inputClient)
    }

    override func activateServer(_ sender: Any!) {
        guard sender is IMKTextInput else {
            return
        }
        InputContext.shared.cleanUp()
        candidates.hide()
    }

    override func deactivateServer(_ sender: Any!) {
        guard sender is IMKTextInput else {
            return
        }
        InputContext.shared.cleanUp()
        candidates.hide()
    }

    override func selectionRange() -> NSRange {
        return NSMakeRange(NSNotFound, NSNotFound)
    }

    override func candidates(_ sender: Any!) -> [Any]! {
        return InputContext.shared.candidates
    }

    func commitInputText(client sender: Any!) {
    }

    func commitCandidate(client sender: Any!) {
        let comp = InputContext.shared.currentInput
        let id = InputContext.shared.currentIndex
        let candidate = InputContext.shared.candidates[id]
        client().insertText(candidate, replacementRange: NSMakeRange(0, comp.count))
		InputContext.shared.cleanUp()
		updateCandidatesWindow()
    }

    override func candidateSelected(_ candidateString: NSAttributedString!) {
		let id = InputContext.shared.candidates.firstIndex(of: candidateString.string) ?? -1
        NSLog("id: \(id), candidate: \(candidateString.string)")
        InputContext.shared.currentIndex = id
        commitCandidate(client: client())
    }

    func getNewCandidates(_ text: String) {
        let candidates = InputEngine.shared.getCandidates(text)
        InputContext.shared.candidates = candidates
        self.candidates.update()
    }

    func updateCandidatesWindow() {
        let comp = InputContext.shared.currentInput
        let range = NSMakeRange(NSNotFound, NSNotFound)
        client().setMarkedText(comp, selectionRange: range, replacementRange: range)
        if comp.count > 0 {
            getNewCandidates(comp)
            candidates.show()
        } else {
            InputContext.shared.currentIndex = 0
            candidates.show()
        }
    }
	
	override func cancelComposition() {
		super.cancelComposition()
		let range = NSMakeRange(NSNotFound, NSNotFound)
		client().setMarkedText("", selectionRange: range, replacementRange: range)
	}

    override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        if event.type == NSEvent.EventType.keyDown {
            let inputStr = event.characters!
            let key = inputStr.first!
            NSLog("key: %@", String(key))
            if key.isLetter {
                InputContext.shared.currentInput.append(inputStr)
                updateCandidatesWindow()
                return true
			} else if event.keyCode == kVK_RightArrow && InputContext.shared.currentIndex < InputContext.shared.candidatesCount - 1 {
				InputContext.shared.currentIndex += 1
				return true
			} else if event.keyCode == kVK_LeftArrow && InputContext.shared.currentIndex > 0 {
				InputContext.shared.currentIndex -= 1
				return true
			} else if event.keyCode == kVK_UpArrow || event.keyCode == kVK_ANSI_Minus || event.keyCode == kVK_PageUp {
				self.candidates.pageUp(sender)
				return true
			} else if event.keyCode == kVK_DownArrow || event.keyCode == kVK_ANSI_Equal || event.keyCode == kVK_PageDown {
				self.candidates.pageDown(sender)
                return true
            } else if (event.keyCode == kVK_Shift || event.keyCode == kVK_Return) && InputContext.shared.currentInput.count > 0 {
                commitInputText(client: sender)
                return true
            } else if event.keyCode == kVK_Escape {
                // cleanup the input
                InputContext.shared.cleanUp()
                candidates.update()
                candidates.hide()
				self.cancelComposition()
                return true
            } else if event.keyCode == kVK_Space && InputContext.shared.candidates.count > 0 {
                // commit the input
                commitCandidate(client: sender)
                return true
            } else {
                commitInputText(client: sender)
                return false
            }
        }
        return false
    }
}
