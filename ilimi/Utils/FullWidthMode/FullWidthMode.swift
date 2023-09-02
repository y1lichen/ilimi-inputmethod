//
//  FullWidthMode.swift
//  ilimi
//
//  Created by 陳奕利 on 2023/9/3.
//

extension IlimiInputController {
    func handleFullWidthMode(event: NSEvent, client sender: Any!) -> Bool {
        if !isFullWidthMode {
            return false
        }
        if let inputChar = event.characters?.first {
            commitText(client: sender, text: String(inputChar).fullWidth)
        }
        return true
    }
}
