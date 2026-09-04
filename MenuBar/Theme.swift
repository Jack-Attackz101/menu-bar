import AppKit
import SwiftUI

/// Mira tokens. Match these hex values exactly.
enum Theme {
    static let ink = Color(hex: 0x24211D)
    static let cream = Color(hex: 0xFFF9ED)
    static let weather = Color(hex: 0xBFDDF3)
    static let keepAwake = Color(hex: 0xFFC928)

    static let cornerRadius: CGFloat = 16
    /// Print shadow once: `4px 4px 0 ink` — hard offset, no blur.
    static let printShadowOffset: CGFloat = 4
    static let overflowPanelWidth: CGFloat = 260
    static let settingsPanelWidth: CGFloat = 220

    static let inkNS = NSColor(srgbRed: 0x24 / 255, green: 0x21 / 255, blue: 0x1D / 255, alpha: 1)
    static let creamNS = NSColor(srgbRed: 0xFF / 255, green: 0xF9 / 255, blue: 0xED / 255, alpha: 1)
    static let weatherNS = NSColor(srgbRed: 0xBF / 255, green: 0xDD / 255, blue: 0xF3 / 255, alpha: 1)
    static let keepAwakeNS = NSColor(srgbRed: 0xFF / 255, green: 0xC9 / 255, blue: 0x28 / 255, alpha: 1)
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
