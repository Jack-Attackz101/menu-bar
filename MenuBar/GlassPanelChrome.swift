import SwiftUI

/// Frosted settings / overflow chrome. Soft join to the bar is a capsule, not a caret.
struct GlassPanelChrome<Content: View>: View {
    var width: CGFloat
    var showsSoftJoin: Bool = true
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            if showsSoftJoin {
                Capsule()
                    .fill(.white.opacity(0.28))
                    .frame(width: 28, height: 5)
                    .padding(.top, 7)
                    .padding(.bottom, 4)
            }
            content()
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .padding(.top, showsSoftJoin ? 4 : 16)
        }
        .frame(width: width, alignment: .leading)
        .background {
            GlassBackdrop(corner: Theme.panelCorner, mesh: 0.38)
        }
    }
}

struct GlassActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Theme.text)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background {
                GlassBackdrop(corner: 12, mesh: configuration.isPressed ? 0.28 : 0.52)
            }
    }
}
