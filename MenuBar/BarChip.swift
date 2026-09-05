import SwiftUI

struct GlassChip<Icon: View>: View {
    var label: String
    var tint: Color? = nil
    var live: Bool = false
    @ViewBuilder var icon: () -> Icon

    var body: some View {
        HStack(spacing: 5) {
            icon()
                .frame(width: 11, height: 11)
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .default))
                .monospacedDigit()
            if live {
                Circle()
                    .fill(Theme.liveDot)
                    .frame(width: 6, height: 6)
            }
        }
        .foregroundStyle(Theme.text)
        .padding(.horizontal, 9)
        .frame(height: Theme.chipHeight)
        .background {
            CompactGlass(tint: tint)
        }
    }
}

enum ChipArtwork {
    static func weather(label: String) -> some View {
        GlassChip(label: label, tint: Theme.weatherTint) {
            ThinIcons.Cloud().stroke(Theme.text, lineWidth: ThinIcons.line)
        }
    }

    static func quota(label: String) -> some View {
        GlassChip(label: label) {
            ThinIcons.Quota().stroke(Theme.text, lineWidth: ThinIcons.line)
        }
    }

    static func cpu(label: String) -> some View {
        GlassChip(label: label) {
            ThinIcons.CPU().stroke(Theme.text, lineWidth: ThinIcons.line)
        }
    }

    static func calendar(label: String) -> some View {
        GlassChip(label: label) {
            ThinIcons.Calendar().stroke(Theme.text, lineWidth: ThinIcons.line)
        }
    }

    static func keepAwake(on: Bool) -> some View {
        GlassChip(label: on ? "On" : "Off", tint: Theme.keepAwakeTint, live: on) {
            ThinIcons.Bolt().stroke(Theme.text, lineWidth: ThinIcons.line)
        }
    }

    static func overflow() -> some View {
        ThinIcons.Spade()
            .stroke(Theme.text, lineWidth: ThinIcons.line)
            .frame(width: 13, height: 13)
            .padding(.horizontal, 8)
            .frame(height: Theme.chipHeight)
            .background {
                CompactGlass()
            }
    }

    static func hideTick() -> some View {
        ThinIcons.Tick()
            .stroke(Theme.text.opacity(0.8), lineWidth: 1.1)
            .frame(width: 8, height: 14)
            .padding(.horizontal, 4)
            .frame(height: Theme.chipHeight)
            .background {
                CompactGlass()
            }
    }
}
