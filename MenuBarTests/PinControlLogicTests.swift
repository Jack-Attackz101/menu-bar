import XCTest
@testable import MenuBar

final class PinControlLogicTests: XCTestCase {
    func testHitTargetIsLargerThanTheVisualChip() {
        XCTAssertEqual(PinControlLogic.visualHeight, ThinChipTokens.height)
        XCTAssertEqual(ThinChipTokens.height, 20)
        XCTAssertEqual(ThinChipTokens.stroke, 0.4)
        XCTAssertGreaterThanOrEqual(PinControlLogic.minHitHeight, 28)
        XCTAssertGreaterThanOrEqual(PinControlLogic.minHitWidth, 44)
        XCTAssertGreaterThan(PinControlLogic.minHitHeight, PinControlLogic.visualHeight)
        XCTAssertTrue(PinControlLogic.usesQuietChrome(pinned: true))
        XCTAssertFalse(PinControlLogic.usesQuietChrome(pinned: false))
    }

    func testPinLabelsStayUniquePerWidget() {
        let labels = PinnableWidget.allCases.map {
            PinControlLogic.accessibilityLabel(widget: $0, pinned: false)
        }
        XCTAssertEqual(Set(labels).count, labels.count)
        XCTAssertEqual(
            PinControlLogic.accessibilityLabel(widget: .flipClock, pinned: false),
            "Pin Flip clock to menu bar"
        )
        XCTAssertEqual(
            PinControlLogic.accessibilityLabel(widget: .usage, pinned: false),
            "Pin Claude / Codex to menu bar"
        )
        XCTAssertEqual(
            PinControlLogic.accessibilityLabel(widget: .flipClock, pinned: true),
            "Unpin Flip clock"
        )
    }

    func testPinIdentifiersAreStableAndUnique() {
        let ids = PinnableWidget.allCases.map(PinControlLogic.accessibilityIdentifier)
        XCTAssertEqual(Set(ids).count, ids.count)
        XCTAssertEqual(ids.first { $0.contains("flipClock") }, "super-spade.pin.flipClock")
        XCTAssertEqual(ids.first { $0.contains("usage") }, "super-spade.pin.usage")
        for id in ids {
            XCTAssertFalse(id.contains("/"), "AX search flakes on slash-y identifiers")
            XCTAssertTrue(id.hasPrefix("super-spade.pin."))
        }
    }

    func testChipInstallOrderIsRightmostFirstWithoutHostRebuild() {
        XCTAssertTrue(PinControlLogic.preservesHostAndBubbleOnPinChange)
        XCTAssertEqual(
            PinControlLogic.chipInstallOrder([.keepAwake, .flipClock, .usage]),
            [.usage, .flipClock, .keepAwake]
        )
        XCTAssertEqual(PinControlLogic.chipInstallOrder([]), [])
        let delta = PinControlLogic.chipDelta(existing: [.keepAwake], desired: [.keepAwake, .usage])
        XCTAssertEqual(delta.add, [.usage])
        XCTAssertTrue(delta.remove.isEmpty)
    }
}
