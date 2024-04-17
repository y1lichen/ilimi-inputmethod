//
//  SwiftUIView.swift
//
//
//  Created by 陳奕利 on 2024/4/9.
//

import SwiftUI

struct ListRowView: View {
    @ObservedObject
    var customPhrase: CustomPhrase

    var body: some View {
        EditableText(text: $customPhrase.key.toUnwrapped(defaultValue: ""))
        EditableText(text: $customPhrase.value.toUnwrapped(defaultValue: ""))
    }
}
