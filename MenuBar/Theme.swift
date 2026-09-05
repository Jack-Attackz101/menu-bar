import AppKit
import SwiftUI

/// Super Spade 1.0 tokens — source: `docs/SUPER-SPADE-1.0-TOKENS.md`.
enum Theme {
    static let chipFill = Color.white.opacity(0.16)
    static let chipBorder = Color.white.opacity(0.29)
    static let chipHeight: CGFloat = 24
    static let chipBlur: CGFloat = 13

    static let weatherTint = Color(red: 125 / 255, green: 211 / 255, blue: 252 / 255).opacity(0.32)
    static let keepAwakeTint = Color(red: 251 / 255, green: 146 / 255, blue: 60 / 255).opacity(0.42)
    static let liveDot = Color(red: 74 / 255, green: 222 / 255, blue: 128 / 255)

    static let islandFill = Color(red: 20 / 255, green: 16 / 255, blue: 30 / 255).opacity(0.72)
    static let islandBlur: CGFloat = 28
    static let islandBottomRadius: CGFloat = 22
    static let islandShoulder: CGFloat = 18
    static let islandJoinWidth: CGFloat = 56

    static let panelRadius: CGFloat = 22
    static let headerSize: CGFloat = 14
    static let rowSize: CGFloat = 12
    static let toggleWidth: CGFloat = 34
    static let toggleHeight: CGFloat = 18

    static let text = Color.white.opacity(0.92)
    static let textMuted = Color.white.opacity(0.55)
    static let islandText = Color.white.opacity(0.92)
    static let islandMuted = Color.white.opacity(0.55)

    static let overflowPanelWidth: CGFloat = 268
    static let settingsPanelWidth: CGFloat = 248
    static let islandWidth: CGFloat = 228
}

/// Compact on-bar chip: white glass fill, 0.29 stroke, pill, ~13pt frost.
struct CompactGlass: View {
    var tint: Color? = nil
    var height: CGFloat = Theme.chipHeight

    var body: some View {
        Capsule()
            .fill(.ultraThinMaterial)
            .overlay {
                Capsule().fill(Theme.chipFill)
            }
            .overlay {
                if let tint {
                    Capsule().fill(tint)
                }
            }
            .overlay {
                Capsule()
                    .strokeBorder(Theme.chipBorder, lineWidth: 0.8)
            }
            .frame(height: height)
    }
}

/// Dark frost used by hover islands and settings. macOS 14 — material, not containerBackground.
struct DarkFrost<S: Shape>: View {
    var shape: S
    var material: Material = .thinMaterial

    var body: some View {
        shape
            .fill(material)
            .overlay {
                shape.fill(Theme.islandFill)
            }
            .overlay {
                shape.stroke(Color.white.opacity(0.14), lineWidth: 0.7)
            }
    }
}

/// Island silhouette: soft shoulders into the bar, 22pt bottom, no triangle.
struct SoftJoinIslandShape: Shape {
    var joinWidth: CGFloat = Theme.islandJoinWidth
    var shoulder: CGFloat = Theme.islandShoulder
    var bottomRadius: CGFloat = Theme.islandBottomRadius

    func path(in rect: CGRect) -> Path {
        let mid = rect.midX
        let joinHalf = min(joinWidth, rect.width) / 2
        let leftJoin = mid - joinHalf
        let rightJoin = mid + joinHalf
        let r = min(bottomRadius, rect.width / 2, rect.height / 2)
        let drop = min(shoulder + 8, rect.height * 0.35)

        var p = Path()
        p.move(to: CGPoint(x: leftJoin, y: rect.minY))
        p.addLine(to: CGPoint(x: rightJoin, y: rect.minY))
        p.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + drop),
            control1: CGPoint(x: rightJoin + 10, y: rect.minY),
            control2: CGPoint(x: rect.maxX, y: rect.minY + 3)
        )
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
        p.addQuadCurve(
            to: CGPoint(x: rect.maxX - r, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        p.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
        p.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - r),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + drop))
        p.addCurve(
            to: CGPoint(x: leftJoin, y: rect.minY),
            control1: CGPoint(x: rect.minX, y: rect.minY + 3),
            control2: CGPoint(x: leftJoin - 10, y: rect.minY)
        )
        p.closeSubpath()
        return p
    }
}

struct SuperSpadePillToggle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 10) {
            configuration.label
                .font(.system(size: Theme.rowSize, weight: .regular, design: .default))
                .foregroundStyle(Theme.islandText)
            Spacer(minLength: 8)
            ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                Capsule()
                    .fill(configuration.isOn ? Color.white.opacity(0.34) : Color.white.opacity(0.12))
                    .overlay {
                        Capsule().strokeBorder(Theme.chipBorder, lineWidth: 0.7)
                    }
                Circle()
                    .fill(Color.white.opacity(0.92))
                    .padding(2)
            }
            .frame(width: Theme.toggleWidth, height: Theme.toggleHeight)
            .contentShape(Capsule())
            .onTapGesture {
                configuration.isOn.toggle()
            }
            .accessibilityAddTraits(.isButton)
        }
    }
}
