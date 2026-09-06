import AppKit
import SwiftUI

/// Thin spade used on the menu bar and in the bubble. Not a mango / fruit mark.
struct ThinSpade: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX
        let top = rect.minY + rect.height * 0.10
        path.move(to: CGPoint(x: cx, y: top))
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.14, y: rect.midY + rect.height * 0.08),
            control1: CGPoint(x: cx - rect.width * 0.02, y: rect.minY + rect.height * 0.34),
            control2: CGPoint(x: rect.minX + rect.width * 0.06, y: rect.midY - rect.height * 0.04)
        )
        path.addCurve(
            to: CGPoint(x: cx, y: rect.midY + rect.height * 0.16),
            control1: CGPoint(x: rect.minX + rect.width * 0.26, y: rect.midY + rect.height * 0.26),
            control2: CGPoint(x: cx - rect.width * 0.12, y: rect.midY + rect.height * 0.20)
        )
        path.addCurve(
            to: CGPoint(x: rect.maxX - rect.width * 0.14, y: rect.midY + rect.height * 0.08),
            control1: CGPoint(x: cx + rect.width * 0.12, y: rect.midY + rect.height * 0.20),
            control2: CGPoint(x: rect.maxX - rect.width * 0.26, y: rect.midY + rect.height * 0.26)
        )
        path.addCurve(
            to: CGPoint(x: cx, y: top),
            control1: CGPoint(x: rect.maxX - rect.width * 0.06, y: rect.midY - rect.height * 0.04),
            control2: CGPoint(x: cx + rect.width * 0.02, y: rect.minY + rect.height * 0.34)
        )
        path.move(to: CGPoint(x: cx, y: rect.midY + rect.height * 0.14))
        path.addLine(to: CGPoint(x: cx, y: rect.maxY - rect.height * 0.08))
        path.move(to: CGPoint(x: cx - rect.width * 0.16, y: rect.maxY - rect.height * 0.14))
        path.addLine(to: CGPoint(x: cx + rect.width * 0.16, y: rect.maxY - rect.height * 0.14))
        return path
    }
}

enum MenuBarSpade {
    /// Compact aurora-glass pill with a thin spade. Single status item — not a chip row.
    @MainActor
    static func image(scale: CGFloat = 2) -> NSImage {
        let view = MenuBarSpadeView()
        let renderer = ImageRenderer(content: view)
        renderer.scale = scale
        let image = renderer.nsImage ?? NSImage(size: NSSize(width: 28, height: 22))
        image.isTemplate = false
        return image
    }
}

struct MenuBarSpadeView: View {
    var body: some View {
        ThinSpade()
            .stroke(Color.white.opacity(0.94), lineWidth: 1.35)
            .frame(width: 13, height: 13)
            .padding(.horizontal, 8)
            .frame(width: 28, height: 22)
            .background {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Theme.lavender.opacity(0.45),
                                        Theme.sky.opacity(0.35),
                                        Theme.teal.opacity(0.30)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay {
                        Capsule().strokeBorder(Theme.glassBorder, lineWidth: 0.8)
                    }
            }
            .accessibilityLabel(Theme.productName)
    }
}
