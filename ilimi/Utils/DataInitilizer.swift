//
//  PhraseInitilizer.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/6.
//

import CoreData
import Foundation

class DataInitilizer {
    static let shared = DataInitilizer()
    let appDelegate = NSApplication.shared.delegate as! AppDelegate

    let persistenceContainer = PersistenceController.shared
    let liuJsonPath = NSHomeDirectory() + "/liu.json"
    let liuCinPath = NSHomeDirectory() + "/liu.cin"
    let pinyinPath = NSHomeDirectory() + "/pinyin.json"
    let userDefaults = UserDefaults.standard

    func initDataWhenStart() {
        let hadReadLiu = userDefaults.object(forKey: "hadReadLiuJson") as? Bool ?? false
        if !hadReadLiu {
            // 暫時優先使用json字檔，未來仍可優先使用cin字檔
            if (checkFileExist(liuJsonPath)) {
                loadLiuJson()
            } else if (checkFileExist(liuCinPath)) {
                CinReader.shared.readCin()
            } else {
                NotifierController.notify(message: "字檔並不存在！", stay: true)
            }
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
            appDelegate.pushInstantNotification(title: String(describing: error), subtitle: "", body: "", sound: true)
        }
        NSLog("Core Data cleaned")
    }

    func loadPinyinJson() {
        cleanAllData("Zhuin")
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: pinyinPath))
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: [String]] {
                var count: Int64 = 0
                for (key, value) in json {
                    for v in value {
                        let model = NSEntityDescription.insertNewObject(forEntityName: "Zhuin", into: persistenceContainer.container.viewContext) as! Zhuin
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
//            NSLog("Error: " + String(describing: error))
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
                            let model = NSEntityDescription.insertNewObject(forEntityName: "Phrase", into: persistenceContainer.container.viewContext) as! Phrase
                            model.key_priority = count
                            model.key = key
                            model.value = v
                            count += 1
                        }
                    }
                    persistenceContainer.saveContext()
                    userDefaults.set(true, forKey: "hadReadLiuJson")
//                    NSLog("liu.json loaded")
                }
            }
        } catch {
            appDelegate.pushInstantNotification(title: String(describing: error), subtitle: "", body: "", sound: true)
        }
        NotifierController.notify(message: "成功匯入liu.json", stay: true)
    }
    
    func reloadAllData() {
        if (checkFileExist(liuJsonPath)) {
            loadLiuJson()
        } else if (checkFileExist(liuCinPath)) {
            CinReader.shared.readCin()
        } else {
            NotifierController.notify(message: "字檔並不存在！", stay: true)
        }
        loadPinyinJson()
    }
}

extension DataInitilizer {
    func checkFileExist(_ fileName: String) -> Bool {
        return FileManager.default.fileExists(atPath: fileName)
    }
}
