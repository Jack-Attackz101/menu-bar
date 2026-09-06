import SwiftUI

/// Mesh / aurora wash — peach, pink, lavender, sky, teal. No cream or mango fill.
struct AuroraMesh: View {
    var body: some View {
        ZStack {
            Color(red: 0.16, green: 0.12, blue: 0.22).opacity(0.42)
            blob(Theme.peach, x: -90, y: -80, size: 220)
            blob(Theme.pink, x: 110, y: -70, size: 210)
            blob(Theme.lavender, x: 40, y: 40, size: 240)
            blob(Theme.sky, x: -70, y: 90, size: 200)
            blob(Theme.teal, x: 100, y: 120, size: 190)
        }
        .allowsHitTesting(false)
    }

    private func blob(_ color: Color, x: CGFloat, y: CGFloat, size: CGFloat) -> some View {
        Circle()
            .fill(color.opacity(0.55))
            .frame(width: size, height: size)
            .blur(radius: 42)
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
                            .fill(Theme.glassFill)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .strokeBorder(Theme.glassBorder, lineWidth: 0.8)
                    }
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
                    AuroraMesh()
                        .clipShape(RoundedRectangle(cornerRadius: Theme.bubbleRadius, style: .continuous))
                    RoundedRectangle(cornerRadius: Theme.bubbleRadius, style: .continuous)
                        .fill(Theme.glassFill)
                    RoundedRectangle(cornerRadius: Theme.bubbleRadius, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.34), lineWidth: 0.9)
                }
            }
            .shadow(color: Color.black.opacity(0.22), radius: 22, x: 0, y: 10)
    }
}
