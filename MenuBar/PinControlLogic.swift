import Foundation

/// Pin-to-bar control metrics and chip order. Pure so Finn can unit-test without AppKit.
enum PinControlLogic {
    /// Visible glass chip — matches the locked on-bar Sol stamp, not a chunky pill.
    static let visualHeight: CGFloat = 20
    static let fontSize: CGFloat = 11
    static let paddingX: CGFloat = 10

    /// Automation + finger hit box around the thin chip. Clock / usage pins sat at 16×~28.
    static let minHitHeight: CGFloat = 28
    static let minHitWidth: CGFloat = 44

    /// Pin / unpin must not destroy the host spade or dismiss the bubble.
    static let preservesHostAndBubbleOnPinChange = true

    /// Unpin stays a 44×28 target but drops the filled glass pill.
    static func usesQuietChrome(pinned: Bool) -> Bool {
        pinned
    }

    static func accessibilityLabel(widget: PinnableWidget, pinned: Bool) -> String {
        pinned ? "Unpin \(widget.title)" : "Pin \(widget.title) to menu bar"
    }

    static func accessibilityIdentifier(widget: PinnableWidget) -> String {
        "super-spade.pin.\(widget.rawValue)"
    }

    /// First created sits rightmost (host is already installed).
    static func chipInstallOrder(_ desired: Set<PinnableWidget>) -> [PinnableWidget] {
        PinnableWidget.allCases.reversed().filter(desired.contains)
    }

    static func chipDelta(
        existing: Set<PinnableWidget>,
        desired: Set<PinnableWidget>
    ) -> (add: [PinnableWidget], remove: [PinnableWidget]) {
        (
            add: chipInstallOrder(desired.subtracting(existing)),
            remove: PinnableWidget.allCases.filter { existing.contains($0) && !desired.contains($0) }
        )
    }
}
