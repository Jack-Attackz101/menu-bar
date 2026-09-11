import AppKit
import SwiftUI

/// Thin filled spade used on the menu bar and in the bubble. Not a mango / fruit mark.
struct ThinSpade: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let cx = rect.midX
        var path = Path()

        path.move(to: CGPoint(x: cx, y: rect.minY + h * 0.05))
        path.addCurve(
            to: CGPoint(x: rect.minX + w * 0.07, y: rect.minY + h * 0.46),
            control1: CGPoint(x: cx - w * 0.03, y: rect.minY + h * 0.20),
            control2: CGPoint(x: rect.minX + w * 0.01, y: rect.minY + h * 0.32)
        )
        path.addCurve(
            to: CGPoint(x: cx, y: rect.minY + h * 0.58),
            control1: CGPoint(x: rect.minX + w * 0.12, y: rect.minY + h * 0.64),
            control2: CGPoint(x: cx - w * 0.15, y: rect.minY + h * 0.60)
        )
        path.addCurve(
            to: CGPoint(x: rect.maxX - w * 0.07, y: rect.minY + h * 0.46),
            control1: CGPoint(x: cx + w * 0.15, y: rect.minY + h * 0.60),
            control2: CGPoint(x: rect.maxX - w * 0.12, y: rect.minY + h * 0.64)
        )
        path.addCurve(
            to: CGPoint(x: cx, y: rect.minY + h * 0.05),
            control1: CGPoint(x: rect.maxX - w * 0.01, y: rect.minY + h * 0.32),
            control2: CGPoint(x: cx + w * 0.03, y: rect.minY + h * 0.20)
        )
        path.closeSubpath()

        let stemWidth = w * 0.11
        path.addRoundedRect(
            in: CGRect(
                x: cx - stemWidth / 2,
                y: rect.minY + h * 0.52,
                width: stemWidth,
                height: h * 0.36
            ),
            cornerSize: CGSize(width: stemWidth / 2, height: stemWidth / 2)
        )

        var base = Path()
        base.move(to: CGPoint(x: cx, y: rect.maxY - h * 0.18))
        base.addLine(to: CGPoint(x: cx - w * 0.20, y: rect.maxY - h * 0.03))
        base.addQuadCurve(
            to: CGPoint(x: cx + w * 0.20, y: rect.maxY - h * 0.03),
            control: CGPoint(x: cx, y: rect.maxY - h * 0.08)
        )
        base.closeSubpath()
        path.addPath(base)
        return path
    }
}

enum MenuBarSpade {
    /// Compact aurora-glass pill with a thin filled spade. Single status item — not a chip row.
    @MainActor
    static func image(scale: CGFloat = 2) -> NSImage {
        let view = MenuBarSpadeView()
        let renderer = ImageRenderer(content: view)
        renderer.scale = scale
        let image = renderer.nsImage ?? NSImage(size: NSSize(width: 28, height: ThinChipTokens.height))
        image.isTemplate = false
        return image
    }
}

struct MenuBarSpadeView: View {
    var body: some View {
        ThinSpade()
            .fill(Color.white.opacity(0.96))
            .overlay {
                ThinSpade()
                    .stroke(Color.white.opacity(0.55), lineWidth: 0.4)
            }
            .frame(width: 11, height: 12)
            .padding(.horizontal, 6)
            .frame(width: 26, height: ThinChipTokens.height)
            .background {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Capsule()
                            .fill(Theme.glassDeep.opacity(0.22))
                    }
                    .overlay {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Theme.lavender.opacity(0.50),
                                        Theme.sky.opacity(0.34),
                                        Theme.teal.opacity(0.28)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay {
                        Capsule().strokeBorder(Theme.glassBorder, lineWidth: 0.85)
                    }
            }
            .accessibilityLabel(Theme.productName)
    }
}
