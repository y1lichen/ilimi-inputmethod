//
//  File.swift
//
//
//  Created by 陳奕利 on 2024/4/12.
//

import CoreData

public class CustomPhraseContainerController {
    // MARK: Lifecycle

    // MARK: - Initializer

    private init() {}

    // MARK: Public

    public static var context: NSManagedObjectContext {
        persistenceController.container.viewContext
    }

    // MARK: - Core Data stack

    // MARK: - Core Data Saving support

    // MARK: Internal

    // MARK: - Define Constants / Variables

    static var persistenceController = PersistenceController.shared
    static let defaultPhraseDict = ["oaooo": "哈哈哈", "ilimi": "一粒米輸入法"]

    static func setDefaultCustomPhrase() {
        cleanAllData()
        for (key, value) in defaultPhraseDict {
            let model = NSEntityDescription.insertNewObject(
                forEntityName: "CustomPhrase",
                into: context
            )
            guard let model = model as? CustomPhrase else { return }
            model.key = key
            model.value = value
			model.timestp = Date.now
        }
        persistenceController.saveContext()
    }

	static func addCustomPhrase(key: String, value: String) {
		let model = CustomPhrase(context: context)
		model.key = key
		model.value = value
		model.timestp = Date.now
		do {
			try context.save()
			context.refreshAllObjects()
		} catch {
			NSLog(String(describing: error))
		}
    }

    static func deleteCustomPhrase(_ phrase: CustomPhrase) {
		do {
			context.delete(phrase)
			try context.save()
			context.refreshAllObjects()
		} catch {
			NSLog(String(describing: error))
		}
    }

    static func cleanAllData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomPhrase")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(batchDeleteRequest)
        } catch {
            NSLog(String(describing: error))
        }
        NSLog("Core Data cleaned")
    }
}
