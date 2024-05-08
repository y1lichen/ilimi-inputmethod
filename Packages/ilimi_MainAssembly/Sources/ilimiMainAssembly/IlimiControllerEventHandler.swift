// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import IMKUtils
import InputMethodKit

extension IlimiInputController {
    // IMK預設不會recognize flagsChanged事件
    override public func recognizedEvents(_ sender: Any!) -> Int {
//        let isCurrentApp = clientBundleIdentifier == Bundle.main.bundleIdentifier
        let events: NSEvent.EventTypeMask = [.keyDown, .flagsChanged]
        return Int(events.rawValue)
    }

    override public func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        guard var event = event, sender is IMKTextInput else {
            cleanComposition()
            NSLog("Unable to handle NSEvent")
            return false
        }
        // check if capslock is pressed
        if checkIsCapslock(event: event) {
            return false
        }
        if checkIsToggleFullWidthMode(event: event) {
            return true
        }
        // don't handle the event with modifier
        // Otherwise, copy & paste won't work
        // 不能直接pass所有含有modifier 否則方向鍵選字也會失效
        // 有時候不會偵測到flags changed，額外使用modifierFlags.contains避免快捷鍵被捕捉
        if event.type == .flagsChanged ||
            event.modifierFlags.contains(.command) ||
            event.modifierFlags.contains(.control) ||
            event.modifierFlags.contains(.option) {
//            NSLog("flags change")
            return false
        }
        guard client() != nil else { return false }

