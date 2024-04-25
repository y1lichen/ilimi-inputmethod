//
//  File.swift
//  
//
//  Created by 陳奕利 on 2024/4/25.
//

import Foundation

class LiuTab2Cin {
	static let shared = CinReader()

	let liuCinPath = NSHomeDirectory() + "/liu.cin"

	let persistenceContainer = PersistenceController.shared
	let userDefaults = UserDefaults.standard
}
