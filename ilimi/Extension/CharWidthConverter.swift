//
//  CharWidthConverter.swift
//  ilimi
//
//  Created by 陳奕利 on 2023/8/22.
//

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
