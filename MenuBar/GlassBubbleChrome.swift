import SwiftUI

/// Mesh / aurora wash — peach, pink, lavender, sky, teal. No cream or mango fill.
struct AuroraMesh: View {
    var body: some View {
        ZStack {
            Color(red: 0.10, green: 0.07, blue: 0.16).opacity(0.72)
            blob(Theme.peach, x: -96, y: -88, size: 250)
            blob(Theme.pink, x: 118, y: -78, size: 236)
            blob(Theme.lavender, x: 36, y: 46, size: 270)
            blob(Theme.sky, x: -78, y: 104, size: 228)
            blob(Theme.teal, x: 108, y: 132, size: 214)
            blob(Theme.lavender, x: -20, y: -10, size: 160)
            RadialGradient(
                colors: [Color.clear, Color.black.opacity(0.38)],
                center: .center,
                startRadius: 40,
                endRadius: 240
            )
        }
        .allowsHitTesting(false)
    }

    private func blob(_ color: Color, x: CGFloat, y: CGFloat, size: CGFloat) -> some View {
        Circle()
            .fill(color.opacity(0.62))
            .frame(width: size, height: size)
            .blur(radius: 46)
            .offset(x: x, y: y)
    }
}

struct GlassCard<Content: View>: View {
    var radius: CGFloat = Theme.cardRadius
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .fill(Theme.glassDeep.opacity(0.22))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .fill(Theme.glassFill)
                    }
                    .overlay(alignment: .top) {
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Theme.glassSheen, Color.clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                            .opacity(0.55)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .strokeBorder(Theme.glassBorder, lineWidth: 0.9)
                    }
                    .shadow(color: Color.black.opacity(0.22), radius: 10, x: 0, y: 6)
            }
    }
}

/// Frosted aurora bubble. macOS 14 path — material + overlay, no `containerBackground`.
struct GlassBubbleChrome<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(16)
            .frame(width: Theme.bubbleWidth, height: Theme.bubbleHeight, alignment: .top)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.bubbleRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: Theme.bubbleRadius, style: .continuous)
                        .fill(Theme.glassDeep.opacity(0.42))
                    AuroraMesh()
                        .clipShape(RoundedRectangle(cornerRadius: Theme.bubbleRadius, style: .continuous))
                    RoundedRectangle(cornerRadius: Theme.bubbleRadius, style: .continuous)
                        .fill(Theme.glassFill.opacity(0.55))
                    RoundedRectangle(cornerRadius: Theme.bubbleRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.50), Color.white.opacity(0.16)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.05
                        )
                    RoundedRectangle(cornerRadius: Theme.bubbleRadius - 3, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.10), lineWidth: 0.6)
                        .padding(3)
                }
            }
            .shadow(color: Color.black.opacity(0.36), radius: 28, x: 0, y: 14)
    }
}
