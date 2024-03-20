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
}
