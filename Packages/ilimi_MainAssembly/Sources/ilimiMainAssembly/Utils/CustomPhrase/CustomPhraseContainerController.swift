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

	static var persistenceController = PersistenceController.shared
    public static var context: NSManagedObjectContext {
        persistenceController.container.viewContext
    }

    // MARK: - Core Data stack

    // MARK: - Core Data Saving support

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
		persistenceController.saveContext()
    }
}
