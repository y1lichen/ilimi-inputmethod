// (c) 2022 and onwards The vChewing Project (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)
// ... with NTL restriction stating that:
// No trademark license is granted to use the trade names, trademarks, service
// marks, or product names of Contributor, except as required to fulfill notice
// requirements defined in MIT License.

import Foundation
import InputMethodKit

// MARK: - IMKHelper

public enum IMKHelper {
    public struct CarbonKeyboardLayout {
        var strName: String = ""
        var strValue: String = ""
    }

    /// 威注音有專門統計過，實際上會有差異的英數鍵盤佈局只有這幾種。
    /// 精簡成這種清單的話，不但節省 SwiftUI 的繪製壓力，也方便使用者做選擇。
    public static let arrWhitelistedKeyLayoutsASCII: [String] = {
        var results = LatinKeyboardMappings.allCases
        if #available(macOS 10.13, *) {
            results = results.filter {
                ![.qwertyUS, .qwertzGerman, .azertyFrench].contains($0)
            }
        }
        return results.map(\.rawValue)
    }()

    public static let arrDynamicBasicKeyLayouts: [String] = [
        "com.apple.keylayout.ZhuyinBopomofo",
        "com.apple.keylayout.ZhuyinEten",
    ]

    public static var allowedAlphanumericalTISInputSources: [TISInputSource.KeyboardLayout] {
        let allTISKeyboardLayouts = TISInputSource.getAllTISInputKeyboardLayoutMap()
        return arrWhitelistedKeyLayoutsASCII.compactMap { allTISKeyboardLayouts[$0] }
    }

    public static var allowedBasicLayoutsAsTISInputSources: [TISInputSource.KeyboardLayout?] {
        let allTISKeyboardLayouts = TISInputSource.getAllTISInputKeyboardLayoutMap()
        // 為了保證清單順序，先弄幾個容器。
        var containerA: [TISInputSource.KeyboardLayout?] = []
        var containerB: [TISInputSource.KeyboardLayout?] = []
        var containerC: [TISInputSource.KeyboardLayout] = []

        let filterSet = Array(Set(arrWhitelistedKeyLayoutsASCII).subtracting(Set(arrDynamicBasicKeyLayouts)))
        let matchedGroupBasic = (arrWhitelistedKeyLayoutsASCII + arrDynamicBasicKeyLayouts).compactMap {
            allTISKeyboardLayouts[$0]
        }
        for neta in matchedGroupBasic {
            if filterSet.contains(neta.id) {
                containerC.append(neta)
            } else if neta.id.hasPrefix("com.apple") {
                containerA.append(neta)
            } else {
                containerB.append(neta)
            }
        }

        // 這裡的 nil 是用來讓選單插入分隔符用的。
        if !containerA.isEmpty { containerA.append(nil) }
        if !containerB.isEmpty { containerB.append(nil) }

        return containerA + containerB + containerC
    }
}

// MARK: - 與輸入法的具體的安裝過程有關的命令

extension IMKHelper {
    @discardableResult
    public static func registerInputMethod() -> Int32 {
        TISInputSource.registerInputMethod() ? 0 : -1
    }
}
