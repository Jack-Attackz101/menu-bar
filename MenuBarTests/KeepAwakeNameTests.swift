import XCTest
@testable import MenuBar

final class KeepAwakeNameTests: XCTestCase {
    func testAssertionNameIsLocked() {
        XCTAssertEqual(KeepAwakeIdentity.assertionName, "Super Spade keep-awake")
        XCTAssertEqual(Theme.keepAwakeAssertion, "Super Spade keep-awake")
    }

    func testProductCopyIsLocked() {
        XCTAssertEqual(Theme.productName, "Super Spade")
        XCTAssertEqual(Theme.settingsHeader, "super spade")
        XCTAssertEqual(Theme.aboutLine, "Super Spade 1.0")
    }
}
