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
                if candidatesSet.contains(value) {
                    continue
                }
                if r.key!.count > text.count {
                    inputStrSet.insert(String(r.key!.prefix(text.count + 1)))
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
