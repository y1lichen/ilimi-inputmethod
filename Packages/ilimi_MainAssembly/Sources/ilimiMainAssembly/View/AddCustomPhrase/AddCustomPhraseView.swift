// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import Foundation
import SwiftUI



struct AddCustomPhraseView: View {
    @Environment(\.managedObjectContext) private var context
	@FetchRequest(entity: CustomPhrase.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \CustomPhrase.timestp, ascending: true)])
    var customPhrases: FetchedResults<CustomPhrase>

    @State var showEditSheet = false
	
	@State var showSheet = false
    @State private var selected = Set<CustomPhrase.ID>()

    func delete(_ customPhrase: CustomPhrase) {
        CustomPhraseContainerController.deleteCustomPhrase(customPhrase)
    }

    var body: some View {
        VStack {
            Table(of: CustomPhrase.self, selection: $selected) {
                TableColumn("字碼") {
                    Text($0.key ?? "")
                }
                TableColumn("字詞") {
                    Text($0.value ?? "")
                }
            }
		rows: {
                ForEach(customPhrases) { phrase in
                    TableRow(phrase)
                        .contextMenu {
//                            Button("Edit") {
//								phraseToBeEdited  = phrase
//                                showEditSheet = true
//                            }
//                            Divider()
                            Button("Delete", role: .destructive) {
                                delete(phrase)
                            }
                        }
                }
            }
            HStack {
                Spacer().frame(width: 5)
                Button("-") {
                    for id in _selected.wrappedValue {
                        if let phrase = customPhrases.first(where: {
                            $0.id == id
                        }) {
                            delete(phrase)
                        }
                    }
                }
                Button("+") {
                    showSheet = true
                }
                Spacer()
			}.padding()
        }
        .frame(width: 450, height: 250)
        .sheet(isPresented: $showSheet) {
            SheetView(isShow: $showSheet)
        }
    }
}
