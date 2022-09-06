//
//  InputEngine.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/7.
//

import Foundation
import CoreData

struct InputEngine {
	static let shared = InputEngine()
	
	private func fetchCandidates(_ text: String) -> [String] {
		let request = NSFetchRequest<Phrase>(entityName: "Phrase")
		request.predicate = NSPredicate(format: "key BEGINSWITH %@", text)
		do {
			let response = try PersistenceController.shared.container.viewContext.fetch(request)
			var candidates: [String] = []
			for r in response {
				let values = r.value(forKey: "value") as! [String]
				candidates.append(contentsOf: values)
			}
			return candidates
		} catch {
			NSLog(error.localizedDescription)
		}
		return []
	}

}
