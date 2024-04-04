//
//  File.swift
//  
//
//  Created by 陳奕利 on 2024/4/4.
//

import Foundation
import SwiftUI

struct EditableText: View {
	@Binding var text: String

	@State private var temporaryText: String
	@FocusState private var isFocused: Bool

	init(text: Binding<String>) {
		self._text = text
		self.temporaryText = text.wrappedValue
	}

	var body: some View {
		TextField("", text: $temporaryText, onCommit: { text = temporaryText })
			.focused($isFocused, equals: true)
			.onTapGesture { isFocused = true }
			.onExitCommand { temporaryText = text; isFocused = false }
	}
}
