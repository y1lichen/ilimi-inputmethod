// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import Cocoa
import IMKCandidatesImpl
import IMKUtils
import InputMethodKit

// MARK: - IlimiInputController

@objc(IlimiInputController)
public class IlimiInputController: IMKInputController {
    // MARK: Lifecycle

    override init!(server: IMKServer!, delegate: Any!, client inputClient: Any!) {
        // 候選字窗
        let isHorizontalCandidates = UserDefaults.standard.bool(forKey: "isHorizontalCandidatesPanel")
        self.candidates = IMKCandidates(
            server: server,
            panelType: isHorizontalCandidates
                ? kIMKScrollingGridCandidatePanel : kIMKSingleColumnScrollingCandidatePanel
        )
        var attributes = candidates.attributes()
        let fontSize = UserDefaults.standard.integer(forKey: "fontSize")
        let font = NSFont.systemFont(ofSize: CGFloat(fontSize))
        attributes?[NSAttributedString.Key.font] = font
        // 若只設attributes無法調整字體大小，setFontSize方法使用bridging header暴露出來
        candidates.setFontSize(font.pointSize)
        super.init(server: server, delegate: delegate, client: inputClient)
        activateServer(inputClient ?? client())
    }

    // MARK: Public

    override public func activateServer(_ sender: Any!) {
//        guard sender is IMKTextInput else {
//            return
//        }
        super.activateServer(sender)
        DispatchQueue.main.async { [self] in
            InputContext.shared.cleanUp()
            candidates.hide()
        }
        // 同步ascii模式狀態
        DispatchQueue.main.async { [self] in
            checkIsCapslockOn()
        }
        DispatchQueue.main.async { [self] in
            setKeyLayout()
        }
    }

    override public func deactivateServer(_ sender: Any!) {
//        guard sender is IMKTextInput else {
//            return
//        }
        DispatchQueue.main.async { [self] in
            cancelComposition()
        }
        super.deactivateServer(sender)
    }

    override public func selectionRange() -> NSRange {
        notFoundRange
    }

    override public func candidates(_ sender: Any!) -> [Any]! {
        InputContext.shared.candidates
    }

    override public func candidateSelected(_ candidateString: NSAttributedString!) {
        let id = findCandidateIndex(candidateString)
        NSLog("id: \(id), candidate: \(candidateString.string)")
        InputContext.shared.currentIndex = id
        commitCandidate(client: client())
    }

    // 參考威注音 不實作該函式
    // 詳見https://github.com/vChewing/vChewing-macOS/blob/main/Source/Modules/ControllerModules/ctlInputMethod_Core.swift
    //
    // 現在看起來沒問題了，實作函式 2023/09/06 17:44:54
    override public func candidateSelectionChanged(_ candidateString: NSAttributedString!) {
        let id = findCandidateIndex(candidateString)
        InputContext.shared.currentIndex = id
    }

    // 依照威注音註解，此函式可能因IMK的bug而不會被執行
    // https://github.com/vChewing/vChewing-macOS/blob/main/Source/Modules/ControllerModules/ctlInputMethod_Core.swift
    override public func inputControllerWillClose() {
        cancelComposition()
        super.inputControllerWillClose()
    }

    override public func cancelComposition() {
        setMarkedText("", selectionRange: NSRange(location: 0, length: 0))
        InputContext.shared.cleanUp()
        candidates.update()
        candidates.hide()
        Self.prefixHasCandidates = true
        // 如果是注音模式則關閉注音模式
        isZhuyinMode = false
        // 如果是同音輸入模式則關閉同音輸入模式
        turnOffIsInputByPronunciationMode()
        clearAssistSelectChar()
        super.cancelComposition()
    }

    // MARK: Internal

    static var prefixHasCandidates = true

    let candidates: IMKCandidates
    let notFoundRange = NSRange(location: NSNotFound, length: NSNotFound)
    // 注音輸入模式
    var isZhuyinMode = false
    // 同音輸入模式
    var isTypeByPronunciationMode = false
    var isSecondCommitOfTypeByPronunciationMode = false
    // 全形模式
    var isFullWidthMode = false
    //
    let puntuationSet: Set<Character> = [",", "'", ";", ".", "[", "]", "(", ")"]
    // 輔助選字的字典
    let assistantDict: [String: Int] = ["v": 1, "r": 2, "s": 3, "f": 4, "w": 5, "l": 6, "c": 7, "b": 8]
    // 英數模式
    var isASCIIMode = false
    // 輔助選字的字元和位置
    var assistSelectChar = (chr: "", pos: -1)

    func findCandidateIndex(_ candidateString: NSAttributedString!) -> Int {
        InputContext.shared.candidates.firstIndex(of: candidateString.string) ?? -1
    }
}

