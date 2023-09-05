//
//  Beep.swift
//  ilimi
//
//  Created by 陳奕利 on 2023/9/5.
//


extension IlimiInputController {
    func beep() {
        let isSilentMode = UserDefaults.standard.bool(forKey: "silentMode")
        if isSilentMode {
            return
        }
        NSSound.beep()
    }
}
