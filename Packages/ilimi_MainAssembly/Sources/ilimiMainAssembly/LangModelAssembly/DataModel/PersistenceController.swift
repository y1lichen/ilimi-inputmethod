// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import CoreData
import Foundation

import CoreData

struct PersistenceController {
    // MARK: Lifecycle

    init(inMemory: Bool = false) {
        let modelURL = Bundle.module.url(forResource: "Model", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        self.container = NSPersistentContainer(name: "Model", managedObjectModel: model)
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    // MARK: Internal

    static let shared = PersistenceController()

    let container: NSPersistentContainer

    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func writeData(_ key: String, _ value: String, _ priority: Int64) {
        let model = NSEntityDescription.insertNewObject(
            forEntityName: "Phrase",
            into: container.viewContext
        )
        guard let model = model as? Phrase else { return }
        model.key_priority = priority
        model.key = key
        model.value = value
    }
}
