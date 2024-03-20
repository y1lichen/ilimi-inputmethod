// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import CoreData
import Foundation

class CinReader {
    static let shared = CinReader()

    let liuCinPath = NSHomeDirectory() + "/liu.cin"

    let persistenceContainer = PersistenceController.shared
    let userDefaults = UserDefaults.standard

    func readCin() {
        DataInitializer.shared.cleanAllData("Phrase")
        do {
            let contents = try String(contentsOfFile: liuCinPath)
            let lines = contents.split(separator: "\n")
            var chardefStarted = false
            let realLines = lines.map {
                sub -> String in String(sub)
            }
            var data: [[String]] = []
            for line in realLines {
                if line == "%chardef begin" {
                    chardefStarted = true
                    continue
                }
                if line == "%chardef end" {
                    chardefStarted = false
                    break
                }
                if !chardefStarted {
                    continue
                }
                let charDataSeq = line.split(separator: " ")
                let charData = charDataSeq.map { sub in
                    String(sub)
                }
                data.append(charData)
            }
            data = data.sorted(by: { $0[0] < $1[0] })
            var priority: Int64 = 0
            for item in data {
                // 如果不是「字碼+文字」就不處理
                if item.count == 2 {
                    writeData(item[0], item[1], priority)
                    priority += 1
                }
            }
            persistenceContainer.saveContext()
            // hadReadLiuJson就先不改名成hadReadLiu了...
            userDefaults.set(true, forKey: "hadReadLiuJson")
        } catch {
            NSLog(error.localizedDescription)
            NotifierController.notify(message: "讀取cin字檔錯誤")
        }
        NotifierController.notify(message: "成功匯入liu.cin", stay: true)
    }

    func writeData(_ key: String, _ value: String, _ priority: Int64) {
        let model = NSEntityDescription.insertNewObject(
            forEntityName: "Phrase",
            into: persistenceContainer.container.viewContext
        ) as! Phrase
        model.key_priority = priority
        model.key = key
        model.value = value
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
