import SwiftUI

/// Frosted settings / overflow chrome. Radius 22. No cream, no caret.
struct GlassPanelChrome<Content: View>: View {
    var width: CGFloat
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(16)
            .frame(width: width, alignment: .leading)
            .background {
                DarkFrost(
                    shape: RoundedRectangle(cornerRadius: Theme.panelRadius, style: .continuous),
                    material: .thinMaterial
                )
            }
    }
}

struct GlassActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: Theme.rowSize, weight: .medium, design: .default))
            .foregroundStyle(Theme.text)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background {
                CompactGlass(height: 28)
            }
            .opacity(configuration.isPressed ? 0.82 : 1)
    }
}
