// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import Foundation

class InputContext {
    // MARK: Internal

    static let shared = InputContext()

    let closureDict: [String: String] = [
        "「": "」",
        "（": "）",
        "﹁": "﹂",
        "﹃": "﹄",
        "【": "】",
        "︻": "︼",
        "︵": "︶",
        "〈": "〉",
        "『": "』",
        "《": "》",
        "︽": "︾",
        "«": "»",
    ]
    var currentIndex: Int = 0
    var candidatesCount = 0

    var preInputPrefixSet: Set<String> = []
    // 當前候選字頁碼
    var candidatesPageId = 0
    var candidatesPagesCount = 0
    var closureStack: [String] = []

    var isTradToSim = false {
        didSet {
            NotifierController.notify(message: isTradToSim ? "開啟打繁出簡" : "關閉打繁出簡")
        }
    }

    var isSpMode = false {
        didSet {
            NotifierController.notify(message: isSpMode ? "開啟快打模式" : "關閉快打模式")
        }
    }

    var candidates: [String] {
        get { _candidates }
        set {
            _candidates = newValue
            candidatesCount = _candidates.count
            IlimiInputController.prefixHasCandidates = (candidatesCount > 0) ? true : false
            _numberedCandidates = []
            for i in 0 ..< _candidates.count {
                _numberedCandidates.append("\(i + 1) \(_candidates[i])")
            }
            candidatesPagesCount = candidatesCount % 9 > 0 ? (candidatesCount / 9) + 1 : candidatesCount / 9
        }
    }

    var numberedCandidates: [String] {
        _numberedCandidates
    }

    var currentNumberedCandidate: String {
        if currentIndex >= 0, currentIndex < _numberedCandidates.count {
            return _numberedCandidates[currentIndex]
        }
        return ""
    }

    func getClosingClosure() -> String? {
        if currentInput.isEmpty, !closureStack.isEmpty {
            let closure = closureStack.removeLast()
            if let closingClosure = closureDict[closure] {
                return closingClosure
            }
        }
        return nil
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
        closureDict[input] != nil
    }

    func appendCurrentInput(_ inputStr: String) {
        currentInput.append(inputStr)
    }

    func getCurrentInput() -> String {
        currentInput
    }

    func deleteLastOfCurrentInput() {
        currentInput.removeLast()
    }

    func moveNext() {
        if currentIndex < candidatesCount - 1 {
            currentIndex += 1
        }
    }

    func movePrev() {
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }

    func movePrevPage() {
        if candidatesPageId > 0 {
            candidatesPageId -= 1
            currentIndex -= 9
        }
    }

    func moveNextPage() {
        if candidatesPageId < candidatesPagesCount - 1 {
            candidatesPageId += 1
        }
        if 9 * candidatesPageId + currentIndex >= candidatesCount {
            currentIndex = candidatesCount - 1
        } else {
            currentIndex = 9 * candidatesPageId + currentIndex
        }
    }

    // 直式選字窗比較複雜，不處理
    func handleRight() {
        if SettingViewModel.shared.isHorizontalCandidatesPanel {
            moveNext()
        }
    }

    func handleLeft() {
        if SettingViewModel.shared.isHorizontalCandidatesPanel {
            movePrev()
        }
    }

    func handleUp() {
        if SettingViewModel.shared.isHorizontalCandidatesPanel {
            movePrevPage()
        }
    }

    func handleDown() {
        if SettingViewModel.shared.isHorizontalCandidatesPanel {
            moveNextPage()
        }
    }

    // MARK: Private

    private var currentInput: String = ""
    private var _candidates: [String] = []
    private var _numberedCandidates: [String] = []
}
