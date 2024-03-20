// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import AppKit
import CoreData
import Foundation

// MARK: - DataInitializer

class DataInitializer {
    static let shared = DataInitializer()
    static let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("ilimi")
    static let appSupportDir = appSupportURL.path

    let persistenceContainer = PersistenceController.shared
    let liuJsonPath = appSupportDir + "/liu.json"
    let liuCinPath = appSupportDir + "/liu.cin"
    let pinyinPath = appSupportDir + "/pinyin.json"
    let userDefaults = UserDefaults.standard

    func initDataWhenStart() {
        let hadReadLiu = userDefaults.object(forKey: "hadReadLiuJson") as? Bool ?? false
        if !hadReadLiu {
            loadLiuData()
        }
        let hadReadPinyin = userDefaults.object(forKey: "hadReadPinyinJson") as? Bool ?? false
        if !hadReadPinyin {
            loadPinyinJson()
        }
    }

    func cleanAllData(_ entityName: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try persistenceContainer.container.viewContext.execute(batchDeleteRequest)
        } catch {
            AppDelegate.shared.pushInstantNotification(
                title: String(describing: error),
                subtitle: "",
                body: "",
                sound: true
            )
        }
        NSLog("Core Data cleaned")
    }

    func loadLiuData() {
        // 暫時優先使用json字檔，未來仍可優先使用cin字檔
        if checkFileExist(liuJsonPath) {
            loadLiuJson()
        } else if checkFileExist(liuCinPath) {
            CinReader.shared.readCin()
        } else {
            NotifierController.notify(message: "字檔並不存在！", stay: true)
        }
    }

    func loadPinyinJson() {
        cleanAllData("Zhuin")
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: pinyinPath))
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: [String]] {
                var count: Int64 = 0
                for (key, value) in json {
                    for v in value {
                        let model = NSEntityDescription.insertNewObject(
                            forEntityName: "Zhuin",
                            into: persistenceContainer.container.viewContext
                        )
                        guard let model = model as? Zhuin else { continue }
                        model.key = key
                        model.value = v
                        model.key_priority = count
                        count += 1
                    }
                }
                persistenceContainer.saveContext()
                userDefaults.set(true, forKey: "hadReadPinyinJson")
                NSLog("pinyin.json laoded")
            }
        } catch {
            NSLog("Error: " + String(describing: error))
        }
    }

    func loadLiuJson() {
        cleanAllData("Phrase")
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: liuJsonPath))
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let chardefs = json["chardefs"] as? [String: [String]] {
                    let res = chardefs.sorted(by: { $0.0 < $1.0 })
                    var count: Int64 = 0
                    for (key, value) in res {
                        for v in value {
                            let model = NSEntityDescription.insertNewObject(
                                forEntityName: "Phrase",
                                into: persistenceContainer.container.viewContext
                            )
                            guard let model = model as? Phrase else { continue }
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
            AppDelegate.shared.pushInstantNotification(
                title: String(describing: error),
                subtitle: "",
                body: "",
                sound: true
            )
        }
        NotifierController.notify(message: "成功匯入liu.json", stay: true)
    }

    func reloadAllData() {
        if checkFileExist(liuJsonPath) {
            loadLiuJson()
        } else if checkFileExist(liuCinPath) {
            CinReader.shared.readCin()
        } else {
            NotifierController.notify(message: "字檔並不存在！", stay: true)
        }
        loadPinyinJson()
    }
}

extension DataInitializer {
    func checkFileExist(_ fileName: String) -> Bool {
        print("[ilimi] Checking file existence: " + fileName)
        return FileManager.default.fileExists(atPath: fileName)
    }
}
