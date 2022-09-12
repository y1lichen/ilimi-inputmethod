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
    private var prefixHasCandidates: Bool = true

    let assistantDict: [String: Int] = ["v": 1, "r": 2, "s": 3, "f": 4, "w": 5, "l": 6, "c": 7, "b": 8]

    override init!(server: IMKServer!, delegate: Any!, client inputClient: Any!) {
        // 橫式候選字窗
        candidates = IMKCandidates(server: server, panelType: kIMKScrollingGridCandidatePanel)
        var attributes = candidates.attributes()
        let font = NSFont.systemFont(ofSize: 22)
        attributes?[NSAttributedString.Key.font] = font
        candidates.setFontSize(font.pointSize)
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

    func commitText(client sender: Any!, text: String) {
        client().insertText(text, replacementRange: NSMakeRange(0, text.count))
        InputContext.shared.cleanUp()
        candidates.hide()
    }

    func commitCandidate(client sender: Any!) {
        let comp = InputContext.shared.currentInput
        let id = InputContext.shared.currentIndex
        if id < 0 || id >= InputContext.shared.candidatesCount {
            return
        }
        var candidate = InputContext.shared.candidates[id]
        if InputContext.shared.isTradToSim {
            candidate = GBig.shared.simplify(candidate)
        }
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

    // 參考威注音 不實作該函式
    // 詳見https://github.com/vChewing/vChewing-macOS/blob/main/Source/Modules/ControllerModules/ctlInputMethod_Core.swift
    override func candidateSelectionChanged(_ candidateString: NSAttributedString!) {
    }

    func getNewCandidates(_ text: String) {
        let candidates = InputEngine.shared.getCandidates(text)
        prefixHasCandidates = candidates.count > 0 ? true : false
        InputContext.shared.candidates = candidates
        self.candidates.update()
    }

    func updateCandidatesWindow() {
        let comp = InputContext.shared.currentInput
        let range = NSMakeRange(NSNotFound, NSNotFound)
        client().setMarkedText(comp, selectionRange: range, replacementRange: range)
        if comp.count > 0 {
            getNewCandidates(comp)
            if InputContext.shared.candidatesCount <= 0 {
                candidates.hide()
                return
            }
            candidates.show()
        } else {
            candidates.hide()
        }
    }

    func selectCandidatesByNumAndCommit(client sender: Any!, id: Int) -> Bool {
        if id >= 0 && id < InputContext.shared.candidatesCount {
            InputContext.shared.currentIndex = id
            commitCandidate(client: sender)
            return true
        }
        return false
    }

    override func cancelComposition() {
        let range = NSMakeRange(NSNotFound, NSNotFound)
        client().setMarkedText("", selectionRange: range, replacementRange: range)
        InputContext.shared.cleanUp()
        candidates.update()
        candidates.hide()
		super.cancelComposition()
    }

    override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        if event.type == NSEvent.EventType.keyDown {
            let inputStr = event.characters!
            let key = inputStr.first!
            if (event.keyCode == kVK_Shift || event.keyCode == kVK_Return) && InputContext.shared.currentInput.count > 0 {
                return true
            } else if event.keyCode == kVK_Space {
                if InputContext.shared.candidates.count > 0 {
                    // commit the input
                    commitCandidate(client: sender)
                    return true
                }
                return false
            } else if event.keyCode == kVK_Delete {
                if InputContext.shared.currentInput.count > 0 {
                    InputContext.shared.currentInput.removeLast()
                    let range = NSMakeRange(NSNotFound, NSNotFound)
                    client().setMarkedText(InputContext.shared.currentInput, selectionRange: range, replacementRange: range)
                    updateCandidatesWindow()
                    return true
                }
                return false
            } else if event.keyCode == kVK_Escape {
                // cleanup the input
                if InputContext.shared.currentInput.count > 0 {
                    cancelComposition()
                    return true
                }
                return false
            } else if key.isLetter || key.isPunctuation {
                // 字根最多只有5碼
				if (InputContext.shared.currentInput.count >= 5 || !prefixHasCandidates) && InputContext.shared.currentInput.prefix(2) != ",,"{
                    NSSound.beep()
                    return true
                }
				// 正常輸入至markedText
				InputContext.shared.currentInput.append(inputStr)
				// 加v、r、s等選字
				if !(InputContext.shared.preInputPrefixSet.contains(InputContext.shared.currentInput)) && InputContext.shared.candidatesCount > 0 {
                    if let id = assistantDict[inputStr] {
                        if selectCandidatesByNumAndCommit(client: sender, id: id) {
                            return true
                        }
                    }
                }
                // ,,CT -> 打繁出簡模式
                let currentInput = InputContext.shared.currentInput
                if checkIsTradToSimToggle(input: currentInput) {
                    return true
                }
                updateCandidatesWindow()
                return true
            } else if candidates.isVisible() {
                // 使用數字鍵選字
                if key.isNumber {
                    let keyValue = Int(key.hexDigitValue!)
                    return selectCandidatesByNumAndCommit(client: sender, id: keyValue - 1)
                }
                if event.keyCode == kVK_RightArrow && InputContext.shared.currentIndex < InputContext.shared.candidatesCount - 1 {
                    InputContext.shared.currentIndex += 1
                    candidates.moveRight(sender)
                    return true
                }
                if event.keyCode == kVK_LeftArrow && InputContext.shared.currentIndex > 0 {
                    InputContext.shared.currentIndex -= 1
                    candidates.moveLeft(sender)
                    return true
                }
                if event.keyCode == kVK_UpArrow || event.keyCode == kVK_ANSI_Minus || event.keyCode == kVK_PageUp {
                    candidates.pageUp(sender)
                    return true
                }
                if event.keyCode == kVK_DownArrow || event.keyCode == kVK_ANSI_Equal || event.keyCode == kVK_PageDown {
                    candidates.pageDown(sender)
                    return true
                }
            }
        }
        return false
    }
}

extension IlimiInputController {
    func checkIsTradToSimToggle(input: String) -> Bool {
        if input == ",,CT" {
            InputContext.shared.isTradToSim = true
            cancelComposition()
            return true
        }
        return false
    }
}
