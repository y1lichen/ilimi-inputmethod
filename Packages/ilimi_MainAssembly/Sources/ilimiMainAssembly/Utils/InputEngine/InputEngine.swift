// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import AppKit
import CoreData
import Foundation
import SwiftUI

struct InputEngine {
    static let shared = InputEngine()

    // 取得以注音輸入的候選字
    func getCadidatesByZhuyin(_ text: String) {
        InputContext.shared.candidates = CoreDataHelper.getCharByZhuyin(text)
    }

    func setCandidates(_ phrases: [Phrase], _ text: String) {
        var candidates: [String] = []
        var candidatesSet: Set<String> = []
        var inputStrSet: Set<String> = []

        for r in phrases {
            let value: String = r.value(forKey: "value") as! String
            if let rKey = r.key, rKey.count > text.count {
                inputStrSet.insert(String(rKey.prefix(text.count + 1)))
            }
            if candidatesSet.contains(value) {
                continue
            }
            candidatesSet.insert(value)
            candidates.append(value)
        }
        // 自定義的字詞
        let customPhrases = CustomPhraseManager.getCustomPhraseByKey(text)
        for c in customPhrases {
            guard let phraseValue = c.value else { return }
            candidates.append(phraseValue)
            candidatesSet.insert(phraseValue)
            inputStrSet.insert(String(phraseValue.prefix(text.count + 1)))
        }
        InputContext.shared.preInputPrefixSet = inputStrSet
        InputContext.shared.candidates = candidates
    }

    // 取得以嘸蝦米輸入的候選字
    func getCandidates(_ text: String) {
        // 輸入碼太長的話就不用查詢，節省資源
        if text.count >= 6 {
            InputContext.shared.preInputPrefixSet = []
            InputContext.shared.candidates = []
        }

        var candidates: [String] = []
        var candidatesSet: Set<String> = []
        var inputStrSet: Set<String> = []

        let response: [Phrase] = LiuManager.shared.getNormalModePhrase(text)
        for r in response {
            let value: String = r.value(forKey: "value") as! String
            if let rKey = r.key, rKey.count > text.count {
                inputStrSet.insert(String(rKey.prefix(text.count + 1)))
            }
            if candidatesSet.contains(value) {
                continue
            }
            candidatesSet.insert(value)
            candidates.append(value)
        }
        // 自定義的字詞
        let customPhrases = CustomPhraseManager.getCustomPhraseByKey(text)
        for c in customPhrases {
            guard let phraseValue = c.value else { return }
            candidates.append(phraseValue)
            candidatesSet.insert(phraseValue)
            inputStrSet.insert(String(phraseValue.prefix(text.count + 1)))
        }
        InputContext.shared.preInputPrefixSet = inputStrSet
        InputContext.shared.candidates = candidates
    }

    // 取得相同讀音的候選字
    func getCandidatesByPronunciation(_ text: String) {
        InputContext.shared.candidates = CoreDataHelper.getCharWithSamePronunciation(text)
    }
}
