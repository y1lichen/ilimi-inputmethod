// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import Foundation
import SwiftUI

struct AddCustomPhraseView: View {
    @StateObject var viewModel = CustomPhraseViewModel()

    var body: some View {
        VStack {
            Table(of: CustomPhrase.self, selection: $viewModel.selected) {
                TableColumn("字碼") {
                    Text($0.key ?? "")
                }
                TableColumn("字詞") {
                    Text($0.value ?? "")
                }
            }
		rows: {
                ForEach(viewModel.customPhrases) { phrase in
                    TableRow(phrase)
                        .contextMenu {
                            Button("Edit") {
                                viewModel.openEditView(phrase)
                            }
                            Divider()
                            Button("Delete", role: .destructive) {
                                viewModel.delete(phrase)
                            }
                        }
                }
            }
            HStack {
                Spacer().frame(width: 5)
                Button("-") {
                    for id in viewModel.selected {
                        if let phrase = viewModel.customPhrases.first(where: {
                            $0.id == id
                        }) {
                            viewModel.delete(phrase)
                        }
                    }
                }
                Button("+") {
                    viewModel.showAddSheet = true
                }
                Spacer()
            }.padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 0))
        }
        .frame(width: 450, height: 250)
        .sheet(isPresented: $viewModel.showAddSheet) {
            SheetView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showEditSheet) {
            SheetView(viewModel: viewModel)
        }
    }
}
