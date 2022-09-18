//
//  GetZhuyinView.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/16.
//

import SwiftUI

struct QueryResult: Identifiable {
    let id = UUID()

    var char: String
    var zhuyin: String
    var inputCode: String
}

struct QueryView: View {
    @State var textFieldText: String = ""
    @State var results: [QueryResult] = []

    func onCommit() {
        results = []
        for i in 0 ..< textFieldText.count {
            results.append(handler(textFieldText[i]))
        }
    }

    func handler(_ text: String) -> QueryResult {
        var res = QueryResult(char: "", zhuyin: "", inputCode: "")
        let requestForKey = NSFetchRequest<Phrase>(entityName: "Phrase")
        requestForKey.predicate = NSPredicate(format: "key == %@", text)
        let requestForZhuyin = NSFetchRequest<Zhuin>(entityName: "Zhuin")
        requestForZhuyin.predicate = NSPredicate(format: "key == %@", text)
        do {
            let responseForKey = try PersistenceController.shared.container.viewContext.fetch(requestForKey)
            var keys = ""
            for phrase in responseForKey {
                keys += phrase.value!
                keys += " "
            }
            res.inputCode = keys
            let responseForZhuyin = try PersistenceController.shared.container.viewContext.fetch(requestForZhuyin)
            var zhuyins = ""
            for zhuyin in responseForZhuyin {
                zhuyins += StringConverter.shared.keyToZhuyins(zhuyin.value!)
                zhuyins += " "
            }
            res.zhuyin = zhuyins
        } catch {
            NSLog(error.localizedDescription)
        }
        return res
    }

    var body: some View {
        VStack {
            TextField("輸入字詞", text: $textFieldText, onCommit: onCommit)
                .textFieldStyle(.plain)
                .padding()
                .frame(width: 380)
            Spacer()
            Table(results) {
                TableColumn("文字", value: \.char)
                TableColumn("輸入碼", value: \.inputCode)
                TableColumn("注音", value: \.zhuyin)
            }
        }.padding()
    }
}
