@testable import ilimiMainAssembly
import XCTest

final class ilimiMainAssemblyTests: XCTestCase {
    func testExample() throws {
        DataInitializer.shared.initDataWhenStart()
    }
}
