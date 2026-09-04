import SwiftUI

struct BarChip<Icon: View>: View {
    var fill: Color
    var label: String
    @ViewBuilder var icon: () -> Icon

    var body: some View {
        HStack(spacing: 4) {
            icon()
                .frame(width: 11, height: 11)
            Text(label)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .monospacedDigit()
        }
        .foregroundStyle(Theme.ink)
        .padding(.horizontal, 7)
        .padding(.vertical, 2)
        .background(fill, in: Capsule(style: .circular))
    }
}

enum ChipArtwork {
    static func weather(label: String) -> some View {
        BarChip(fill: Theme.weather, label: label) {
            HandmadeMarks.Cloud().fill(Theme.ink)
        }
    }

    static func quota(label: String) -> some View {
        BarChip(fill: Theme.cream, label: label) {
            HandmadeMarks.Quota().fill(Theme.ink)
        }
    }

    static func cpu(label: String) -> some View {
        BarChip(fill: Theme.cream, label: label) {
            HandmadeMarks.CPUBars().fill(Theme.ink)
        }
    }

    static func calendar(label: String) -> some View {
        BarChip(fill: Theme.cream, label: label) {
            HandmadeMarks.Calendar().fill(Theme.ink)
        }
    }

    static func keepAwake(on: Bool) -> some View {
        BarChip(fill: on ? Theme.keepAwake : Theme.cream, label: on ? "On" : "Off") {
            HandmadeMarks.Sun().fill(Theme.ink)
        }
    }

    static func overflow() -> some View {
        HandmadeMarks.HostDots()
            .fill(Theme.ink)
            .frame(width: 16, height: 12)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Theme.cream, in: Capsule(style: .circular))
    }

    static func hideTick() -> some View {
        HandmadeMarks.HideTick()
            .fill(Theme.cream)
            .frame(width: 8, height: 14)
    }
}
