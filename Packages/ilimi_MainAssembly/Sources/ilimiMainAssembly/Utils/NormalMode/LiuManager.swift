//
//  File.swift
//
//
//  Created by 陳奕利 on 2024/6/9.
//

import CoreData
import Foundation
import SwiftUI

struct LiuManager {
    static let shared = LiuManager()

    @StateObject var settingsModel = SettingViewModel.shared

    func getPhraseExactly(_ text: String) -> [Phrase] {
        let request = NSFetchRequest<Phrase>(entityName: "Phrase")
        request.predicate = NSPredicate(format: "key == %@", text)
        request.sortDescriptors = [NSSortDescriptor(key: "key_priority", ascending: true)]
        do {
            let response = try PersistenceController.shared.container.viewContext.fetch(request)
            return response
        } catch {
            NSLog(error.localizedDescription)
        }
        return []
    }

    func getNormalModePhrase(_ text: String) -> [Phrase] {
        let request = NSFetchRequest<Phrase>(entityName: "Phrase")
        request.predicate = settingsModel
            .showOnlyExactlyMatch ? NSPredicate(format: "key == %@", text) :
            NSPredicate(format: "key BEGINSWITH %@", text)
        request.sortDescriptors = [NSSortDescriptor(key: "key_priority", ascending: true)]
        do {
            let response = try PersistenceController.shared.container.viewContext.fetch(request)
            return response
        } catch {
            NSLog(error.localizedDescription)
        }
        return []
    }

    func getKeysOfChar(_ chr: String) -> [Phrase] {
        let request = NSFetchRequest<Phrase>(entityName: "Phrase")
        request.predicate = NSPredicate(format: "value == %@", chr)
        do {
            let response = try PersistenceController.shared.container.viewContext.fetch(request)
            return response
        } catch {
            NSLog(error.localizedDescription)
        }
        return []
    }

    func checkIsFirstCandidates(_ input: String, _ chr: String) -> Bool {
        getPhraseExactly(input).first?.value == chr
    }
}
