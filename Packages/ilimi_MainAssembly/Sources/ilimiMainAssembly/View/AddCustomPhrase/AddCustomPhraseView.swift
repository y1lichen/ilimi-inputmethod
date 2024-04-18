// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import Foundation
import SwiftUI

struct AddCustomPhraseView: View {
    @Environment(\.managedObjectContext)
    private var context
    @FetchRequest(entity: CustomPhrase.entity(), sortDescriptors: [])
    var customPhrases: FetchedResults<CustomPhrase>
    func delete(_ customPhrase: CustomPhrase) {
    }

    var body: some View {
        VStack {
            Table(of: CustomPhrase.self) {
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
                            Button("Edit") {
                                // TODO: open editor in inspector
                            }
                            Button("See Details") {
                                // TODO: open detai view
                            }
                            Divider()
                            Button("Delete", role: .destructive) {
                                delete(phrase)
                            }
                        }
                }
            }
			HStack() {
				Spacer().frame(width: 5)
                Button("-") {
                }
                Button("+") {
                }
				Spacer()
            }
        }
        .frame(width: 450, height: 250)
    }
}
