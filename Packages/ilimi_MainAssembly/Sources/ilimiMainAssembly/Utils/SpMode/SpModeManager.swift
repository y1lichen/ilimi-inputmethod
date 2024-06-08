//
//  File.swift
//
//
//  Created by 陳奕利 on 2024/5/2.
//

import CoreData
import Foundation

class SpModeManager {
    // MARK: Internal

    static func getSpKeyOfChar(_ chr: String) -> [String] {
        let isLoadByLiu = UserDefaults.standard.bool(forKey: "isLoadByLiuUniTab")
        if isLoadByLiu {
            return getSpOfCharWithLiuTab(chr)
        }
        return getSpOfCharWithoutLiuTab(chr)
    }

    static func checkInputIsSp(_ text: String, _ assistChar: String) -> Bool {
        // 在快打模式下標點符號不一定要是最短碼
        if InputContext.shared.getCurrentInput().first == "," {
            return true
        }
        let isLoadByLiu = UserDefaults.standard.bool(forKey: "isLoadByLiuUniTab")
        var input = InputContext.shared.getCurrentInput()
        if !assistChar.isEmpty {
            input.removeLast()
        }
        if isLoadByLiu, !getSpOfCharWithLiuTab(text).contains(input) {
            return false
        }
        if !isLoadByLiu, !getSpOfCharWithoutLiuTab(text).contains(input) {
            if handleMultipleSp(text, isLoadByLiu) {
                return true
            }
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

            // 如果最短字根只有一個且是第一位就直接回傳
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

    // MARK: Private
	// 快打模式下簡碼加選字碼可能和非簡碼有相同碼數
	// 使用.tab時不用特別處理，因使用.tab時簡碼判斷是直接讀字根檔
    // https://github.com/y1lichen/ilimi-inputmethod/issues/26
    private static func handleMultipleSp(_ text: String, _ isLoadByLiu: Bool) -> Bool {
        let sps: [String] = isLoadByLiu ? getSpOfCharWithLiuTab(text) : getSpOfCharWithoutLiuTab(text)
        if !sps.isEmpty {
            let minLen = sps.first!.count
            if InputEngine.shared.getPhraseExactly(sps.first!).first?.value != text,
               InputContext.shared.getCurrentInput().count == minLen + 1 {
                return true
            }
        }
        return false
    }
}
