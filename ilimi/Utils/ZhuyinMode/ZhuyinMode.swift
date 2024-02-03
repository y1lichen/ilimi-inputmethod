//
//  ZhuyinMode.swift
//  ilimi
//
//  Created by 陳奕利 on 2023/9/3.
//

extension IlimiInputController {
    // 把輸入碼轉成注音碼
    func getZhuyinMarkedText(_ text: String) -> String {
        return "注" + StringConverter.shared.keyToZhuyins(text)
    }

    // 輸入';進入注音模式
    func checkIsZhuyinMode(_ input: String) -> Bool {
        let hadReadPinyin = UserDefaults.standard.object(forKey: "hadReadPinyinJson") as? Bool ?? false
        if (!hadReadPinyin) {
            // 沒有注音檔的話提示使用者
            NotifierController.notify(message: "請下載並匯入注音檔", stay: true)
            return false
        }
        isZhuyinMode = (input == "';")
        if isZhuyinMode {
            InputContext.shared.cleanUp()
            candidates.hide()
            client().setMarkedText("注", selectionRange: notFoundRange, replacementRange: notFoundRange)
            return true
        }
        return false
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
}
