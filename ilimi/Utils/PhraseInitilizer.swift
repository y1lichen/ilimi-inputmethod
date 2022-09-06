//
//  PhraseInitilizer.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/6.
//

import Foundation
import CoreData

class PhraseInitilizer {
	
	let persistenceContainer = PersistenceController.shared
	let path = NSHomeDirectory() + "/liu.json"
	
	init() {
		initPhraseData()
	}
	
	func initPhraseData() {
		do {
			let data = try Data(contentsOf: URL(fileURLWithPath: path))
			if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
				if let chardefs = json["chardefs"] as? [String: [String]] {
					for (key, value) in chardefs {
						let model = NSEntityDescription.insertNewObject(forEntityName: "Phrase", into: persistenceContainer.container.viewContext) as! Phrase
						model.key = key
						model.value = value as NSObject
					}
					persistenceContainer.saveContext()
				}
			}
		} catch {
			NSLog(String(describing: error))
		}
	}
}
