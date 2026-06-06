// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import AppKit
import CoreData
import Foundation
import SwiftUI

struct InputEngine {
    static let shared = InputEngine()

    private static let maxNormalInputLength = 5
    private let candidateBuilder = CandidateBuilder()

    // 取得以注音輸入的候選字
    func getCadidatesByZhuyin(_ text: String) {
        InputContext.shared.candidates = CoreDataHelper.getCharByZhuyin(text)
    }

    func setCandidates(_ phrases: [Phrase], _ text: String) {
        apply(candidateBuilder.build(from: phrases, matching: text))
    }

    // 取得以嘸蝦米輸入的候選字
    func getCandidates(_ text: String) {
        // 輸入碼太長的話就不用查詢，節省資源
        if text.count > Self.maxNormalInputLength {
            InputContext.shared.preInputPrefixSet = []
            InputContext.shared.candidates = []
            return
        }

        let response: [Phrase] = LiuManager.shared.getNormalModePhrase(text)
        apply(candidateBuilder.build(from: response, matching: text))
    }

    // 取得相同讀音的候選字
    func getCandidatesByPronunciation(_ text: String) {
        InputContext.shared.candidates = CoreDataHelper.getCharWithSamePronunciation(text)
    }

    private func apply(_ result: CandidateBuildResult) {
        InputContext.shared.preInputPrefixSet = result.preInputPrefixes
        InputContext.shared.candidates = result.candidates
    }
}