        if event.type == NSEvent.EventType.keyDown {
            reinitalization: if let queriedKeyMapPair = LatinKeyboardMappings.qwertyIlimi.mapTable[event.keyCode] {
                // 這段可以確保 event 裡面處理的一般內容都是 ASCII 英數。
                switch event.commonKeyModifierFlags {
                case .shift:
                    event = event.reinitiate(
                        characters: queriedKeyMapPair.1,
                        charactersIgnoringModifiers: queriedKeyMapPair.0
                    ) ?? event

                case []:
                    event = event.reinitiate(
                        characters: queriedKeyMapPair.0,
                        charactersIgnoringModifiers: queriedKeyMapPair.0
                    ) ?? event
                default: break reinitalization
                }
            }
            if handleFullWidthMode(event: event, client: sender) {
                return true
            }
            let inputStr = event.characters!
            let key = inputStr.first!
            if event.keyCode == kVK_Space {
                return spcHandler(client: sender)
            }
            // 選字窗出現時
            if candidates.isVisible() {
                // 使用數字鍵選字
                if (!isZhuyinMode && key.isNumber) ||
                    (isZhuyinMode && checkIsEndOfZhuyin(text: InputContext.shared.getCurrentInput()) && key.isNumber) {
                    // 直式不處理
                    if !SettingViewModel.shared.isHorizontalCandidatesPanel, InputContext.shared.currHentIndex > 9 {
                        return false
                    }
                    let keyValue = Int(key.hexDigitValue!)
                    return handleSelectCandidatesByNum(keyValue, client: sender)
                }
                if handleCandidatesWindowNavigation(event, client: sender) {
                    return true
                }
            }
            if event.keyCode == kVK_Escape {
                // cleanup the input
                return escHandler()
            } else if event.keyCode == kVK_Delete {
                return deleteHandler()
            } else if event.keyCode == kVK_Return && !InputContext.shared.getCurrentInput().isEmpty {
                commitText(client: sender, text: InputContext.shared.getCurrentInput())
                cleanComposition()
                return true
            }
            if key.isLetter || puntuationSet
                .contains(key) || (isZhuyinMode && (key.isNumber || key.isPunctuation)) || key == "\\" {
//                NSLog("\(key)")
                //
                if isASCIIMode {
                    return capslockHandler(event: event, text: inputStr, client: sender)
                }
                // 字根最多只有5碼
                // 使用者可設定在沒有候選字時限制輸入
                let limitInputWhenNoCandidate = UserDefaults.standard.bool(forKey: "limitInputWhenNoCandidate")
                if limitInputWhenNoCandidate,
                   (SettingViewModel.shared.showOnlyExactlyMatch && InputContext.shared.getCurrentInput().count >= 5)
                   ||
                   (
                       !SettingViewModel.shared.showOnlyExactlyMatch && (
                           InputContext.shared.getCurrentInput()
                               .count >= 5 || !IlimiInputController.prefixHasCandidates
                       )
                   ),
                   InputContext.shared.getCurrentInput().prefix(2) != ",,",
                   InputContext.shared.getCurrentInput().prefix(2) != "';" {
                    beep()
                    return true
                }
                // 關閉括弧
                if key == "]" {
                    if let closure = InputContext.shared.getClosingClosure() {
                        commitText(client: sender, text: closure)
                        return true
                    }
                }
                // vrs等輔助選字
                if handleAssistChar(inputStr, sender) {
                    return true
                }
                // 加到composition
                InputContext.shared.appendCurrentInput(inputStr)
                // \ -> 同音輸入模式
                if !isTypeByPronunciationMode, checkIsInputByPronunciationMode(InputContext.shared.getCurrentInput()) {
                    return true
                }
                // '; -> 注音模式
                if !isZhuyinMode, checkIsZhuyinMode(InputContext.shared.getCurrentInput()) {
                    return true
                }
                // 檢查快捷
                if ckeckIsShortcut(InputContext.shared.getCurrentInput()) {
                    return true
                }
                updateCandidatesWindow()
                return true
            }
        }
        InputContext.shared.cleanUp()
        return false
    }

    // 加v、r、s等選字
    // 釐清輔助選字機制
    // 參考https://liuzmd1.pixnet.net/blog/3
    // 如果加輔助字根有候選字，輔助字根無效
    func handleAssistChar(_ inputStr: String, _ sender: Any!) -> Bool {
        if isZhuyinMode {
            return false
        }
        // 在完全匹配模式下先檢查加上這個字碼後有沒有對應字元，若有就不進入輔助字根機制
        if SettingViewModel.shared.showOnlyExactlyMatch {
            let newPhrases = InputEngine.shared.getNormalModePhrase(InputContext.shared.getCurrentInput() + inputStr)
            if !newPhrases.isEmpty {
                // 直接在這輸入字元，以免要多查找一次coredata
                InputContext.shared.appendCurrentInput(inputStr)
                setMarkedText(InputContext.shared.getCurrentInput())
                InputEngine.shared.setCandidates(newPhrases, inputStr)
                showCandidatesWindow(client: sender)
                return true
            }
        }
        if assistSelectChar.chr.isEmpty,
           !(InputContext.shared.preInputPrefixSet.contains(InputContext.shared.getCurrentInput() + inputStr)),
           InputContext.shared.candidatesCount > 0 {
            if let idx = assistantDict[inputStr] {
                assistSelectChar = (chr: inputStr, pos: InputContext.shared.getCurrentInput().count)
                if idx >= InputContext.shared.candidatesCount {
                    if !SettingViewModel.shared.showOnlyExactlyMatch {
                        beep()
                        return true
                    }
                    // 如果是完全匹配模式，而idx超過候選字代表這個字不是輔助字根
                    clearAssistSelectChar()
                    return false
                }
                let prevIdx = InputContext.shared.currentIndex
                InputContext.shared.currentIndex = idx
                let isHorizontalCandidatesPanel = SettingViewModel.shared.isHorizontalCandidatesPanel
                if prevIdx < idx {
                    for _ in prevIdx ... idx - 1 {
                        if isHorizontalCandidatesPanel {
                            candidates.moveRight(sender)
                        } else {
                            candidates.moveDown(sender)
                        }
                    }
                } else if prevIdx > idx {
                    for _ in idx ... prevIdx - 1 {
                        if isHorizontalCandidatesPanel {
                            candidates.moveLeft(sender)
                        } else {
                            candidates.moveUp(sender)
                        }
                    }
                }
                InputContext.shared.appendCurrentInput(inputStr)
                setMarkedText(InputContext.shared.getCurrentInput())
                return true
            }
        }
        return false
    }

    func checkIsCapslock(event: NSEvent) -> Bool {
        // toggle ascii mode
        if event.type == .flagsChanged, event.keyCode == 57 {
            DispatchQueue.main.async { [self] in
                let shouldNotifyCpLkState = CapsLockToggler.isOn
                isASCIIMode = event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(.capsLock)
                // 在isASCIIMode改變時推播通知
                NotifierController.notify(message: shouldNotifyCpLkState ? "英數模式" : "中文模式")
                setKeyLayout()
                if isASCIIMode {
                    if !InputContext.shared.getCurrentInput().isEmpty {
                        commitText(client: client(), text: InputContext.shared.getCurrentInput())
                        InputContext.shared.cleanUp()
                    }
                }
            }
            return true
        }
        return false
    }

    // ascii mode處理開啟capslock的情況
    func capslockHandler(event: NSEvent, text: String, client sender: Any!) -> Bool {
        // 如果按著shift則可直接輸出大寫字母
        if event.modifierFlags.contains(.shift) {
            return false
        }
        commitText(client: sender, text: text.lowercased())
        return true
    }

    func spcHandler(client sender: Any!) -> Bool {
        if InputContext.shared.candidatesCount > 0 {
            // commit the input
            commitCandidate(client: sender)
        } else if InputContext.shared.getCurrentInput().isEmpty {
            // do nothing if composed string isn't empty
            return false
        }
        return true
    }

    func deleteHandler() -> Bool {
        if !InputContext.shared.getCurrentInput().isEmpty {
            InputContext.shared.deleteLastOfCurrentInput()
            // 如果是注音模式，則在composition清空時關閉注音模式。
            if isZhuyinMode || isTypeByPronunciationMode, InputContext.shared.getCurrentInput().isEmpty {
                setMarkedText("")
                isZhuyinMode = false
                turnOffIsInputByPronunciationMode()
            }
            // 處理輔助選字
            if !assistSelectChar.chr.isEmpty,
               InputContext.shared.getCurrentInput().count == assistSelectChar.pos {
                clearAssistSelectChar()
            }
            if InputContext.shared.getCurrentInput().isEmpty {
                cleanComposition()
                return true
            }
            setMarkedText(InputContext.shared.getCurrentInput())
            updateCandidatesWindow()
            return true
        }
        return false
    }

    // 如果currentInput為空就直接pass esc事件，讓系統處理
    func escHandler() -> Bool {
        if !InputContext.shared.getCurrentInput().isEmpty || isZhuyinMode || isTypeByPronunciationMode {
            cleanComposition()
            return true
        }
        return false
    }

    // 處理使用數字鍵選字
    func handleSelectCandidatesByNum(_ keyValue: Int, client sender: Any!) -> Bool {
        let selectCandidateBy1to8 = UserDefaults.standard.bool(forKey: "selectCandidateBy1to8")
        var inputIndex: Int = selectCandidateBy1to8 ? (keyValue - 1) : keyValue
        inputIndex += InputContext.shared.candidatesPageId * 9
        if inputIndex > InputContext.shared.candidatesCount {
            return true
        }
        return selectCandidatesByNumAndCommit(client: sender, id: inputIndex)
    }

    // 全形模式開關 shift+空白鍵
    func checkIsToggleFullWidthMode(event: NSEvent) -> Bool {
        if event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .shift, event.keyCode == 49 {
            isFullWidthMode.toggle()
            NotifierController.notify(message: isFullWidthMode ? "全形模式" : "半形模式")
            return true
        }
        return false
    }

    func handleCandidatesWindowNavigation(_ event: NSEvent, client sender: Any!) -> Bool {
        if let key = event.characters?.first {
            if key == "<" {
                if SettingViewModel.shared.isHorizontalCandidatesPanel {
                    candidates.moveUp(sender)
                } else {
                    candidates.moveLeft(sender)
                }
                InputContext.shared.movePrevPage()
                return true
            } else if key == ">" {
                if SettingViewModel.shared.isHorizontalCandidatesPanel {
                    candidates.moveDown(sender)
                } else {
                    candidates.moveRight(sender)
                }
                InputContext.shared.moveNextPage()
                return true
            }
        }
        // 即使已經在最左或最右也要攔截左﹑右方向鍵事件。否則輸入法會在再次按下方向鍵時卡死
        var isArrow = false
        if event.keyCode == kVK_RightArrow {
            candidates.moveRight(sender)
            InputContext.shared.handleRight()
            isArrow = true
        } else if event.keyCode == kVK_LeftArrow {
            candidates.moveLeft(sender)
            InputContext.shared.handleLeft()
            isArrow = true
        } else if event.keyCode == kVK_UpArrow {
            candidates.moveUp(sender)
            InputContext.shared.handleUp()
            isArrow = true
        } else if event.keyCode == kVK_DownArrow {
            candidates.moveDown(sender)
            InputContext.shared.handleDown()
            isArrow = true
        }
        return isArrow
    }

    func checkIsCapslockOn() {
        let result = NSEvent.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(.capsLock)
        isASCIIMode = result
    }
}
