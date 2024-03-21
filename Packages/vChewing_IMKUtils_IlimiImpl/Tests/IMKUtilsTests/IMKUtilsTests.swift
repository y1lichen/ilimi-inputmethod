@testable import IMKUtils
import InputMethodKit
import XCTest

final class IMKUtilsTests: XCTestCase {
    func testPrintAllTISLayoutIdentifiers() throws {
        TISInputSource.getAllTISInputKeyboardLayoutMap().forEach {
            print($0.key)
        }
    }
}
