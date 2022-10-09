//
//  IlimiControllerEventHandler.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/23.
//

extension IlimiInputController {
    
    // IMK預設不會recognize flagsChanged事件
    override func recognizedEvents(_ sender: Any!) -> Int {
        let events: NSEvent.EventTypeMask = [.keyDown, .flagsChanged]
        return Int(events.rawValue)
    }
    
    override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        guard let event = event, sender is IMKTextInput else {
            cancelComposition()
            NSLog("Unable to handle NSEvent")
            return false
        }
        // check if capslock is pressed
        if checkIsCapslock(event: event) {
            return false
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
            let inputStr = event.characters!
            let key = inputStr.first!
            if event.keyCode == kVK_Space {
                return spcHandler(client: sender)
            }
            // 選字窗出現時
            if candidates.isVisible() {
                // 使用數字鍵選字
                if (!isZhuyinMode && key.isNumber) || (isZhuyinMode && checkIsEndOfZhuyin(text: InputContext.shared.currentInput) && key.isNumber) {
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
            } else if event.keyCode == kVK_Return && InputContext.shared.currentInput.count > 0 {
                commitText(client: sender, text: InputContext.shared.currentInput)
                cancelComposition()
                return true
            }
            if key.isLetter || puntuationSet.contains(key) || (isZhuyinMode && (key.isNumber || key.isPunctuation)) || key == "\\" {
//                NSLog("\(key)")
                //
                if isASCIIMode {
                    return capslockHandler(event: event, text: inputStr, client: sender)
                }
                // 字根最多只有5碼
                if (InputContext.shared.currentInput.count >= 5 || !IlimiInputController.prefixHasCandidates) && InputContext.shared.currentInput.prefix(2) != ",," && InputContext.shared.currentInput.prefix(2) != "';" {
                    NSSound.beep()
                    return true
                }
                // 關閉括弧
                if key == "]" {
                    if let closure = InputContext.shared.getClosingClosure() {
                        commitText(client: sender, text: closure)
                        return true
                    }
                }
                // 加到composition
                InputContext.shared.currentInput.append(inputStr)
                // \ -> 同音輸入模式
                if !isTypeByPronunciationMode && checkIsInputByPronunciationMode(InputContext.shared.currentInput) {
                    return true
                }
                // '; -> 注音模式
                if !isZhuyinMode && checkIsZhuyinMode(InputContext.shared.currentInput) {
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
    
    func checkIsCapslock(event: NSEvent) -> Bool {
        // toggle ascii mode
        if event.type == .flagsChanged && event.keyCode == 57 {
            DispatchQueue.main.async { [self] in
                let capsLockIsOn = event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(.capsLock)
                // 在isASCIIMode改變時推播通知
                if self.isASCIIMode != capsLockIsOn {
                    NotifierController.notify(message: capsLockIsOn ? "英數模式" : "中文模式")
                }
                self.isASCIIMode = capsLockIsOn
                setKeyLayout()
                if self.isASCIIMode {
                    if !InputContext.shared.currentInput.isEmpty {
                        commitText(client: client(), text: InputContext.shared.currentInput)
                        InputContext.shared.cleanUp()
                    }
                }
            }
            return true
        }
        return false
    }
    
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
        } else if InputContext.shared.currentInput.isEmpty {
            // do nothing if composed string isn't empty
            return false
        }
        return true
    }
    
    func deleteHandler() -> Bool {
        if InputContext.shared.currentInput.count > 0 {
            InputContext.shared.currentInput.removeLast()
            let range = NSMakeRange(NSNotFound, NSNotFound)
            // 如果是注音模式，則在composition清空時關閉注音模式。
            if (isZhuyinMode || isTypeByPronunciationMode) && InputContext.shared.currentInput.count == 0 {
                client().setMarkedText("", selectionRange: range, replacementRange: range)
                isZhuyinMode = false
                turnOffIsInputByPronunciationMode()
            }
            if InputContext.shared.currentInput.count == 0 {
                cancelComposition()
                return true
            }
            client().setMarkedText(InputContext.shared.currentInput, selectionRange: range, replacementRange: range)
            updateCandidatesWindow()
            return true
        }
        return false
    }

    // 如果currentInput為空就直接pass esc事件，讓系統處理
    func escHandler() -> Bool {
        if InputContext.shared.currentInput.count > 0 || isZhuyinMode || isTypeByPronunciationMode {
            cancelComposition()
            return true
        }
        return false
    }
    
    func handleSelectCandidatesByNum(_ keyValue: Int, client sender: Any!) -> Bool {
        if keyValue > InputContext.shared.candidatesCount {
            return true
        }
        if InputContext.shared.candidatesPageId == 0 {
            return selectCandidatesByNumAndCommit(client: sender, id: keyValue - 1)
        } else {
            // 選字窗展開時只有5個候選字
            if keyValue > 5 {
                return false
            }
            let selectedId = ((InputContext.shared.candidatesPageId - 1) * 5) + keyValue - 1
            return selectCandidatesByNumAndCommit(client: sender, id: selectedId)
        }
    }

    func handleCandidatesWindowNavigation(_ event: NSEvent, client sender: Any!) -> Bool {
        if let key = event.characters?.first {
            if key == "[" {
                candidates.moveUp(sender)
                return true
            } else if key == "]" {
                candidates.moveDown(sender)
                return true
            }
        }
        // 即使已經在最左或最右也要攔截左﹑右方向鍵事件。否則輸入法會在再次按下方向鍵時卡死
        var isArrow = false
        if event.keyCode == kVK_RightArrow {
            if InputContext.shared.currentIndex < InputContext.shared.candidatesCount - 1 {
                InputContext.shared.currentIndex += 1
                candidates.moveRight(sender)
            }
            isArrow = true
        } else if event.keyCode == kVK_LeftArrow {
            if InputContext.shared.currentIndex > 0 {
                InputContext.shared.currentIndex -= 1
                candidates.moveLeft(sender)
            }
            isArrow = true
        } else if event.keyCode == kVK_UpArrow {
            candidates.moveUp(sender)
            if InputContext.shared.candidatesPageId > 0 {
                if InputContext.shared.candidatesPageId > 1 {
                    InputContext.shared.currentIndex -= 5
                }
                InputContext.shared.candidatesPageId -= 1
            }
            isArrow = true
        } else if event.keyCode == kVK_DownArrow {
            candidates.moveDown(sender)
            if InputContext.shared.candidatesPageId < InputContext.shared.candidatesPagesCount {
                if InputContext.shared.candidatesPageId > 0 {
                    InputContext.shared.currentIndex += 5
                }
                InputContext.shared.candidatesPageId += 1
            }
            isArrow = true
        }
        return isArrow
    }
}
