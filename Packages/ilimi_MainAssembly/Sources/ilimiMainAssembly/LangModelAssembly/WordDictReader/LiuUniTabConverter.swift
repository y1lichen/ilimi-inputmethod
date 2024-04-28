//
//  File.swift
//
//
//  Created by 陳奕利 on 2024/4/25.
//

import Foundation

class LiuUniTabConverter {
	var bytes: [UInt8] = []

	init(filename: String = "liu-uni.tab") {
		do {
			let fileData = try Data(contentsOf: URL(fileURLWithPath: DataInitializer.appSupportDir + "/" + filename))
			bytes = [UInt8](fileData)
		} catch {
			print("Failed to read file:", error)
		}
	}

	func getint16(addr: Int) -> UInt16 {
		return UInt16(bytes[addr]) | UInt16(bytes[addr+1]) << 8
	}

	func getbits(start: Int, nbit: Int, i: Int) -> UInt16 {
		if nbit == 1 || nbit == 2 || nbit == 4 {
			let byte = bytes[start + i * nbit / 8]
			let ovalue = byte >> (8 - nbit - i * nbit % 8)
			return UInt16(ovalue & ((1 << nbit) - 1))
		} else if nbit > 0 && nbit % 8 == 0 {
			let nbyte = nbit / 8
			var value: UInt16 = 0
			var a = start + i * nbyte
			var nByteTemp = nbyte
			while nByteTemp > 0 {
				value = value << 8 | UInt16(bytes[a])
				a += 1
				nByteTemp -= 1
			}
			return value
		} else {
			fatalError("Invalid nbit value")
		}
	}

	func utf8_chr(ord: UInt16) -> String {
		return String(UnicodeScalar(ord)!)
	}

	func convertLiuUniTab() {
		let i1 = getint16(addr: 0)
		let _ = getint16(addr: 4)
		let i2 = i1 + getint16(addr: 2) // or + (words*2+7)/8
		let i3 = i2 + getint16(addr: 6) // or + (words*1+7)/8
		let i4 = i3 + getint16(addr: 6) // or + (words*1+7)/8

		let rootkey = Array(" abcdefghijklmnopqrstuvwxyz,.'[]")

		var step = 0
		for i in 0..<1024 {
			var key = String(rootkey[i/32]) + String(rootkey[i%32])
			if key.first == " " {
				continue
			}

			for ci in getint16(addr: i*2)..<getint16(addr: i*2+2) {
				let bit24 = getbits(start: Int(i4), nbit: 24, i: Int(ci))
				let hi = getbits(start: Int(i1), nbit: 2, i: Int(ci))
				let lo = bit24 & 0x3fff

				key += String(rootkey[Int(bit24>>19)]) + String(rootkey[Int(bit24>>14 & 0x1f)])
				key = key.replacingOccurrences(of: " ", with: "")
				if key.count > 4 {
					continue
				}

				print("[\(key)]", terminator: "\t")
				print(utf8_chr(ord: hi<<14 | lo), terminator: "")
				let flag_sp = getbits(start: Int(i3), nbit: 1, i: Int(ci))
				let flag_unknown = getbits(start: Int(i2), nbit: 1, i: Int(ci))
				print(flag_sp == 1 ? "" : "", terminator: "")
				print(flag_unknown == 1 ? "" : "")
				step += 1
			}
		}
	}
}

