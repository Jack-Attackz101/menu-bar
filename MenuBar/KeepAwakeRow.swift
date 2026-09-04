import SwiftUI

struct KeepAwakeRow: View {
    @EnvironmentObject private var keepAwake: KeepAwakeController

    var body: some View {
        Button(action: keepAwake.toggle) {
            Text(keepAwake.isEnabled ? "Keeping awake" : "Keep awake")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.ink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    Theme.mangoAction,
                    in: RoundedRectangle(cornerRadius: Theme.controlCornerRadius, style: .circular)
                )
        }
        .buttonStyle(StampPressStyle())
        .accessibilityLabel("Keep awake")
        .accessibilityValue(keepAwake.isEnabled ? "On" : "Off")
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Prevents the Mac from sleeping while on.")
    }
}

/// Flat press — no glass, no bounce. Offset reads as a stamp being pressed.
private struct StampPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.9 : 1)
            .offset(
                x: configuration.isPressed ? 1 : 0,
                y: configuration.isPressed ? 1 : 0
            )
    }
}

#Preview {
    KeepAwakeRow()
        .environmentObject(KeepAwakeController.shared)
        .padding(16)
        .background(Theme.ink)
}
