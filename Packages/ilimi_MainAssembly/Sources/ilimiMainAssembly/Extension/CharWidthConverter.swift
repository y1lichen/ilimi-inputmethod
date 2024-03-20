// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import Foundation

extension String {
    // 轉半形
    var halfWidth: String {
        transformFullWidthToHalfWidth(reverse: false)
    }

    // 轉全型
    var fullWidth: String {
        transformFullWidthToHalfWidth(reverse: true)
    }

    private func transformFullWidthToHalfWidth(reverse: Bool) -> String {
        let string = NSMutableString(string: self) as CFMutableString
        CFStringTransform(string, nil, kCFStringTransformFullwidthHalfwidth, reverse)
        return string as String
    }
}
