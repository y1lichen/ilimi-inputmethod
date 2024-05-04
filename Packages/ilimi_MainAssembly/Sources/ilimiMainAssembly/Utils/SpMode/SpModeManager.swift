//
//  File.swift
//
//
//  Created by 陳奕利 on 2024/5/2.
//

import CoreData
import Foundation

class SpModeManager {
    static func getSpKeyOfChar(_ chr: String) -> [String] {
        let isLoadByLiu = UserDefaults.standard.bool(forKey: "isLoadByLiuUniTab")
        if isLoadByLiu {
            return getSpOfCharWithLiuTab(chr)
        }
        return getSpOfCharWithoutLiuTab(chr)
    }

    static func checkInputIsSp(_ text: String) -> Bool {
        let isLoadByLiu = UserDefaults.standard.bool(forKey: "isLoadByLiuUniTab")
        let input = InputContext.shared.getCurrentInput()
        if isLoadByLiu, !getSpOfCharWithLiuTab(text).contains(input) {
            return false
        }
        if !isLoadByLiu, !getSpOfCharWithoutLiuTab(text).contains(input) {
            return false
        }
        return true
    }

    static func getIndexOfChr(_ input: String, _ chr: String) -> Int {
        let request = NSFetchRequest<Phrase>(entityName: "Phrase")
        request.predicate = NSPredicate(format: "key BEGINSWITH %@", input)
        request.sortDescriptors = [NSSortDescriptor(key: "key_priority", ascending: true)]
        do {
            let response = try PersistenceController.shared.container.viewContext.fetch(request)
            for i in 0 ... response.count {
                if response[i].value == chr {
                    return i
                }
            }
        } catch {
            NSLog(error.localizedDescription)
        }
        return -1
    }

    static func getSpOfCharWithoutLiuTab(_ chr: String) -> [String] {
        let request = NSFetchRequest<Phrase>(entityName: "Phrase")
        request.predicate = NSPredicate(format: "value == %@", chr)
        request.sortDescriptors = [NSSortDescriptor(key: "key_priority", ascending: true)]
        do {
            var shortestKeySet = Set<String>()
            var response = try PersistenceController.shared.container.viewContext.fetch(request)
            response = response.sorted { phr1, phr2 in
                phr1.key?.count ?? 0 < phr2.key?.count ?? 0
            }
            let shortestLen: Int = response.first?.key?.count ?? -1
            for item in response {
                if item.key?.count == shortestLen {
                    shortestKeySet.insert(item.key ?? "")
                } else {
                    break
                }
            }
            // 如果最短字根只有一個就直接回傳
            if shortestKeySet.count == 1 {
                return [shortestKeySet.first ?? ""]
            }
            // 如果最短字根不只一個就去比較這個字元在哪個字根priority比較早
            var curPriority = 100
            var res: [String] = []
            for keyItem in shortestKeySet {
                let idx = getIndexOfChr(keyItem, chr)
                if idx < curPriority {
                    curPriority = idx
                    res = [keyItem]
                } else if idx == curPriority {
                    res.append(keyItem)
                }
            }
            return res
        } catch {
            NSLog(error.localizedDescription)
        }
        return []
    }

    static func getSpOfCharWithLiuTab(_ chr: String) -> [String] {
        let request = NSFetchRequest<Phrase>(entityName: "Phrase")
        let keyPredicate = NSPredicate(format: "value == %@", chr)
        let spPredicate = NSPredicate(format: "sp == %@", NSNumber(value: true))
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [keyPredicate, spPredicate])
        do {
            let response = try PersistenceController.shared.container.viewContext.fetch(request)
            return response.map { $0.key ?? "" }
        } catch {
            NSLog(error.localizedDescription)
        }
        return []
    }

    static func getSpPhrasesForLiuTab(_ text: String) -> [Phrase] {
        let request = NSFetchRequest<Phrase>(entityName: "Phrase")
        let keyPredicate = NSPredicate(format: "key BEGINSWITH %@", text)
        let spPredicate = NSPredicate(format: "sp == %@", NSNumber(value: true))
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [keyPredicate, spPredicate])
        request.sortDescriptors = [NSSortDescriptor(key: "key_priority", ascending: true)]
        do {
            let response = try PersistenceController.shared.container.viewContext.fetch(request)
            return response
        } catch {
            NSLog(error.localizedDescription)
        }
        return []
    }
}
