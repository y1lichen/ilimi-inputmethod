//
//  File.swift
//
//
//  Created by 陳奕利 on 2024/5/7.
//

import Foundation

class UpdateManager {
    static func checkUpdate() {
		var appVer: String? = nil
        if let infoDict = Bundle.main.infoDictionary {
            if !infoDict.isEmpty {
                appVer = infoDict["CFBundleShortVersionString"] as! String?
            }
        }
    }
}
