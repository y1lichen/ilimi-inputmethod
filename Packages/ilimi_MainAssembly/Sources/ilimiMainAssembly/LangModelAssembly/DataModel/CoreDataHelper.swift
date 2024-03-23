//
//  File.swift
//  
//
//  Created by 陳奕利 on 2024/3/23.
//

import Foundation
import CoreData

class CoreDataHelper {
	static func getZhuyinOfChar(_ char: String) -> [String] {
		let requestForZhuyin = NSFetchRequest<Zhuin>(entityName: "Zhuin")
		requestForZhuyin.predicate = NSPredicate(format: "value == %@", char)
		var res: [String] = []
		do {
			let responseForZhuyin = try PersistenceController.shared.container.viewContext.fetch(requestForZhuyin)
			for zhuyin in responseForZhuyin {
				guard let zhuyinKey = zhuyin.key else { continue }
				res.append(StringConverter.shared.keyToZhuyins(zhuyinKey))
			}
		} catch {
			NSLog(error.localizedDescription)
		}
		return res
	}
	
	static func getKeyOfChar(_ char: String) -> [String] {
		let requestForKey = NSFetchRequest<Phrase>(entityName: "Phrase")
		requestForKey.predicate = NSPredicate(format: "value == %@", char)
		var res: [String] = []
		do {
			let responseForKey = try PersistenceController.shared.container.viewContext.fetch(requestForKey)
			for phrase in responseForKey {
				guard let phraseKey = phrase.key else { continue }
				res.append(phraseKey)
			}
		} catch {
			NSLog(error.localizedDescription)
		}
		return res
	}
}
