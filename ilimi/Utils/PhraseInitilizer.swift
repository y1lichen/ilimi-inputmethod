//
//  PhraseInitilizer.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/6.
//

import CoreData
import Foundation

class PhraseInitilizer {
    static let shared = PhraseInitilizer()

    let persistenceContainer = PersistenceController.shared
    let path = NSHomeDirectory() + "/liu.json"
    let userDefaults = UserDefaults.standard

    func initPhraseWhenStart() {
        let hadRead = userDefaults.object(forKey: "hadReadLiuJson") as? Bool ?? false
        if !hadRead {
            loadLiuJson()
        }
    }

    func cleanAllPhrase() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Phrase")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
			try persistenceContainer.container.viewContext.execute(batchDeleteRequest)
        } catch {
            NSLog("Error: "+String(describing: error))
        }
		NSLog("Core Data cleaned")
    }

    func loadLiuJson() {
		cleanAllPhrase()
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let chardefs = json["chardefs"] as? [String: [String]] {
                    let res = chardefs.sorted(by: { $0.0 < $1.0 })
                    var count: Int64 = 0
                    for (key, value) in res {
                        for v in value {
                            let model = NSEntityDescription.insertNewObject(forEntityName: "Phrase", into: persistenceContainer.container.viewContext) as! Phrase
                            model.key_priority = count
                            model.key = key
                            model.value = v
                            count += 1
                        }
                    }
                    persistenceContainer.saveContext()
                    userDefaults.set(true, forKey: "hadReadLiuJson")
                    NSLog("liu.json loaded")
                }
            }
        } catch {
			NSLog("Error: "+String(describing: error))
        }
    }
}
