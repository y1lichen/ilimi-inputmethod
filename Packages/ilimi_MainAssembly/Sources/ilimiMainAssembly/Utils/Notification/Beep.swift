// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import AppKit

extension IlimiInputController {
    func beep() {
        let isSilentMode = UserDefaults.standard.bool(forKey: "silentMode")
        if isSilentMode {
            return
        }
        NSSound.beep()
    }
}
