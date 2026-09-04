import SwiftUI

struct GlassChip<Icon: View>: View {
    var label: String
    var mesh: Double = 0.42
    @ViewBuilder var icon: () -> Icon

    var body: some View {
        HStack(spacing: 5) {
            icon()
                .frame(width: 11, height: 11)
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .default))
                .monospacedDigit()
        }
        .foregroundStyle(Theme.text)
        .padding(.horizontal, 9)
        .padding(.vertical, 3)
        .background {
            GlassBackdrop(corner: Theme.chipCorner, mesh: mesh)
        }
    }
}

enum ChipArtwork {
    static func weather(label: String) -> some View {
        GlassChip(label: label, mesh: 0.50) {
            ThinIcons.Cloud().stroke(Theme.text, lineWidth: ThinIcons.line)
        }
    }

    static func quota(label: String) -> some View {
        GlassChip(label: label, mesh: 0.38) {
            ThinIcons.Quota().stroke(Theme.text, lineWidth: ThinIcons.line)
        }
    }

    static func cpu(label: String) -> some View {
        GlassChip(label: label, mesh: 0.40) {
            ThinIcons.CPU().stroke(Theme.text, lineWidth: ThinIcons.line)
        }
    }

    static func calendar(label: String) -> some View {
        GlassChip(label: label, mesh: 0.36) {
            ThinIcons.Calendar().stroke(Theme.text, lineWidth: ThinIcons.line)
        }
    }

    static func keepAwake(on: Bool) -> some View {
        GlassChip(label: on ? "On" : "Off", mesh: on ? 0.62 : 0.28) {
            ThinIcons.Bolt().stroke(Theme.text, lineWidth: ThinIcons.line)
        }
    }

    static func overflow() -> some View {
        ThinIcons.Spade()
            .stroke(Theme.text, lineWidth: ThinIcons.line)
            .frame(width: 13, height: 13)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background {
                GlassBackdrop(corner: Theme.chipCorner, mesh: 0.48)
            }
    }

    static func hideTick() -> some View {
        ThinIcons.Tick()
            .stroke(Theme.text.opacity(0.8), lineWidth: 1.1)
            .frame(width: 8, height: 14)
            .padding(.horizontal, 3)
            .background {
                GlassBackdrop(corner: 8, mesh: 0.30)
            }
    }
}
