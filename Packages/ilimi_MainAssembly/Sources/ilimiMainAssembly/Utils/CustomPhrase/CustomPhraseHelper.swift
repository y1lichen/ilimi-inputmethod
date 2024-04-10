// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import AppKit
import CoreData
import Foundation

class CustomPhraseHelper {
	static let shared = CustomPhraseHelper()

	let persistenceContainer = PersistenceController.shared

	let userDefaults = UserDefaults.standard

	let defaultPhraseDict = ["oaooo": "哈哈哈", "ilimi": "一粒米輸入法"]

	func setDefaultCustomPhrase() {
		DataInitializer.shared.cleanAllData("CustomPhrase")
		for (key, value) in defaultPhraseDict {
			let model = NSEntityDescription.insertNewObject(
				forEntityName: "CustomPhrase",
				into: persistenceContainer.container.viewContext
			)
			guard let model = model as? CustomPhrase else { continue }
			model.key = key
			model.value = value
		}
		persistenceContainer.saveContext()
	}
}
