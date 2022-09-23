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
	var isTradToSim: Bool = false
    var currentInput: String = ""
    var currentIndex: Int = 0
	var candidatesCount = 0
	var preInputPrefixSet: Set<String> = []
    private var _candidates: [String] = []
    private var _numberedCandidates: [String] = []
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
        }
    }
    
    var closureStack: [String] = []
    func getClosingClosure() -> String? {
        if currentInput.isEmpty && !closureStack.isEmpty {
            let closure = closureStack.removeLast()
            if let closingClosure = closureDict[closure] {
                NSLog("\(closure), \(closingClosure)")
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
		currentInput  = ""
		preInputPrefixSet = []
		candidates = []
        IlimiInputController.prefixHasCandidates = true
	}
    
    func isClosure(input: String) -> Bool {
        return (closureDict[input] != nil)
    }
}

