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

    // MARK: - Define Constants / Variables

    public static var context: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }

    // MARK: - Core Data stack

    // MARK: - Core Data Saving support

    public static func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: Internal

    static let defaultPhraseDict = ["oaooo": "哈哈哈", "ilimi": "一粒米輸入法"]

    static func setDefaultCustomPhrase() {
        for (key, value) in defaultPhraseDict {
            let model = NSEntityDescription.insertNewObject(
                forEntityName: "CustomPhrase",
                into: context
            )
            guard let model = model as? CustomPhrase else { return }
            model.key = key
            model.value = value
        }
        saveContext()
    }
}
