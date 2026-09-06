import SwiftUI

/// Dual Claude + Codex usage meter. Not a CPU graph.
struct DualUsageMeter: View {
    var claude: UsageReading
    var codex: UsageReading

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            meter(claude, tint: Theme.lavender)
            meter(codex, tint: Theme.teal)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Claude and Codex usage")
    }

    private func meter(_ reading: UsageReading, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(reading.label)
                    .font(.system(size: 12, weight: .semibold, design: .default))
                    .foregroundStyle(Theme.text)
                Spacer()
                Text(reading.caption)
                    .font(.system(size: 10, weight: .regular, design: .default))
                    .foregroundStyle(Theme.textMuted)
                    .lineLimit(1)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.10))
                    Capsule()
                        .fill(tint.opacity(0.85))
                        .frame(width: max(6, geo.size.width * reading.fraction))
                }
            }
            .frame(height: 8)
        }
    }
}
