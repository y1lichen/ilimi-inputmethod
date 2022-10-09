//  IlimiInputController.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/5.
//

import Cocoa
import InputMethodKit

@objc(IlimiInputController)
class IlimiInputController: IMKInputController {
    let candidates: IMKCandidates
    static var prefixHasCandidates: Bool = true
    let notFoundRange = NSMakeRange(NSNotFound, NSNotFound)
    // 注音輸入模式
    var isZhuyinMode: Bool = false
    // 同音輸入模式
    var isTypeByPronunciationMode = false
    var isSecondCommitOfTypeByPronunciationMode = false
    //
    let puntuationSet: Set<Character> = [",", "'", ";", ".", "[", "]", "(", ")"]
    // 輔助選字的字典
    let assistantDict: [String: Int] = ["v": 1, "r": 2, "s": 3, "f": 4, "w": 5, "l": 6, "c": 7, "b": 8]
    var isASCIIMode: Bool = false

    override init!(server: IMKServer!, delegate: Any!, client inputClient: Any!) {
        // 橫式候選字窗
        candidates = IMKCandidates(server: server, panelType: kIMKScrollingGridCandidatePanel)
        var attributes = candidates.attributes()
        let font = NSFont.systemFont(ofSize: 22)
        attributes?[NSAttributedString.Key.font] = font
        // 若只設attributes無法調整字體大小，setFontSize方法使用bridging header暴露出來
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
        // 同步ascii模式狀態
        checkIsCapslockOn()
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

    override func selectionRange() -> NSRange {
        return notFoundRange
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
        client().setMarkedText("", selectionRange: NSMakeRange(0, 0), replacementRange: notFoundRange)
        InputContext.shared.cleanUp()
        candidates.update()
        candidates.hide()
        IlimiInputController.prefixHasCandidates = true
        // 如果是注音模式則關閉注音模式
        isZhuyinMode = false
        // 如果是同音輸入模式則關閉同音輸入模式
        turnOffIsInputByPronunciationMode()
        super.cancelComposition()
    }
}

extension IlimiInputController {
    func turnOffIsInputByPronunciationMode() {
        isTypeByPronunciationMode = false
        isSecondCommitOfTypeByPronunciationMode = false
    }
    
    // 輸入\進入同音輸入模式
    func checkIsInputByPronunciationMode(_ input: String) -> Bool {
        isTypeByPronunciationMode = (input == "\\")
        if isTypeByPronunciationMode {
            InputContext.shared.cleanUp()
            client().setMarkedText("音", selectionRange: notFoundRange, replacementRange: notFoundRange)
            return true
        }
        return false
    }
    
    // 輸入';進入注音模式
    func checkIsZhuyinMode(_ input: String) -> Bool {
        isZhuyinMode = (input == "';")
        if isZhuyinMode {
            InputContext.shared.cleanUp()
            candidates.hide()
            client().setMarkedText("注", selectionRange: notFoundRange, replacementRange: notFoundRange)
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

    // 輸入,,CT進入打繁出簡模式
    func checkIsTradToSimToggle(input: String) -> Bool {
        if input == ",,CT" {
            InputContext.shared.isTradToSim.toggle()
            cancelComposition()
            return true
        }
        return false
    }

    // 把輸入碼轉成注音碼
    func getZhuyinMarkedText(_ text: String) -> String {
        return "注" + StringConverter.shared.keyToZhuyins(text)
    }

    // 嘗試實作https://github.com/gureum/gureum/issues/843
    func ensureWindowLevel(client sender: Any!) {
        while candidates.windowLevel() <= client().windowLevel() {
            candidates.setWindowLevel(UInt64(max(0, client().windowLevel() + 1000)))
        }
    }

    // 取得同音輸入模式的同音候選字
    func getNewCandidatesOfSamePronunciation(text: String, client sender: Any!) {
        InputEngine.shared.getCandidatesByPronunciation(text)
        if InputContext.shared.candidatesCount > 0 {
            isSecondCommitOfTypeByPronunciationMode = true
            candidates.update()
            candidates.show()
            ensureWindowLevel(client: sender)
        } else {
            // 沒有同音字時直接輸入該文字
            client().insertText(text, replacementRange: NSMakeRange(0, 2))
            turnOffIsInputByPronunciationMode()
            InputContext.shared.cleanUp()
            candidates.hide()
        }
    }

    // 取得注音輸入的候選字
    func getNewCandidatesByZhuyin(comp: String, client sender: Any!) {
        if comp.count > 0 {
            InputEngine.shared.getCadidatesByZhuyin(comp)
            if InputContext.shared.candidatesCount <= 0 {
                candidates.hide()
                return
            }
            candidates.update()
            candidates.show()
            ensureWindowLevel(client: sender)
        } else {
            candidates.hide()
        }
    }

    // 注音輸入的最後一碼是聲調
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
            ensureWindowLevel(client: sender)
        } else {
            candidates.hide()
        }
    }

    func updateCandidatesWindow() {
        guard let client = client() else { return }
        let comp = InputContext.shared.currentInput
        if isZhuyinMode {
            client.setMarkedText(getZhuyinMarkedText(comp), selectionRange: notFoundRange, replacementRange: notFoundRange)
            getNewCandidatesByZhuyin(comp: comp, client: client)
        } else {
            if isTypeByPronunciationMode && !isSecondCommitOfTypeByPronunciationMode {
                client.setMarkedText("音" + comp, selectionRange: notFoundRange, replacementRange: notFoundRange)
            } else {
                client.setMarkedText(comp, selectionRange: notFoundRange, replacementRange: notFoundRange)
            }
            getNewCandidates(comp: comp, client: client)
        }
    }

    func commitText(client sender: Any!, text: String) {
//        client().insertText(text, replacementRange: NSMakeRange(0, text.count))
        client().insertText(text, replacementRange: notFoundRange)
        cancelComposition()
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
        } else if isSecondCommitOfTypeByPronunciationMode {
            // 同音模式下，第二次選定候選字
            client().insertText(candidate, replacementRange: NSMakeRange(0, 2))
            turnOffIsInputByPronunciationMode()
        } else if isTypeByPronunciationMode {
            // 同音模式下，第一次選字候選字
            client().setMarkedText("音" + candidate, selectionRange: notFoundRange, replacementRange: notFoundRange)
            InputContext.shared.cleanUp()
            getNewCandidatesOfSamePronunciation(text: candidate, client: sender)
            return
        } else {
            client().insertText(candidate, replacementRange: NSMakeRange(0, comp.count))
            // 如果輸出的字元是括弧的左部，則添加到closureStack
            if InputContext.shared.isClosure(input: candidate) {
                InputContext.shared.closureStack.append(candidate)
            }
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

    // 依照威注音註解，此函式可能因IMK的bug而不會被執行
    // https://github.com/vChewing/vChewing-macOS/blob/main/Source/Modules/ControllerModules/ctlInputMethod_Core.swift
    override func inputControllerWillClose() {
        cancelComposition()
        super.inputControllerWillClose()
    }
    
    func checkIsCapslockOn() {
        let result = NSEvent.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(.capsLock)
        self.isASCIIMode = result
    }
}
