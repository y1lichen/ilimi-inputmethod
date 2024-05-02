//
//  File.swift
//
//
//  Created by 陳奕利 on 2024/4/25.
//

import CoreData
import Foundation

class LiuUniTabConverter {
    let persistenceContainer = PersistenceController.shared
    let userDefaults = UserDefaults.standard
    var bytes: [UInt8] = []

    init(filename: String = "liu-uni.tab") {
        do {
            let fileData = try Data(contentsOf: URL(fileURLWithPath: DataInitializer.appSupportDir + "/" + filename))
            bytes = [UInt8](fileData)
        } catch {
            print("Failed to read file:", error)
        }
    }

	func getint16(addr: Int) -> Int {
		return Int(bytes[addr]) | Int(bytes[addr + 1]) << 8
	}

	func getbits(_ start: Int, _ nbit: Int, _ i: Int) -> Int {
		if nbit == 1 || nbit == 2 || nbit == 4 {
			let byte = bytes[start + i * nbit / 8]
			let ovalue = Int(byte) >> (8 - nbit - i * nbit % 8)
			return ovalue & ((1 << nbit) - 1)
		} else if nbit > 0 && nbit % 8 == 0 {
			let nbyte = nbit / 8
			var value: Int = 0
			var a = start + i * nbyte
			for _ in 0..<nbyte {
				value = value << 8 | Int(bytes[a])
				a += 1
			}
			return value
		} else {
			fatalError("Invalid nbit")
		}
	}

    func utf8_chr(ord: Int) -> String {
        return String(UnicodeScalar(ord)!)
    }

    func mb_str_split(_ str: String) -> [String] {
        return str.map { String($0) }
    }

    func convertLiuUniTab() {
        DataInitializer.shared.cleanAllData("Phrase")
        let i1 = getint16(addr: 0)
        _ = getint16(addr: 4)
        let i2 = i1 + getint16(addr: 2) // or + (words*2+7)/8
        let i3 = i2 + getint16(addr: 6) // or + (words*1+7)/8
        let i4 = i3 + getint16(addr: 6) // or + (words*1+7)/8

		let rootkey: [Character] = Array(" abcdefghijklmnopqrstuvwxyz,.'[]")

        var count = 0
        for i in 0 ..< 1024 {
			var key: [Character] = [Character](repeating: Character(" "), count: 4)
			
            key[0] = (rootkey[i / 32])
            key[1] = (rootkey[i % 32])

            if key[0] == " " { continue }

            for ci in getint16(addr: i * 2) ..< getint16(addr: i * 2 + 2) {
				let bit24 = getbits(i4, 24, ci)
				let hi = getbits(i1, 2, ci)
                let lo = bit24 & 0x3fff
				key[2] = rootkey[bit24 >> 19]
				key[3] = rootkey[bit24 >> 14 & 0x1f]

				let keyString = String(key).trimmingCharacters(in: .whitespacesAndNewlines)
				let chr = utf8_chr(ord: hi << 14 | lo)

				let flag_sp = getbits(i3, 1, ci)
                writeData(keyString, chr, Int64(count), flag_sp == 0 ? true : false)
//                let flag_unknown = getbits(start: Int(i2), nbit: 1, i: Int(ci))
                count += 1
            }
        }
        persistenceContainer.saveContext()
        userDefaults.set(true, forKey: "hadReadLiuJson")
        userDefaults.set(true, forKey: "isLoadByLiuUniTab")
        NotifierController.notify(message: "自liu-uni.tab讀取\(count)個字元")
    }

    func writeData(_ key: String, _ value: String, _ priority: Int64, _ sp: Bool) {
        let model = NSEntityDescription.insertNewObject(
            forEntityName: "Phrase",
            into: persistenceContainer.container.viewContext
        )
        guard let model = model as? Phrase else { return }
        model.key_priority = priority
        model.key = key
        model.value = value
        model.sp = sp
    }
}
