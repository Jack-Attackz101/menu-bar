import SwiftUI

/// Dual Claude + Codex usage as clear bar meters. Not a CPU graph.
struct DualUsageMeter: View {
    var claude: UsageReading
    var codex: UsageReading
    var now: Date = Date()
    var onRetry: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            meter(claude, tint: Theme.lavender)
            meter(codex, tint: Theme.teal)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Claude and Codex usage")
        .accessibilityValue("\(claude.label) \(UsageDisplay.usageLine(used: claude.fraction)). \(codex.label) \(UsageDisplay.usageLine(used: codex.fraction)).")
    }

    private func meter(_ reading: UsageReading, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .firstTextBaseline) {
                Text(reading.label)
                    .font(.system(size: 12, weight: .semibold, design: .default))
                    .foregroundStyle(Theme.text)
                statusChip(reading.source)
                Spacer(minLength: 8)
                Text(UsageDisplay.percentUsed(reading.fraction))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Theme.text)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.glassDeep.opacity(0.55))
                        .overlay {
                            Capsule().strokeBorder(Color.white.opacity(0.10), lineWidth: 0.6)
                        }
                    if reading.source != .empty {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [tint.opacity(0.95), tint.opacity(0.62)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: barWidth(in: geo.size.width, reading: reading))
                            .opacity(reading.source == .loading ? 0.55 : 0.95)
                            .shadow(color: tint.opacity(0.28), radius: 4, x: 0, y: 0)
                    }
                }
            }
            .frame(height: 11)

            HStack(alignment: .firstTextBaseline) {
                Text(reading.source == .empty ? "Add a key or leave demo on" : UsageDisplay.remainingLabel(reading.fraction))
                    .font(.system(size: 10, weight: .medium, design: .default))
                    .foregroundStyle(Theme.textMuted)
                Spacer(minLength: 8)
                footer(reading)
            }
        }
    }

    @ViewBuilder
    private func footer(_ reading: UsageReading) -> some View {
        let text = UsageDisplay.footer(reading, now: now)
        if reading.source == .error, let onRetry {
            Button("Retry") { onRetry() }
                .buttonStyle(.plain)
                .font(.system(size: 10, weight: .semibold, design: .default))
                .foregroundStyle(Theme.sky)
                .accessibilityLabel("Retry \(reading.label) usage")
        } else {
            Text(text)
                .font(.system(size: 10, weight: .regular, design: .default))
                .foregroundStyle(Theme.textMuted)
                .lineLimit(1)
        }
    }

    private func statusChip(_ source: UsageSource) -> some View {
        Text(chipLabel(source))
            .font(.system(size: 9, weight: .semibold, design: .default))
            .foregroundStyle(chipColor(source))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background {
                Capsule()
                    .fill(chipColor(source).opacity(0.16))
                    .overlay {
                        Capsule().strokeBorder(chipColor(source).opacity(0.28), lineWidth: 0.6)
                    }
            }
    }

    private func chipLabel(_ source: UsageSource) -> String {
        switch source {
        case .empty: return "empty"
        case .loading: return "loading"
        case .live: return "live"
        case .demo: return "demo"
        case .error: return "error"
        }
    }

    private func chipColor(_ source: UsageSource) -> Color {
        switch source {
        case .empty: return Theme.textMuted
        case .loading: return Theme.sky
        case .live: return Theme.liveDot
        case .demo: return Theme.lavender
        case .error: return Theme.peach
        }
    }

    private func barWidth(in total: CGFloat, reading: UsageReading) -> CGFloat {
        if reading.source == .empty { return 0 }
        return max(7, total * UsageReading.clampFraction(reading.fraction))
    }
}
