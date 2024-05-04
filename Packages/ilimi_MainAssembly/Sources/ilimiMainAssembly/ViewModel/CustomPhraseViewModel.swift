//
//  File.swift
//
//
//  Created by 陳奕利 on 2024/4/24.
//

import Foundation

class CustomPhraseViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {
        fetchData()
    }

    // MARK: Internal

    @Published
    var key: String = ""
    @Published
    var value: String = ""

    @Published
    var showEditSheet = false

    @Published
    var showAddSheet = false
    var selected = Set<CustomPhrase.ID>()

    var customPhraseToBeEdited: CustomPhrase?

    //	static var shared = CustomPhraseViewModel()

    @Published
    var customPhrases: [CustomPhrase] = []

    func fetchData() {
        customPhrases = CustomPhraseManager.getAllCustomPhrase()
    }

    func delete(_ customPhrase: CustomPhrase) {
        CustomPhraseManager.deleteCustomPhrase(customPhrase)
        fetchData()
    }

    func addCustomPhrase() {
        CustomPhraseManager.addCustomPhrase(key: key, value: value)
        fetchData()
        clearKeyValue()
    }

    func openEditView(_ customPhrase: CustomPhrase) {
        showEditSheet = true
        customPhraseToBeEdited = customPhrase
    }

    func syncKeyValueWithCustomPhraseToBeEdited() {
        if showEditSheet {
            if let customPhraseToBeEdited = customPhraseToBeEdited {
                key = customPhraseToBeEdited.key ?? ""
                value = customPhraseToBeEdited.value ?? ""
            }
        }
    }

    func editCustomPhrase() {
        if let customPhraseToBeEdited = customPhraseToBeEdited {
            CustomPhraseManager.editCustomPhrase(customPhraseToBeEdited, key: key, value: value)
            clearKeyValue()
        }
    }

    func checkIsValid() -> Bool {
        if key.count > 5 {
            NotifierController.notify(message: "自訂字詞的字碼以5碼為上限")
            return false
        }
        return true
    }

    // MARK: Private

    private func clearKeyValue() {
        key = ""
        value = ""
        customPhraseToBeEdited = nil
    }
}
