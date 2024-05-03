@testable import ilimiMainAssembly
import XCTest

final class ilimiMainAssemblyTests: XCTestCase {
	func testGetSpOfCharWithoutLiuTab() throws {
		DataInitializer.shared.initDataWhenStart()
		print(SpModeManager.getSpOfCharWithoutLiuTab("嘸") as Any)
		print(SpModeManager.getSpOfCharWithoutLiuTab("蝦") as Any)
	}
	
	func testConvertLiuTab() throws {
		LiuUniTabConverter().convertLiuUniTab()
		let sharedEngine = InputEngine.shared
		let sharedInputContext = InputContext.shared
		sharedEngine.getCandidates("dez")
		XCTAssertNotEqual(0, sharedInputContext.candidates.count)
		print(sharedInputContext.candidates)
	}
	
    func testDataLoadAndQuery() throws {
        DataInitializer.shared.initDataWhenStart()
        DataInitializer.shared.loadLiuData()
        DataInitializer.shared.loadPinyinJson()
        let sharedEngine = InputEngine.shared
        let sharedInputContext = InputContext.shared
//        sharedEngine.getCandidates(",]]")
//		sharedEngine.getCandidates("ix")
//        XCTAssertNotEqual(0, sharedInputContext.candidates.count)
//		print(sharedInputContext.candidates)
//        print("Found \(sharedInputContext.candidates.count) candidates.")
		sharedEngine.getCandidates("dez")
		XCTAssertNotEqual(0, sharedInputContext.candidates.count)
		print(sharedInputContext.candidates)
    }

    // 測試同音輸入
    func testFindCharWithSamePronunciation() throws {
        DataInitializer.shared.initDataWhenStart()
        DataInitializer.shared.loadLiuData()
        DataInitializer.shared.loadPinyinJson()
        let res = CoreDataHelper.getCharWithSamePronunciation("我")
        XCTAssertNotEqual(0, res.count)
        print("Found \(res.count) candidates.")
    }
	
	func testReadCin() throws {
		let sharedEngine = InputEngine.shared
		let sharedInputContext = InputContext.shared
		let reader = CinReader()
		reader.readCin()
		sharedEngine.getCandidates("dez")
		XCTAssertNotEqual(0, sharedInputContext.candidates.count)
		print(sharedInputContext.candidates)
	}
}
