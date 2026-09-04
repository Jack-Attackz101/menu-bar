import SwiftUI

/// Detail island that soft-joins the bar under a compact chip. Same pattern for
/// weather, quota, CPU, and calendar. Keep-awake stays a tap chip only.
struct HoverIsland<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content()
        }
        .padding(.horizontal, 14)
        .padding(.top, 14)
        .padding(.bottom, 12)
        .frame(width: Theme.islandWidth, alignment: .leading)
        .background {
            GlassBackdrop(corner: Theme.islandCorner, mesh: 0.40)
        }
        .overlay(alignment: .top) {
            Capsule()
                .fill(.white.opacity(0.34))
                .frame(width: 26, height: 5)
                .offset(y: -2)
        }
        .padding(.top, 5)
    }
}

struct WeatherIsland: View {
    var body: some View {
        HoverIsland {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("72°")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(Theme.islandText)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Clear")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.islandText)
                    Text("Local · stub")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(Theme.islandMuted)
                }
                Spacer(minLength: 0)
                ThinIcons.Cloud()
                    .stroke(Theme.islandText.opacity(0.7), lineWidth: ThinIcons.line)
                    .frame(width: 22, height: 16)
            }
            Text("Live weather is not wired yet. This island is the hover pattern.")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(Theme.islandMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct QuotaIsland: View {
    var body: some View {
        HoverIsland {
            Text("Disk")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Theme.islandMuted)
            Text("—")
                .font(.system(size: 26, weight: .light))
                .foregroundStyle(Theme.islandText)
            Text("Free space will land here. The compact chip stays on the bar.")
                .font(.system(size: 11, weight: .regular))
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
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Theme.islandMuted)
            Text(cpu.percent.map { "\($0)%" } ?? "—")
                .font(.system(size: 26, weight: .light))
                .foregroundStyle(Theme.islandText)
                .monospacedDigit()
            Text("Live sample from this Mac. The bar chip shows the same figure.")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(Theme.islandMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct CalendarIsland: View {
    var body: some View {
        HoverIsland {
            Text("Today")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Theme.islandMuted)
            Text("No events")
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(Theme.islandText)
            Text("Calendar access is not connected yet.")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(Theme.islandMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
