//
//  File.swift
//
//
//  Created by 陳奕利 on 2024/4/12.
//

import CoreData

public class CustomPhraseManager {
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

    static func getAllCustomPhrase() -> [CustomPhrase] {
        let request = NSFetchRequest<CustomPhrase>(entityName: "CustomPhrase")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CustomPhrase.timestp, ascending: true)]
        do {
            let response = try PersistenceController.shared.container.viewContext.fetch(request)
            return response
        } catch {
            NSLog(error.localizedDescription)
        }
        return []
    }

    static func getCustomPhraseByKey(_ key: String) -> [CustomPhrase] {
        let request = NSFetchRequest<CustomPhrase>(entityName: "CustomPhrase")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CustomPhrase.timestp, ascending: true)]
        request.predicate = SettingViewModel.shared
            .showOnlyExactlyMatch ? NSPredicate(format: "key == %@", key) :
            NSPredicate(format: "key BEGINSWITH %@", key)
        do {
            let response = try PersistenceController.shared.container.viewContext.fetch(request)
            return response
        } catch {
            NSLog(error.localizedDescription)
        }
        return []
    }

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
        persistenceController.saveContext()
    }

    static func deleteCustomPhrase(_ phrase: CustomPhrase) {
        context.delete(phrase)
        persistenceController.saveContext()
    }

    static func editCustomPhrase(_ phrase: CustomPhrase, key: String, value: String) {
        phrase.key = key
        phrase.value = value
        persistenceController.saveContext()
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
