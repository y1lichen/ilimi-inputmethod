// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import SwiftUI

// MARK: - QueryResult

struct QueryResult: Identifiable {
    let id = UUID()

    var char: String
    var zhuyin: String
    var inputCode: String
}

// MARK: - QueryView

struct QueryView: View {
    @State
    var textFieldText: String = ""
    @State
    var results: [QueryResult] = []

    var body: some View {
        VStack {
            TextField("輸入字詞", text: $textFieldText, onCommit: onCommit)
                .textFieldStyle(.plain)
                .padding()
                .frame(width: 380)
            Spacer()
            Table(results) {
                TableColumn("文字", value: \.char)
                    .width(60)
                TableColumn("輸入碼", value: \.inputCode)
                TableColumn("注音", value: \.zhuyin)
            }
        }.padding()
    }

    func onCommit() {
        results = []
        var temp = [QueryResult]()
        for i in 0 ..< textFieldText.count {
            temp.append(handler(textFieldText[i]))
        }
        results = temp
    }

    func handler(_ text: String) -> QueryResult {
        var res = QueryResult(char: text, zhuyin: "", inputCode: "")
        let requestForKey = NSFetchRequest<Phrase>(entityName: "Phrase")
        requestForKey.predicate = NSPredicate(format: "value == %@", text)
        let requestForZhuyin = NSFetchRequest<Zhuin>(entityName: "Zhuin")
        requestForZhuyin.predicate = NSPredicate(format: "value == %@", text)
        do {
            let responseForKey = try PersistenceController.shared.container.viewContext.fetch(requestForKey)
            var keys = ""
            for phrase in responseForKey {
                keys += phrase.key
                keys += " "
            }
            res.inputCode = keys
            let responseForZhuyin = try PersistenceController.shared.container.viewContext.fetch(requestForZhuyin)
            var zhuyins = ""
            for zhuyin in responseForZhuyin {
                zhuyins += StringConverter.shared.keyToZhuyins(zhuyin.key)
                zhuyins += " "
            }
            res.zhuyin = zhuyins
        } catch {
            NSLog(error.localizedDescription)
        }
        return res
    }
}
