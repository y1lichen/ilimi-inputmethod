// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import CoreData

// MARK: - Phrase

@objc(Event)
class Phrase: NSManagedObject {
    @NSManaged
    var key: String
    @NSManaged
    var key_priority: Int64
    @NSManaged
    var value: String
}

// MARK: - Zhuin

@objc(Location)
class Zhuin: NSManagedObject {
    @NSManaged
    var key: String
    @NSManaged
    var key_priority: Int64
    @NSManaged
    var value: String
}

// MARK: - DataSputnik

public class DataSputnik {
    // MARK: Public

    public static var shared = DataSputnik()

    // MARK: Internal

    lazy var objModel: NSManagedObjectModel = {
        let model = NSManagedObjectModel()
        model.entities = prepareEntities()
        return model
    }()

    // MARK: Private

    private func handleAttributes(with entity: NSEntityDescription) {
        let attrKey = NSAttributeDescription()
        attrKey.name = "key"
        attrKey.type = .string
        attrKey.isOptional = true
        entity.properties.append(attrKey)

        let attrPriority = NSAttributeDescription()
        attrPriority.name = "key_priority"
        attrPriority.type = .integer64
        attrPriority.defaultValue = 0
        entity.properties.append(attrPriority)

        let attrValue = NSAttributeDescription()
        attrValue.name = "value"
        attrValue.type = .string
        attrKey.isOptional = true
        entity.properties.append(attrValue)
    }

    private func prepareEntities() -> [NSEntityDescription] {
        var result = [NSEntityDescription]()

        let phraseEntity = NSEntityDescription()
        phraseEntity.name = "Phrase"
        phraseEntity.managedObjectClassName = "Phrase"
        handleAttributes(with: phraseEntity)
        result.append(phraseEntity)

        let zhuinEntity = NSEntityDescription()
        zhuinEntity.name = "Zhuin"
        zhuinEntity.managedObjectClassName = "Zhuin"
        handleAttributes(with: zhuinEntity)
        result.append(zhuinEntity)

        return result
    }
}
