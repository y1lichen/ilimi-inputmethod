// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import Foundation
import SwiftUI

struct AddCustomPhraseView: View {
	@State var chars = ["test0", "test1", "test2"]
	
	var body: some View {
		VStack {
			List {
				ForEach($chars, id: \.self) { entry in
					EditableText(text: entry)
				}
			}
		}
		.frame(width: 450, height: 250)
	}
}

