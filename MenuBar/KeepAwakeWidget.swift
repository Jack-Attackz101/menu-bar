import SwiftUI

struct KeepAwakeWidget: View {
    @ObservedObject var keepAwake: KeepAwakeController

    var body: some View {
        Button(action: keepAwake.toggle) {
            HStack(spacing: 8) {
                Image(systemName: keepAwake.isEnabled ? "bolt.fill" : "bolt")
                    .font(.system(size: 12, weight: .semibold))
                Text(keepAwake.isEnabled ? "Keeping awake" : "Keep awake")
                    .font(.system(size: 12, weight: .semibold, design: .default))
                Spacer(minLength: 0)
                Circle()
                    .fill(keepAwake.isEnabled ? Theme.liveDot : Color.white.opacity(0.22))
                    .frame(width: 7, height: 7)
            }
            .foregroundStyle(Theme.text)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Theme.keepAwakeTint)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Theme.glassBorder, lineWidth: 0.8)
                    }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Keep awake")
        .accessibilityValue(keepAwake.isEnabled ? "On" : "Off")
        .accessibilityHint("Holds Super Spade keep-awake so the Mac does not sleep.")
    }
}

struct WeatherStub: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "sun.max")
                .font(.system(size: 12, weight: .semibold))
            VStack(alignment: .leading, spacing: 1) {
                Text("72°")
                    .font(.system(size: 13, weight: .semibold, design: .default))
                Text("Clear · stub")
                    .font(.system(size: 10, weight: .regular, design: .default))
                    .foregroundStyle(Theme.textMuted)
            }
            Spacer(minLength: 0)
        }
        .foregroundStyle(Theme.text)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Theme.weatherTint)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Theme.glassBorder, lineWidth: 0.8)
                }
        }
        .accessibilityLabel("Weather stub, 72 degrees, clear")
    }
}
