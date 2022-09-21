//  IlimiInputController.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/5.
//

import Cocoa
import InputMethodKit

@objc(IlimiInputController)
class IlimiInputController: IMKInputController {
    private let candidates: IMKCandidates
    static var prefixHasCandidates: Bool = true
    private var isASCIIMode: Bool = false
    private var isZhuyinMode: Bool = false
    private let puntuationSet: Set<Character> = [",", "'", ";", ".", "[", "]", "(", ")"]
    // 輔助選字的字典
    let assistantDict: [String: Int] = ["v": 1, "r": 2, "s": 3, "f": 4, "w": 5, "l": 6, "c": 7, "b": 8]

    override init!(server: IMKServer!, delegate: Any!, client inputClient: Any!) {
        // 橫式候選字窗
        candidates = IMKCandidates(server: server, panelType: kIMKScrollingGridCandidatePanel)
        var attributes = candidates.attributes()
        let font = NSFont.systemFont(ofSize: 22)
        attributes?[NSAttributedString.Key.font] = font
        candidates.setFontSize(font.pointSize)
        super.init(server: server, delegate: delegate, client: inputClient)
        activateServer(inputClient)
    }

    override func activateServer(_ sender: Any!) {
        guard sender is IMKTextInput else {
            return
        }
        InputContext.shared.cleanUp()
        candidates.hide()
        if let client = client(), client.bundleIdentifier() != Bundle.main.bundleIdentifier {
            setKeyLayout()
        }
    }

    override func deactivateServer(_ sender: Any!) {
        guard sender is IMKTextInput else {
            return
        }
        InputContext.shared.cleanUp()
        candidates.hide()
    }

    // 依照威注音註解，此函式可能因IMK的bug而不會被執行
    // https://github.com/vChewing/vChewing-macOS/blob/main/Source/Modules/ControllerModules/ctlInputMethod_Core.swift
    override func inputControllerWillClose() {
        cancelComposition()
        super.inputControllerWillClose()
    }

    override func recognizedEvents(_ sender: Any!) -> Int {
        let events: NSEvent.EventTypeMask = [.keyDown, .flagsChanged]
        return Int(events.rawValue)
    }

    override func selectionRange() -> NSRange {
        return NSMakeRange(NSNotFound, NSNotFound)
    }

