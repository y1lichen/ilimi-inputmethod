//
//  InputContext.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/6.
//

import Foundation

class InputContext {
    static let shared = InputContext()
    let closureDict: [String: String] = ["「": "」", "（": "）",
                                         "【": "】", "〈": "〉",
                                         "『": "』", "《": "》",
                                         "«": "»"]
    var isTradToSim: Bool = false {
        didSet {
            NotifierController.notify(message: isTradToSim ? "開啟打繁出簡" : "關閉打繁出簡")
        }
    }

    private var currentInput: String = ""
    var currentIndex: Int = 0
    var candidatesCount = 0
    var candidatesPagesCount = 0
    var preInputPrefixSet: Set<String> = []
    private var _candidates: [String] = []
    private var _numberedCandidates: [String] = []
    // 當前候選字頁碼
    var candidatesPageId = 0
    var candidates: [String] {
        get { return _candidates }
        set {
            _candidates = newValue
            candidatesCount = _candidates.count
            IlimiInputController.prefixHasCandidates = (candidatesCount > 0) ? true : false
            _numberedCandidates = []
            for i in 0 ..< _candidates.count {
                _numberedCandidates.append("\(i + 1) \(_candidates[i])")
            }
            candidatesPagesCount = candidatesCount % 5 > 0 ? (candidatesCount / 5) + 1 : candidatesCount / 5
        }
    }

    var closureStack: [String] = []
    func getClosingClosure() -> String? {
        if currentInput.isEmpty && !closureStack.isEmpty {
            let closure = closureStack.removeLast()
            if let closingClosure = closureDict[closure] {
                return closingClosure
            }
        }
        return nil
    }

    var numberedCandidates: [String] {
        return _numberedCandidates
    }

    var currentNumberedCandidate: String {
        if currentIndex >= 0 && currentIndex < _numberedCandidates.count {
            return _numberedCandidates[currentIndex]
        }
        return ""
    }

    func cleanUp() {
        currentIndex = 0
        currentInput = ""
        preInputPrefixSet = []
        candidates = []
        candidatesPageId = 0
        IlimiInputController.prefixHasCandidates = true
    }

    func isClosure(input: String) -> Bool {
        return (closureDict[input] != nil)
    }

    func appendCurrentInput(_ inputStr: String) {
        currentInput.append(inputStr)
    }

    func getCurrentInput() -> String {
        return currentInput
    }

    func deleteLastOfCurrentInput() {
        currentInput.removeLast()
    }
}
