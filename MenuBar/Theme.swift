import AppKit
import SwiftUI

/// Mira 1.2 / Sol tokens. Match these hex values exactly.
enum Theme {
    /// Panel fill — dark notch hanging off the menu bar.
    static let ink = Color(hex: 0x24211D)
    /// Type on ink, and the cream mango tray stamp.
    static let cream = Color(hex: 0xFFF9ED)
    /// In-panel fruit fill (not the keep-awake button).
    static let fruit = Color(hex: 0xFFE169)
    /// In-panel leaf fill. No outline/stroke on the fruit mark.
    static let leaf = Color(hex: 0x4BA33D)
    /// Keep-awake control fill (mango action color).
    static let mangoAction = Color(hex: 0xFFC928)
    /// Reserved for later weather-strip rows.
    static let weatherStrip = Color(hex: 0xBFDDF3)

    static let controlCornerRadius: CGFloat = 16
    /// Print shadow once: `4px 4px 0 ink` — hard offset, no blur.
    static let printShadowOffset: CGFloat = 4
    static let panelWidth: CGFloat = 280

    static let inkNS = NSColor(srgbRed: 0x24 / 255, green: 0x21 / 255, blue: 0x1D / 255, alpha: 1)
    static let creamNS = NSColor(srgbRed: 0xFF / 255, green: 0xF9 / 255, blue: 0xED / 255, alpha: 1)
    static let fruitNS = NSColor(srgbRed: 0xFF / 255, green: 0xE1 / 255, blue: 0x69 / 255, alpha: 1)
    static let leafNS = NSColor(srgbRed: 0x4B / 255, green: 0xA3 / 255, blue: 0x3D / 255, alpha: 1)
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
