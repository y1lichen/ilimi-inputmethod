//
//  InputContext.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/6.
//

import Foundation

class InputContext {
    static let shared = InputContext()
    var currentInput: String = ""
    var currentIndex: Int = 0
    private var _candidates: [String] = []
    private var _numberedCandidates: [String] = []
    var candidates: [String] {
        get { return _candidates }
        set {
            _candidates = newValue
            _numberedCandidates = []
            for i in 0 ..< _candidates.count {
                _numberedCandidates.append("\(i + 1) \(_candidates[i])")
            }
        }
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
		currentInput  = ""
		_candidates = []
		_numberedCandidates = []
	}
}
