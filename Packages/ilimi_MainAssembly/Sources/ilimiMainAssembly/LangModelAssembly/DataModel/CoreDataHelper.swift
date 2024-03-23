//
//  File.swift
//
//
//  Created by 陳奕利 on 2024/3/23.
//

import Foundation
import CoreData

class CoreDataHelper {
	// 取得文字的注音碼的raw value（英文碼）
	static func getRawZhuyinOfChar(_ text: String) -> [String] {
		let request = NSFetchRequest<Zhuin>(entityName: "Zhuin")
		request.predicate = NSPredicate(format: "value == %@", text)
		do {
			let response = try PersistenceController.shared.container.viewContext.fetch(request)
			let res = response.compactMap { $0.key }
			return res
		} catch {
			NSLog(error.localizedDescription)
		}
		return []
	}
	
	// 查找文字的注音碼
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
	
	// 查找文字的嘸蝦米輸入碼
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
	
	// 取得相同讀音的候選字
	static func getCharWithSamePronunciation(_ char: String) -> [String] {
		let zhuyins: [String] = getRawZhuyinOfChar(char)
		var result: [String] = []
		let request = NSFetchRequest<Zhuin>(entityName: "Zhuin")
		do {
			for zhuyin in zhuyins {
				request.predicate = NSPredicate(format: "key == %@", zhuyin)
				let response = try PersistenceController.shared.container.viewContext.fetch(request)
				for item in response {
					if let itemValue = item.value, itemValue != char {
						result.append(itemValue)
					}
				}
			}
		} catch {
			NSLog(error.localizedDescription)
		}
		return result
	}
}
