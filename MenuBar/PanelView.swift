import AppKit
import SwiftUI

/// Ink notch hanging off the menu bar: square top flush with the bar, 16pt bottom corners.
struct PanelNotchShape: Shape {
    var bottomRadius: CGFloat = 16

    func path(in rect: CGRect) -> Path {
        UnevenRoundedRectangle(
            cornerRadii: RectangleCornerRadii(
                topLeading: 0,
                bottomLeading: bottomRadius,
                bottomTrailing: bottomRadius,
                topTrailing: 0
            ),
            style: .circular
        )
        .path(in: rect)
    }
}

struct PanelView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            KeepAwakeRow()

            HStack {
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.cream.opacity(0.72))
            }
        }
        .padding(16)
        .frame(width: Theme.panelWidth)
        .background(Theme.ink, in: PanelNotchShape())
        .compositingGroup()
        .shadow(color: Theme.ink, radius: 0, x: Theme.printShadowOffset, y: Theme.printShadowOffset)
        .padding(.trailing, Theme.printShadowOffset)
        .padding(.bottom, Theme.printShadowOffset)
        .background(PanelWindowConfigurator())
        .containerBackground(.clear, for: .window)
        // Later rows (not in this slice): quota, weather, CPU, calendar — keep-awake stays last.
    }
}

#Preview("Ink panel") {
    PanelView()
        .environmentObject(KeepAwakeController.shared)
}
