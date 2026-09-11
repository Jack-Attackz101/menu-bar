import XCTest
@testable import MenuBar

final class ExtraIdentityTests: XCTestCase {
    func testPlaceholderItemTitleIsRejected() {
        XCTAssertTrue(ExtraIdentity.isPlaceholderTitle("Item 1"))
        XCTAssertTrue(ExtraIdentity.isPlaceholderTitle("Item 12"))
        XCTAssertFalse(ExtraIdentity.isPlaceholderTitle("Wi‑Fi"))
        XCTAssertFalse(ExtraIdentity.isPlaceholderTitle("Control Center"))
    }

    func testUntitledAXExtraUsesAppNameNotItemN() {
        let title = ExtraIdentity.resolvedTitle(
            axTitle: nil,
            axDescription: "  ",
            axHelp: nil,
            appName: "Control Center"
        )
        XCTAssertEqual(title, "Control Center")
        XCTAssertFalse(ExtraIdentity.isPlaceholderTitle(title))
    }

    func testRealAXTitleWins() {
        let title = ExtraIdentity.resolvedTitle(
            axTitle: "Wi‑Fi",
            axDescription: "Wi-Fi",
            axHelp: nil,
            appName: "Control Center"
        )
        XCTAssertEqual(title, "Wi‑Fi")
    }

    func testEmptyAppNameIsNotInvented() {
        XCTAssertNil(
            ExtraIdentity.resolvedTitle(
                axTitle: "Item 1",
                axDescription: nil,
                axHelp: nil,
                appName: "  "
            )
        )
    }

    func testHideCopyIsHonest() {
        XCTAssertTrue(ExtraHideCopy.caption(.axHidden).contains("Accessibility"))
        XCTAssertTrue(ExtraHideCopy.caption(.spacerCollapsed).contains("left of Super Spade"))
        XCTAssertTrue(ExtraHideCopy.caption(.stillVisible).contains("still on the system bar"))
        XCTAssertFalse(ExtraHideCopy.caption(.stillVisible).contains("hidden"))
    }

    func testSpacerLengthIsPublicCollapseNotMagic() {
        XCTAssertEqual(OverflowSpacer.length(collapsed: false, screenWidth: 1512), 0.5)
        XCTAssertEqual(OverflowSpacer.length(collapsed: true, screenWidth: 1512), 1512)
        XCTAssertEqual(OverflowSpacer.length(collapsed: true, screenWidth: 200), 800)
        XCTAssertEqual(OverflowSpacer.length(collapsed: true, screenWidth: 9000), 6000)
    }

    func testIconSourceLabels() {
        XCTAssertEqual(ExtraIconSource.axImage.label, "AX icon")
        XCTAssertEqual(ExtraIconSource.appIcon.label, "app icon")
        XCTAssertEqual(ExtraIconSource.none.label, "no icon")
    }
}

final class PinStoreTests: XCTestCase {
    func testPinsRoundTripAndDefaultEmpty() {
        let suite = "superSpade.tests.pins.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let store = PinStore(defaults: defaults, key: "pins")
        XCTAssertTrue(store.load().isEmpty)
        store.set(.keepAwake, pinned: true)
        store.set(.weather, pinned: true)
        XCTAssertEqual(store.load(), [.keepAwake, .weather])
        store.set(.keepAwake, pinned: false)
        XCTAssertEqual(store.load(), [.weather])
        defaults.removePersistentDomain(forName: suite)
    }
}
