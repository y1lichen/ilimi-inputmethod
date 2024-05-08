//
//  File.swift
//
//
//  Created by 陳奕利 on 2024/4/20.
//

import Foundation
import SwiftUI

struct SheetView: View {
    // MARK: Lifecycle

    init(viewModel: CustomPhraseViewModel) {
        self.viewModel = viewModel
    }

    // MARK: Internal

    @ObservedObject var viewModel: CustomPhraseViewModel

    var body: some View {
        VStack {
            Text("新增自訂字詞")
                .font(.headline)
                .fontWeight(.heavy)
            Spacer()
            HStack {
                TextField("字碼", text: $viewModel.key)
                    .frame(width: 80)
                TextField("字詞", text: $viewModel.value)
            }
            Spacer().frame(maxHeight: 20)
            HStack {
                Button("取消") {
                    viewModel.showAddSheet = false
                    viewModel.showEditSheet = false
                }
                Spacer()
                Button("完成") {
                    if !viewModel.checkIsValid() {
                        return
                    }
                    if viewModel.showAddSheet {
                        viewModel.addCustomPhrase()
                        viewModel.showAddSheet = false
                    } else if viewModel.showEditSheet {
                        viewModel.editCustomPhrase()
                        viewModel.showEditSheet = false
                    }
                }
            }
        }
        .frame(width: 300, height: 100)
        .padding()
        .onAppear {
            viewModel.syncKeyValueWithCustomPhraseToBeEdited()
        }
    }
}
