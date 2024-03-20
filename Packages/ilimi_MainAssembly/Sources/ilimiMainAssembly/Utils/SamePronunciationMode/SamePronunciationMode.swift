// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import Foundation

extension IlimiInputController {
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
            client().insertText(text, replacementRange: NSRange(location: 0, length: 2))
            turnOffIsInputByPronunciationMode()
            // 提示使用者
            NotifierController.notify(message: "沒有其他同音字")
            InputContext.shared.cleanUp()
            candidates.hide()
        }
    }
}
