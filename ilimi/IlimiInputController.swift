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
    var isZhuyinMode: Bool = false
    let puntuationSet: Set<Character> = [",", "'", ";", ".", "[", "]", "(", ")"]
    // 輔助選字的字典
    let assistantDict: [String: Int] = ["v": 1, "r": 2, "s": 3, "f": 4, "w": 5, "l": 6, "c": 7, "b": 8]
    
    override init!(server: IMKServer!, delegate: Any!, client inputClient: Any!) {
        // 橫式候選字窗
        candidates = IMKCandidates(server: server, panelType: kIMKScrollingGridCandidatePanel)
        var attributes = candidates.attributes()
        let font = NSFont.systemFont(ofSize: 22)
        attributes?[NSAttributedString.Key.font] = font
        // 若只設attributes無法調整字體大小
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
        client.overrideKeyboard(withKeyboardNamed: "BasicKeyboardLayout")
    }

    func checkIsTradToSimToggle(input: String) -> Bool {
        if input == ",,CT" {
            InputContext.shared.isTradToSim.toggle()
            cancelComposition()
            return true
        }
        return false
    }

    func getZhuyinMarkedText(_ text: String) -> String {
        return "注" + StringConverter.shared.keyToZhuyins(text)
    }

    // 嘗試實作https://github.com/gureum/gureum/issues/843
    func ensureWindowLevel(client sender: Any!) {
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
//        client().insertText(text, replacementRange: NSMakeRange(0, text.count))
        client().insertText(text, replacementRange: NSMakeRange(NSNotFound, NSNotFound))
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
}
