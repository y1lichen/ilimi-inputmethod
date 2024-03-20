// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import InputMethodKit

extension IlimiInputController {
    func handleFullWidthMode(event: NSEvent, client sender: Any!) -> Bool {
        if !isFullWidthMode {
            return false
        }
        if let inputChar = event.characters?.first {
            commitText(client: sender, text: String(inputChar).fullWidth)
        }
        return true
    }
}
