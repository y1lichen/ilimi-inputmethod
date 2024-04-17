//
//  File.swift
//
//
//  Created by 陳奕利 on 2024/4/4.
//

import Foundation
import SwiftUI

struct EditableText: View {
    // MARK: Lifecycle

    init(text: Binding<String>) {
        self._text = text
        self.temporaryText = text.wrappedValue
    }

    // MARK: Internal

    @Binding
    var text: String

    var body: some View {
        TextField("", text: $temporaryText, onCommit: { text = temporaryText })
            .focused($isFocused, equals: true)
            .onTapGesture { isFocused = true }
            .onExitCommand { temporaryText = text; isFocused = false }
    }

    // MARK: Private

    @State
    private var temporaryText: String
    @FocusState
    private var isFocused: Bool
}
