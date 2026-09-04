import AppKit
import SwiftUI

/// Super Spade 1.0 — aurora glass. Not cream/ink product chrome.
enum Theme {
    static let peach = Color(hex: 0xFFD4C2)
    static let pink = Color(hex: 0xFFC2D6)
    static let lavender = Color(hex: 0xD4C8FF)
    static let sky = Color(hex: 0xC2E4FF)
    static let teal = Color(hex: 0xB6F0E6)

    /// Chip glyphs sit on aurora mesh.
    static let text = Color.white.opacity(0.92)
    static let textMuted = Color.white.opacity(0.62)

    /// Island / panel type on frost. Adapts with the material.
    static let islandText = Color.primary
    static let islandMuted = Color.secondary

    static let chipCorner: CGFloat = 12
    static let islandCorner: CGFloat = 22
    static let panelCorner: CGFloat = 22

    static let overflowPanelWidth: CGFloat = 268
    static let settingsPanelWidth: CGFloat = 228
    static let islandWidth: CGFloat = 228
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

struct AuroraMesh: View {
    var intensity: Double = 0.5

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.peach, Theme.pink.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            LinearGradient(
                colors: [Theme.lavender.opacity(0.75), Theme.sky.opacity(0.55), Theme.teal.opacity(0.7)],
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
        }
        .opacity(intensity)
        .allowsHitTesting(false)
    }
}

struct GlassBackdrop: View {
    var corner: CGFloat
    var mesh: Double = 0.45

    var body: some View {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay {
                AuroraMesh(intensity: mesh)
                    .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
            }
            .overlay {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.42), lineWidth: 0.6)
            }
    }
}
