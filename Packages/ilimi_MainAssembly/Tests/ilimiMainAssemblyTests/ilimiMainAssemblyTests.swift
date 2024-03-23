@testable import ilimiMainAssembly
import XCTest

final class ilimiMainAssemblyTests: XCTestCase {
    func testDataLoadAndQuery() throws {
        DataInitializer.shared.initDataWhenStart()
        DataInitializer.shared.loadLiuData()
        DataInitializer.shared.loadPinyinJson()
        let sharedEngine = InputEngine.shared
        let sharedInputContext = InputContext.shared
        sharedEngine.getCandidates(",]]")
        XCTAssertNotEqual(0, sharedInputContext.candidates.count)
        print("Found \(sharedInputContext.candidates.count) candidates.")
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
}
