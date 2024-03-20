// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import AppKit
import CoreData
import Foundation

struct InputEngine {
    static let shared = InputEngine()

    // 取得以注音輸入的候選字
    func getCadidatesByZhuyin(_ text: String) {
        let request = NSFetchRequest<Zhuin>(entityName: "Zhuin")
        request.predicate = NSPredicate(format: "key BEGINSWITH %@", text)
        request.sortDescriptors = [
            NSSortDescriptor(key: "key.length", ascending: true),
            NSSortDescriptor(key: "key_priority", ascending: true),
        ]
        do {
            let response = try PersistenceController.shared.container.viewContext.fetch(request)
            let candidates: [String] = response.compactMap { $0.value }
            InputContext.shared.candidates = candidates
        } catch {
            NSLog(error.localizedDescription)
        }
    }

    // 取的以嘸蝦米輸入的候選字
    func getCandidates(_ text: String) {
        let request = NSFetchRequest<Phrase>(entityName: "Phrase")
        request.predicate = NSPredicate(format: "key BEGINSWITH %@", text)
        request.sortDescriptors = [NSSortDescriptor(key: "key_priority", ascending: true)]
        do {
            let response = try PersistenceController.shared.container.viewContext.fetch(request)
            var candidates: [String] = []
            var candidatesSet: Set<String> = []
            var inputStrSet: Set<String> = []
            for r in response {
                let value: String = r.value(forKey: "value") as! String
                if let rKey = r.key, rKey.count > text.count {
                    inputStrSet.insert(String(rKey.prefix(text.count + 1)))
                }
                if candidatesSet.contains(value) {
                    continue
                }
                candidatesSet.insert(value)
                candidates.append(value)
            }
            InputContext.shared.preInputPrefixSet = inputStrSet
            InputContext.shared.candidates = candidates
        } catch {
            NSLog(error.localizedDescription)
        }
    }

    // 取得相同讀音的候選字
    func getCandidatesByPronunciation(_ text: String) {
        let zhuyins: [String] = getKeysOfChar(text)
        let request = NSFetchRequest<Zhuin>(entityName: "Zhuin")
        var result: [String] = []
        do {
            for zhuyin in zhuyins {
                request.predicate = NSPredicate(format: "key == %@", zhuyin)
                let response = try PersistenceController.shared.container.viewContext.fetch(request)
                for item in response {
                    if let itemValue = item.value, itemValue != text {
                        result.append(itemValue)
                    }
                }
            }
            InputContext.shared.candidates = result
        } catch {
            NSLog(error.localizedDescription)
        }
    }

    // 取得文字的注音碼
    func getKeysOfChar(_ text: String) -> [String] {
        let request = NSFetchRequest<Zhuin>(entityName: "Zhuin")
        request.predicate = NSPredicate(format: "value == %@", text)
        do {
            let response = try PersistenceController.shared.container.viewContext.fetch(request)
            let res = response.compactMap { $0.key }
            return res
        } catch {
            NSLog(error.localizedDescription)
        }
        return []
    }
}
