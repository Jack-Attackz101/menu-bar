import SwiftUI

/// Dark frost island that soft-joins the bar. Same pattern for weather, quota,
/// CPU, and calendar. Keep-awake stays a tap chip only.
struct HoverIsland<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content()
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
        .padding(.bottom, 14)
        .frame(width: Theme.islandWidth, alignment: .leading)
        .background {
            DarkFrost(shape: SoftJoinIslandShape(), material: .regularMaterial)
        }
    }
}

struct WeatherIsland: View {
    var body: some View {
        HoverIsland {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("72°")
                    .font(.system(size: 28, weight: .light, design: .default))
                    .foregroundStyle(Theme.islandText)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Clear")
                        .font(.system(size: Theme.rowSize + 1, weight: .medium, design: .default))
                        .foregroundStyle(Theme.islandText)
                    Text("Local · stub")
                        .font(.system(size: 11, weight: .regular, design: .default))
                        .foregroundStyle(Theme.islandMuted)
                }
                Spacer(minLength: 0)
                ThinIcons.Cloud()
                    .stroke(Theme.islandText.opacity(0.7), lineWidth: ThinIcons.line)
                    .frame(width: 22, height: 16)
            }
            Text("Live weather is not wired yet. This island is the hover pattern.")
                .font(.system(size: 11, weight: .regular, design: .default))
                .foregroundStyle(Theme.islandMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct QuotaIsland: View {
    var body: some View {
        HoverIsland {
            Text("Disk")
                .font(.system(size: 11, weight: .medium, design: .default))
                .foregroundStyle(Theme.islandMuted)
            Text("—")
                .font(.system(size: 26, weight: .light, design: .default))
                .foregroundStyle(Theme.islandText)
            Text("Free space will land here. The compact chip stays on the bar.")
                .font(.system(size: 11, weight: .regular, design: .default))
                .foregroundStyle(Theme.islandMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct CPUIsland: View {
    @ObservedObject var cpu: CPUMonitor

    var body: some View {
        HoverIsland {
            Text("Processor")
                .font(.system(size: 11, weight: .medium, design: .default))
                .foregroundStyle(Theme.islandMuted)
            Text(cpu.percent.map { "\($0)%" } ?? "—")
                .font(.system(size: 26, weight: .light, design: .default))
                .foregroundStyle(Theme.islandText)
                .monospacedDigit()
            Text("Live sample from this Mac. The bar chip shows the same figure.")
                .font(.system(size: 11, weight: .regular, design: .default))
                .foregroundStyle(Theme.islandMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct CalendarIsland: View {
    var body: some View {
        HoverIsland {
            Text("Today")
                .font(.system(size: 11, weight: .medium, design: .default))
                .foregroundStyle(Theme.islandMuted)
            Text("No events")
                .font(.system(size: 18, weight: .regular, design: .default))
                .foregroundStyle(Theme.islandText)
            Text("Calendar access is not connected yet.")
                .font(.system(size: 11, weight: .regular, design: .default))
                .foregroundStyle(Theme.islandMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
