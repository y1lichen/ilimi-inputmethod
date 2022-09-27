//
//  InputEngine.swift
//  ilimi
//
//  Created by 陳奕利 on 2022/9/7.
//

import AppKit
import CoreData
import Foundation

struct InputEngine {
    static let shared = InputEngine()
    
    // 取得以注音輸入的候選字
    func getCadidatesByZhuyin(_ text: String) {
        let request = NSFetchRequest<Zhuin>(entityName: "Zhuin")
        request.predicate = NSPredicate(format: "key BEGINSWITH %@", text)
        request.sortDescriptors = [NSSortDescriptor(key: "key_priority", ascending: true)]
        do {
            let response = try PersistenceController.shared.container.viewContext.fetch(request)
            let candidates: [String] = response.map({ $0.value! })
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
                if r.key!.count > text.count {
                    inputStrSet.insert(String(r.key!.prefix(text.count + 1)))
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
                    if item.value! != text {
                        result.append(item.value!)
                    }
                }
            }
            InputContext.shared.candidates = result
        } catch {
            NSLog(error.localizedDescription)
        }
    }
    
    //取得文字的注音碼
    func getKeysOfChar(_ text: String) -> [String] {
        let request = NSFetchRequest<Zhuin>(entityName: "Zhuin")
        request.predicate = NSPredicate(format: "value == %@", text)
        do {
            let response = try PersistenceController.shared.container.viewContext.fetch(request)
            let res = response.map({ $0.key! })
            return res
        } catch {
            NSLog(error.localizedDescription)
        }
        return []
    }
}