extension IlimiInputController {
    func clearAssistSelectChar() {
        assistSelectChar = ("", -1)
    }

    func turnOffIsInputByPronunciationMode() {
        isTypeByPronunciationMode = false
        isSecondCommitOfTypeByPronunciationMode = false
    }

    var clientBundleIdentifier: String {
        guard let client = client() else { return "" }
        return client.bundleIdentifier() ?? ""
    }

    // 如果不setKeyLayout，在spotlight會無法輸入
    func setKeyLayout() {
        guard let client = client() else { return }
        Task {
            client.overrideKeyboard(
                withKeyboardNamed: LatinKeyboardMappings.qwertyIlimi.rawValue
            )
        }
    }

    // 輸入,,CT進入打繁出簡模式
    func checkIsTradToSimToggle(_ input: String) -> Bool {
        // 輸入,,t可關閉打繁出簡
        if input == ",,t" {
            InputContext.shared.isTradToSim = false
            cancelComposition()
            return true
        }
        // 輸入,,ct可開啟/關閉打繁出簡
        if input == ",,ct" {
            InputContext.shared.isTradToSim.toggle()
            cancelComposition()
            return true
        }
        return false
    }

    // 嘗試實作https://github.com/gureum/gureum/issues/843
//    func ensureWindowLevel(client sender: Any!) {
//        while candidates.windowLevel() <= client().windowLevel() {
//            candidates.setWindowLevel(UInt64(max(0, client().windowLevel() + 1000)))
//        }
//    }
    // https://github.com/y1lichen/ilimi-inputmethod/issues/3
    // 依照ShikiSuen見議
    func ensureWindowLevel(client sender: Any!) {
        candidates.setWindowLevel(UInt64(CGShieldingWindowLevel() + 2))
    }

    func getNewCandidates(comp: String, client sender: Any!) {
        if !comp.isEmpty {
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
        let comp = InputContext.shared.getCurrentInput()
        if isZhuyinMode {
            setMarkedText(getZhuyinMarkedText(comp))
            getNewCandidatesByZhuyin(comp: comp, client: client)
        } else {
            if isTypeByPronunciationMode, !isSecondCommitOfTypeByPronunciationMode {
                setMarkedText("音" + comp)
            } else {
                setMarkedText(comp)
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
        let comp = InputContext.shared.getCurrentInput()
        let id = InputContext.shared.currentIndex
        if id < 0 || id >= InputContext.shared.candidatesCount {
            return
        }
        var candidate = InputContext.shared.candidates[id]
        if InputContext.shared.isTradToSim {
            candidate = StringConverter.shared.simplify(candidate)
        }
		if isZhuyinMode {
			client().insertText(candidate, replacementRange: NSRange(location: 0, length: comp.count + 1))
			isZhuyinMode = false
			// 以通知窗顯示蝦米拆碼
			let showTips = UserDefaults.standard.bool(forKey: "showLiuKeyAfterZhuyin")
			if showTips {
				let keys = CoreDataHelper.getKeyOfChar(candidate)
				NotifierController.notify(message: candidate + "：" + keys.joined(separator: " "), stay: true)
			}
        } else if isSecondCommitOfTypeByPronunciationMode {
            // 同音模式下，第二次選定候選字
            client().insertText(candidate, replacementRange: NSRange(location: 0, length: 2))
            turnOffIsInputByPronunciationMode()
        } else if isTypeByPronunciationMode {
            // 同音模式下，第一次選字候選字
            setMarkedText("音" + candidate)
            InputContext.shared.cleanUp()
            getNewCandidatesOfSamePronunciation(text: candidate, client: sender)
            return
        } else {
            client().insertText(candidate, replacementRange: NSRange(location: 0, length: comp.count))
            // 如果輸出的字元是括弧的左部，則添加到closureStack
            if InputContext.shared.isClosure(input: candidate) {
                InputContext.shared.closureStack.append(candidate)
            }
        }
        InputContext.shared.cleanUp()
        clearAssistSelectChar()
        updateCandidatesWindow()
    }

    func selectCandidatesByNumAndCommit(client sender: Any!, id: Int) -> Bool {
        if id >= 0, id < InputContext.shared.candidatesCount {
            InputContext.shared.currentIndex = id
            commitCandidate(client: sender)
            return true
        }
        return false
    }

    func setMarkedText(
        _ markedText: String,
        selectionRange: NSRange = NSRange(location: NSNotFound, length: NSNotFound),
        replacementRange: NSRange = NSRange(location: NSNotFound, length: NSNotFound)
    ) {
        guard let client = client() else { return }
        client.setMarkedText(markedText, selectionRange: selectionRange, replacementRange: replacementRange)
    }
}
