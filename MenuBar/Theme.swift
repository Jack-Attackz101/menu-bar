import AppKit
import SwiftUI

/// Super Spade bubble tokens. No cream `#FFF9ED`, ink stamp, mango fruit, or `#FFC928` brand.
enum Theme {
    static let productName = "Super Spade"
    static let settingsHeader = "super spade"
    static let aboutLine = "Super Spade 1.0"
    static let keepAwakeAssertion = "Super Spade keep-awake"

    static let peach = Color(red: 1.0, green: 0.77, blue: 0.72)
    static let pink = Color(red: 0.96, green: 0.69, blue: 0.82)
    static let lavender = Color(red: 0.77, green: 0.71, blue: 0.99)
    static let sky = Color(red: 0.49, green: 0.83, blue: 0.99)
    static let teal = Color(red: 0.37, green: 0.91, blue: 0.83)

    static let glassFill = Color.white.opacity(0.12)
    static let glassBorder = Color.white.opacity(0.38)
    static let glassDeep = Color.black.opacity(0.34)
    static let glassSheen = Color.white.opacity(0.24)
    static let text = Color.white.opacity(0.95)
    static let textMuted = Color.white.opacity(0.62)
    static let liveDot = Color(red: 0.29, green: 0.87, blue: 0.50)
    static let keepAwakeTint = Color(red: 1.0, green: 0.62, blue: 0.48).opacity(0.32)
    static let weatherTint = Color(red: 125 / 255, green: 211 / 255, blue: 252 / 255).opacity(0.24)

    static let bubbleWidth: CGFloat = 360
    static let bubbleHeight: CGFloat = 508
    static let bubbleRadius: CGFloat = 22
    static let cardRadius: CGFloat = 12
    static let headerSize: CGFloat = 14
    static let rowSize: CGFloat = 12
    static let flipDigitWidth: CGFloat = 46
    static let flipDigitHeight: CGFloat = 70
}

enum KeepAwakeIdentity {
    static let assertionName = Theme.keepAwakeAssertion
}
