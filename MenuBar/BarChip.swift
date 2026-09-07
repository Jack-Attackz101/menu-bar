import AppKit
import SwiftUI

/// Locked Sol thin-chip stamp. Drop fill/border/height here — hosts stay Apple-thin, not chunky pills.
enum ThinChipTokens {
    static let height: CGFloat = 22
    static let paddingX: CGFloat = 5
    static let spacing: CGFloat = 3
    static let icon: CGFloat = 11
    static let font: CGFloat = 11
    static let stroke: CGFloat = 0.55
    static let fill = Color.white.opacity(0.10)
    static let border = Color.white.opacity(0.30)
}

struct CompactThinGlass: View {
    var tint: Color?

    var body: some View {
        Capsule()
            .fill(.ultraThinMaterial)
            .overlay {
                Capsule().fill(tint ?? ThinChipTokens.fill)
            }
            .overlay {
                Capsule().strokeBorder(ThinChipTokens.border, lineWidth: ThinChipTokens.stroke)
            }
    }
}

struct ThinBarChip<Content: View>: View {
    var tint: Color? = nil
    var live: Bool = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        HStack(spacing: ThinChipTokens.spacing) {
            content()
            if live {
                Circle()
                    .fill(Theme.liveDot)
                    .frame(width: 5, height: 5)
            }
        }
        .foregroundStyle(Theme.text)
        .padding(.horizontal, ThinChipTokens.paddingX)
        .frame(height: ThinChipTokens.height)
        .background {
            CompactThinGlass(tint: tint)
        }
    }
}

enum ThinChipArtwork {
    static func keepAwake(on: Bool) -> some View {
        ThinBarChip(tint: Theme.keepAwakeTint, live: on) {
            Image(systemName: on ? "bolt.fill" : "bolt")
                .font(.system(size: ThinChipTokens.icon, weight: .semibold))
            Text(on ? "On" : "Off")
                .font(.system(size: ThinChipTokens.font, weight: .medium, design: .default))
        }
    }

    static func flipClock(label: String) -> some View {
        ThinBarChip {
            Text(label)
                .font(.system(size: ThinChipTokens.font, weight: .medium, design: .rounded))
                .monospacedDigit()
        }
    }

    static func usage(claude: String, codex: String) -> some View {
        ThinBarChip {
            Text("C \(claude)")
                .font(.system(size: ThinChipTokens.font, weight: .medium, design: .default))
                .monospacedDigit()
            Text("X \(codex)")
                .font(.system(size: ThinChipTokens.font, weight: .medium, design: .default))
                .monospacedDigit()
        }
    }

    static func weather(label: String) -> some View {
        ThinBarChip(tint: Theme.weatherTint) {
            Image(systemName: "sun.max")
                .font(.system(size: ThinChipTokens.icon, weight: .semibold))
            Text(label)
                .font(.system(size: ThinChipTokens.font, weight: .medium, design: .default))
        }
    }
}

enum ChipRenderer {
    @MainActor
    static func image<V: View>(for view: V) -> NSImage {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        let image = renderer.nsImage ?? NSImage(size: NSSize(width: 44, height: ThinChipTokens.height))
        image.isTemplate = false
        return image
    }
}

struct ExtraGlyph: View {
    var extra: DiscoveredExtra
    var size: CGFloat = 14

    var body: some View {
        Group {
            if let data = extra.iconPNG, let image = NSImage(data: data) {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.high)
                    .aspectRatio(contentMode: .fit)
            } else {
                ThinSpade()
                    .fill(Theme.text.opacity(0.86))
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel(extra.iconSource.label)
    }
}

struct PinAffordance: View {
    var widget: PinnableWidget
    @ObservedObject var model: AppModel

    var body: some View {
        Button {
            model.setPinned(widget, !model.isPinned(widget))
        } label: {
            Text(model.isPinned(widget) ? "Unpin" : "Pin")
                .font(.system(size: 9, weight: .semibold, design: .default))
                .foregroundStyle(Theme.text)
                .padding(.horizontal, 6)
                .frame(height: 16)
                .background {
                    CompactThinGlass()
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(model.isPinned(widget) ? "Unpin \(widget.title)" : "Pin \(widget.title) to menu bar")
    }
}
