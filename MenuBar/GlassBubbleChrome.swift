import SwiftUI

/// Mesh / aurora wash — peach, pink, lavender, sky, teal. No cream or mango fill.
struct AuroraMesh: View {
    var body: some View {
        ZStack {
            Color(red: 0.09, green: 0.07, blue: 0.14).opacity(0.78)
            blob(Theme.peach, x: -88, y: -76, size: 210)
            blob(Theme.pink, x: 104, y: -68, size: 198)
            blob(Theme.lavender, x: 28, y: 36, size: 220)
            blob(Theme.sky, x: -70, y: 92, size: 190)
            blob(Theme.teal, x: 96, y: 112, size: 176)
            RadialGradient(
                colors: [Color.clear, Color.black.opacity(0.42)],
                center: .center,
                startRadius: 28,
                endRadius: 210
            )
        }
        .allowsHitTesting(false)
    }

    private func blob(_ color: Color, x: CGFloat, y: CGFloat, size: CGFloat) -> some View {
        Circle()
            .fill(color.opacity(0.52))
            .frame(width: size, height: size)
            .blur(radius: 32)
            .offset(x: x, y: y)
    }
}

struct GlassCard<Content: View>: View {
    var radius: CGFloat = Theme.cardRadius
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .fill(Theme.glassDeep.opacity(0.18))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .fill(Theme.glassFill)
                    }
                    .overlay(alignment: .top) {
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Theme.glassSheen.opacity(0.7), Color.clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .strokeBorder(Theme.glassBorder, lineWidth: 0.6)
                    }
            }
    }
}

/// Sharper frosted aurora bubble. macOS 14 path — material + overlay, no `containerBackground`.
struct GlassBubbleChrome<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(12)
            .frame(width: Theme.bubbleWidth, height: Theme.bubbleHeight, alignment: .top)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.bubbleRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: Theme.bubbleRadius, style: .continuous)
                        .fill(Theme.glassDeep.opacity(0.38))
                    AuroraMesh()
                        .clipShape(RoundedRectangle(cornerRadius: Theme.bubbleRadius, style: .continuous))
                    RoundedRectangle(cornerRadius: Theme.bubbleRadius, style: .continuous)
                        .fill(Theme.glassFill.opacity(0.42))
                    RoundedRectangle(cornerRadius: Theme.bubbleRadius, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.42), lineWidth: 0.7)
                    RoundedRectangle(cornerRadius: Theme.bubbleRadius - 2, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5)
                        .padding(2)
                }
            }
            .shadow(color: Color.black.opacity(0.30), radius: 16, x: 0, y: 8)
    }
}