    override func candidates(_ sender: Any!) -> [Any]! {
        return InputContext.shared.candidates
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

    override func cancelComposition() {
        client().setMarkedText("", selectionRange: NSMakeRange(0, 0), replacementRange: NSMakeRange(NSNotFound, NSNotFound))
        InputContext.shared.cleanUp()
        candidates.update()
        candidates.hide()
        IlimiInputController.prefixHasCandidates = true
        isZhuyinMode = false
        super.cancelComposition()
    }

    func toggleASCIIMode() {
        cancelComposition()
        isASCIIMode.toggle()
        if isASCIIMode {
            NSLog("ascii mode is on")
        } else {
            NSLog("ascii mode is off")
        }
        setKeyLayout()
    }

    override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        guard let event = event, sender is IMKTextInput else {
            cancelComposition()
            NSLog("Unable to handle NSEvent")
            return false
        }
        guard client() != nil else { return false }
        // toggle isASCIIMode by capslock
        if event.isCapsLockOn {
            if event.characters == nil {
                cancelComposition()
                toggleASCIIMode()
                return true
            }
        }

        // don't handle the event with modifier
        // Otherwise, copy & paste won't work
        // 不能直接pass所有含有modifier 否則方向鍵選字也會失效
        if event.modifierFlags.contains(.control) || event.modifierFlags.contains(.command) || event.modifierFlags.contains(.option) {
            return false
        }
        if event.type == NSEvent.EventType.keyDown {
            let inputStr = event.characters!
            let key = inputStr.first!
            if event.keyCode == kVK_Space {
                if InputContext.shared.candidatesCount > 0 {
                    // commit the input
                    commitCandidate(client: sender)
                    return true
                } else if InputContext.shared.currentInput.count > 0 {
                    // do nothing if composed string isn't empty
                    return true
                }
                return false
            }
            // 原先使用的是self.candidates.isVisible
            if InputContext.shared.candidatesCount > 0 {
                // 使用數字鍵選字
                if !isZhuyinMode && key.isNumber {
                    let keyValue = Int(key.hexDigitValue!)
                    return selectCandidatesByNumAndCommit(client: sender, id: keyValue - 1)
                }
                if isZhuyinMode && checkIsEndOfZhuyin(text: InputContext.shared.currentInput) && key.isNumber {
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
                if event.keyCode == kVK_UpArrow || event.keyCode == kVK_PageUp {
                    candidates.pageUp(sender)
                    return true
                }
                if event.keyCode == kVK_DownArrow || event.keyCode == kVK_PageDown {
                    candidates.pageDown(sender)
                    return true
                }
            }
            if event.keyCode == kVK_Escape {
                // cleanup the input
                if InputContext.shared.currentInput.count > 0 || isZhuyinMode {
                    cancelComposition()
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
            } else if event.keyCode == kVK_Return && InputContext.shared.currentInput.count > 0 {
                commitText(client: sender, text: InputContext.shared.currentInput)
                cancelComposition()
                return true
            }
            if key.isLetter || puntuationSet.contains(key) || (isZhuyinMode && key.isNumber) {
                NSLog("\(key)")
                // 字根最多只有5碼
                if (InputContext.shared.currentInput.count >= 5 || !IlimiInputController.prefixHasCandidates) && InputContext.shared.currentInput.prefix(2) != ",," && InputContext.shared.currentInput.prefix(2) != "';" {
                    NSSound.beep()
                    return true
                }
                // 加到comp
                InputContext.shared.currentInput.append(inputStr)
                // '; -> 注音模式
                if !isZhuyinMode && checkIsZhuyinMode(input: InputContext.shared.currentInput) {
                    return true
                }
                // ,,CT -> 打繁出簡模式
                if checkIsTradToSimToggle(input: InputContext.shared.currentInput) {
                    return true
                }
                // 加v、r、s等選字
                if !(InputContext.shared.preInputPrefixSet.contains(InputContext.shared.currentInput)) && InputContext.shared.candidatesCount > 0 {
                    if let id = assistantDict[inputStr] {
                        if selectCandidatesByNumAndCommit(client: sender, id: id) {
                            return true
                        }
                    }
                }
                updateCandidatesWindow()
                return true
            }
        }
        InputContext.shared.cleanUp()
        return false
    }
}

extension IlimiInputController {
    func checkIsZhuyinMode(input: String) -> Bool {
        isZhuyinMode = (input == "';") ? true : false
        if isZhuyinMode {
            InputContext.shared.cleanUp()
            let range = NSMakeRange(NSNotFound, NSNotFound)
            client().setMarkedText("注", selectionRange: range, replacementRange: range)
            return true
        }
        return false
    }

    var clientBundleIdentifier: String {
        guard let client = client() else { return "" }
        return client.bundleIdentifier() ?? ""
    }

    func setKeyLayout() {
        guard let client = client() else { return }
        if isASCIIMode {
            client.overrideKeyboard(withKeyboardNamed: "AlphanumericalKeyboardLayout")
            return
        }
        client.overrideKeyboard(withKeyboardNamed: "BasicKeyboardLayout")
    }

    func checkIsTradToSimToggle(input: String) -> Bool {
        if input == ",,CT" {
            InputContext.shared.isTradToSim = true
            cancelComposition()
            return true
        }
        return false
    }

    func getZhuyinMarkedText(_ text: String) -> String {
        return "注" + StringConverter.shared.keyToZhuyins(text)
    }

    func ensureWindowLevel(client sender: Any!) {
        // 嘗試實作https://github.com/gureum/gureum/issues/843
        while candidates.windowLevel() <= client().windowLevel() {
            candidates.setWindowLevel(UInt64(max(0, client().windowLevel() + 1000)))
        }
    }

    func getNewCandidatesByZhuyin(comp: String, client sender: Any!) {
        if comp.count > 0 {
            InputEngine.shared.getCadidatesByZhuyin(comp)
            if InputContext.shared.candidatesCount <= 0 {
                candidates.hide()
                return
            }
            candidates.update()
            candidates.show()
            ensureWindowLevel(client: client())
        } else {
            candidates.hide()
        }
    }

    func checkIsEndOfZhuyin(text: String) -> Bool {
        if (text.last?.isLetter) != nil {
            let num = Int(String(text.last!))
            if num == 3 || num == 4 || num == 6 || num == 7 {
                return true
            }
        }
        return false
    }

    func getNewCandidates(comp: String, client sender: Any!) {
        if comp.count > 0 {
            InputEngine.shared.getCandidates(comp)
            if InputContext.shared.candidatesCount <= 0 {
                candidates.hide()
                return
            }
            candidates.update()
            candidates.show()
            ensureWindowLevel(client: client())
        } else {
            candidates.hide()
        }
    }

    func updateCandidatesWindow() {
        guard let client = client() else { return }
        let comp = InputContext.shared.currentInput
        let range = NSMakeRange(NSNotFound, NSNotFound)
        if isZhuyinMode {
            client.setMarkedText(getZhuyinMarkedText(comp), selectionRange: range, replacementRange: range)
            getNewCandidatesByZhuyin(comp: comp, client: client)
        } else {
            client.setMarkedText(comp, selectionRange: range, replacementRange: range)
            getNewCandidates(comp: comp, client: client)
        }
    }

    func commitText(client sender: Any!, text: String) {
        client().insertText(text, replacementRange: NSMakeRange(0, text.count))
        InputContext.shared.cleanUp()
        candidates.hide()
        // 如果是注音模式則關閉注音模式
        isZhuyinMode = false
    }

    func commitCandidate(client sender: Any!) {
        let comp = InputContext.shared.currentInput
        let id = InputContext.shared.currentIndex
        if id < 0 || id >= InputContext.shared.candidatesCount {
            return
        }
        var candidate = InputContext.shared.candidates[id]
        if InputContext.shared.isTradToSim {
            candidate = StringConverter.shared.simplify(candidate)
        }
        if isZhuyinMode {
            client().insertText(candidate, replacementRange: NSMakeRange(0, comp.count + 1))
            isZhuyinMode = false
        } else {
            client().insertText(candidate, replacementRange: NSMakeRange(0, comp.count))
        }
        InputContext.shared.cleanUp()
        updateCandidatesWindow()
    }

    func selectCandidatesByNumAndCommit(client sender: Any!, id: Int) -> Bool {
        if id >= 0 && id < InputContext.shared.candidatesCount {
            InputContext.shared.currentIndex = id
            commitCandidate(client: sender)
            return true
        }
        return false
    }
}
