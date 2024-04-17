@testable import IMKUtils
import InputMethodKit
import XCTest

final class IMKUtilsTests: XCTestCase {
    func testPrintAllTISLayoutIdentifiers() throws {
        for item in TISInputSource.getAllTISInputKeyboardLayoutMap() {
            print(item.key)
        }
    }
}
