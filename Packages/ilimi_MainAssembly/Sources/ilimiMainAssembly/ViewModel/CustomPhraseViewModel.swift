//
//  File.swift
//  
//
//  Created by 陳奕利 on 2024/4/24.
//

import Foundation

class CustomPhraseViewModel: ObservableObject {
	@Published var key: String = ""
	@Published var value: String = ""
	
	@Published var showEditSheet = false
	
	@Published var showAddSheet = false
	var selected = Set<CustomPhrase.ID>()
	
	static var shared = CustomPhraseViewModel()
	
	@Published var customPhrases: [CustomPhrase] = []
	
	init() {
		fetchData()
	}
	
	func fetchData() {
		customPhrases = CustomPhraseContainerController.getAllCustomPhrase()
	}
	
	func delete(_ customPhrase: CustomPhrase) {
		CustomPhraseContainerController.deleteCustomPhrase(customPhrase)
		fetchData()
	}
	
	func addCustomPhrase() {
		CustomPhraseContainerController.addCustomPhrase(key: key, value: value)
		fetchData()
	}

}
