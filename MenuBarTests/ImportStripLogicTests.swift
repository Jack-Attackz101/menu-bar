import XCTest
@testable import MenuBar

final class ImportStripLogicTests: XCTestCase {
    private let wifi = DiscoveredExtra(id: "wifi.1", title: "Wi‑Fi", appName: "Control Center")
    private let sound = DiscoveredExtra(id: "sound.1", title: "Sound", appName: "Control Center")

    func testDeniedBeforePrompt() {
        let state = ImportStripLogic.state(
            trusted: false,
            prompted: false,
            discovered: [],
            imported: []
        )
        XCTAssertEqual(state, .denied)
        XCTAssertTrue(ImportStripLogic.body(state).contains("cannot steal"))
        XCTAssertEqual(ImportStripLogic.headline(state), "Accessibility needed")
    }

    func testDeniedWaitingAfterPrompt() {
        let state = ImportStripLogic.state(
            trusted: false,
            prompted: true,
            discovered: [],
            imported: []
        )
        XCTAssertEqual(state, .deniedWaiting)
        XCTAssertTrue(ImportStripLogic.body(state).contains("quit Super Spade"))
        XCTAssertTrue(ImportStripLogic.body(state).contains("reopen"))
    }

    func testGrantedEmptyIsIntentional() {
        let state = ImportStripLogic.state(
            trusted: true,
            prompted: true,
            discovered: [],
            imported: []
        )
        XCTAssertEqual(state, .grantedEmpty)
        XCTAssertTrue(ImportStripLogic.body(state).contains("placeholders"))
        XCTAssertTrue(ImportStripLogic.body(state).contains("AXExtrasMenuBar"))
    }

    func testGrantedAvailableMakesClickToBookmarkObvious() {
        let state = ImportStripLogic.state(
            trusted: true,
            prompted: false,
            discovered: [wifi, sound],
            imported: [wifi]
        )
        XCTAssertEqual(state, .grantedAvailable)
        XCTAssertTrue(ImportStripLogic.headline(state).lowercased().contains("bookmark"))
        XCTAssertTrue(ImportStripLogic.body(state).contains("Click a real extra"))
    }

    func testGrantedAllBookmarked() {
        let state = ImportStripLogic.state(
            trusted: true,
            prompted: false,
            discovered: [wifi],
            imported: [wifi]
        )
        XCTAssertEqual(state, .grantedAllBookmarked)
        XCTAssertTrue(ImportStripLogic.body(state).contains("right-click"))
    }

    func testAvailableExtrasOmitsImported() {
        let extras = ImportStripLogic.available(discovered: [wifi, sound], imported: [wifi])
        XCTAssertEqual(extras.map(\.id), [sound.id])
    }
}
