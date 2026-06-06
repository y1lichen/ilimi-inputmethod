// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import Foundation

struct CandidateBuildResult {
    let candidates: [String]
    let preInputPrefixes: Set<String>
}

struct CandidateBuilder {
    func build(from phrases: [Phrase], matching text: String) -> CandidateBuildResult {
        var candidates: [String] = []
        var candidateSet: Set<String> = []
        var preInputPrefixes: Set<String> = []

        appendManagedPhrases(
            phrases,
            matching: text,
            candidates: &candidates,
            candidateSet: &candidateSet,
            preInputPrefixes: &preInputPrefixes
        )
        appendCustomPhrases(
            CustomPhraseManager.getCustomPhraseByKey(text),
            matching: text,
            candidates: &candidates,
            candidateSet: &candidateSet,
            preInputPrefixes: &preInputPrefixes
        )

        return CandidateBuildResult(
            candidates: candidates,
            preInputPrefixes: preInputPrefixes
        )
    }

    private func appendManagedPhrases(
        _ phrases: [Phrase],
        matching text: String,
        candidates: inout [String],
        candidateSet: inout Set<String>,
        preInputPrefixes: inout Set<String>
    ) {
        for phrase in phrases {
            guard let value = phrase.value else { continue }
            appendPrefix(from: phrase.key, matching: text, to: &preInputPrefixes)
            appendCandidate(value, to: &candidates, knownCandidates: &candidateSet)
        }
    }

    private func appendCustomPhrases(
        _ phrases: [CustomPhrase],
        matching text: String,
        candidates: inout [String],
        candidateSet: inout Set<String>,
        preInputPrefixes: inout Set<String>
    ) {
        for phrase in phrases {
            guard let value = phrase.value else { continue }
            appendCandidate(value, to: &candidates, knownCandidates: &candidateSet)
            appendPrefix(from: phrase.key, matching: text, to: &preInputPrefixes)
        }
    }

    private func appendCandidate(
        _ candidate: String,
        to candidates: inout [String],
        knownCandidates: inout Set<String>
    ) {
        if knownCandidates.insert(candidate).inserted {
            candidates.append(candidate)
        }
    }

    private func appendPrefix(
        from key: String?,
        matching text: String,
        to preInputPrefixes: inout Set<String>
    ) {
        guard let key, key.count > text.count else { return }
        preInputPrefixes.insert(String(key.prefix(text.count + 1)))
    }
}
