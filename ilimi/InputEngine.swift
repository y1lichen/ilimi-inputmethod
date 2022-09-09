//
//  InputEngine.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/7.
//

import CoreData
import Foundation
import AppKit

struct InputEngine {
    static let shared = InputEngine()

    func getCandidates(_ text: String) -> [NSAttributedString] {
        let request = NSFetchRequest<Phrase>(entityName: "Phrase")
        request.predicate = NSPredicate(format: "key BEGINSWITH %@", text)
		request.sortDescriptors = [NSSortDescriptor(key: "key_priority", ascending: true)]
        do {
            let response = try PersistenceController.shared.container.viewContext.fetch(request)
            var candidates: [NSAttributedString] = []
            for r in response {
                let value: String = r.value(forKey: "value") as! String
				let attValue = NSAttributedString.init(string: value)
                candidates.append(attValue)
            }
            return candidates
        } catch {
            NSLog(error.localizedDescription)
        }
        return []
    }
}
