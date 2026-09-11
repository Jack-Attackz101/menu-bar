import SwiftUI

/// Mesh / aurora wash — peach, pink, lavender, sky, teal. No cream or mango fill.
struct AuroraMesh: View {
    var intensity: Double = 1

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.05, blue: 0.12).opacity(0.40 * intensity)
            blob(Theme.peach, x: -98, y: -86, size: 268)
            blob(Theme.pink, x: 118, y: -78, size: 250)
            blob(Theme.lavender, x: 18, y: 32, size: 286)
            blob(Theme.sky, x: -86, y: 112, size: 236)
            blob(Theme.teal, x: 112, y: 132, size: 224)
            blob(Theme.pink, x: -36, y: 18, size: 168)
            blob(Theme.sky, x: 72, y: -16, size: 158)
            RadialGradient(
                colors: [Color.clear, Color.black.opacity(0.16 * intensity)],
                center: .center,
                startRadius: 46,
                endRadius: 236
            )
        }
        .allowsHitTesting(false)
    }

    private func blob(_ color: Color, x: CGFloat, y: CGFloat, size: CGFloat) -> some View {
        Circle()
            .fill(color.opacity(0.74 * intensity))
            .frame(width: size, height: size)
            .blur(radius: 48)
            .offset(x: x, y: y)
    }
}

/// Shared frost + aurora stack for the bubble and tiles. Deeper bleed, still no mango cream/ink.
struct AuroraGlassFill: View {
    var radius: CGFloat
    var intensity: Double = 1
    var materialOpacity: Double = 1

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(.ultraThinMaterial)
                .opacity(materialOpacity)
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(Theme.glassDeep.opacity(0.16 * intensity))
            AuroraMesh(intensity: intensity)
                .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(Theme.glassFill.opacity(0.22))
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Theme.glassSheen.opacity(0.88 * intensity), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(Theme.glassBorder.opacity(0.92), lineWidth: 0.55)
            RoundedRectangle(cornerRadius: max(radius - 2, 1), style: .continuous)
                .strokeBorder(Color.white.opacity(0.12 * intensity), lineWidth: 0.45)
                .padding(1.5)
        }
    }
}

struct GlassCard<Content: View>: View {
    var radius: CGFloat = Theme.cardRadius
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(10)
            .background {
                AuroraGlassFill(radius: radius, intensity: 0.62)
            }
    }
}

/// Deeper frosted aurora bubble. macOS 14 path — material + overlay, no `containerBackground`.
struct GlassBubbleChrome<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(12)
            .frame(width: Theme.bubbleWidth, height: Theme.bubbleHeight, alignment: .top)
            .background {
                AuroraGlassFill(radius: Theme.bubbleRadius, intensity: 1)
            }
            .shadow(color: Color.black.opacity(0.34), radius: 18, x: 0, y: 9)
    }
}
