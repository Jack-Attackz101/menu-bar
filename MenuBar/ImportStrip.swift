import AppKit
import SwiftUI

/// Bookmarks-style strip: discover extras, click to import into Super Spade's bar.
struct ImportStrip: View {
    @ObservedObject var model: AppModel

    private var stripState: ImportStripState {
        ImportStripLogic.state(
            trusted: model.accessibilityTrusted,
            prompted: model.permissionPrompted,
            discovered: model.discovered,
            imported: model.imported
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Import")
                    .font(.system(size: Theme.rowSize, weight: .semibold, design: .default))
                    .foregroundStyle(Theme.text)
                Spacer()
                Text(ImportStripLogic.headline(stripState))
                    .font(.system(size: 10, weight: .medium, design: .default))
                    .foregroundStyle(Theme.textMuted)
            }

            switch stripState {
            case .denied, .deniedWaiting:
                PermissionGate(model: model, state: stripState)
            case .grantedEmpty:
                ImportWell {
                    emptyState
                }
            case .grantedAvailable:
                workingStrip(showAvailable: true)
            case .grantedAllBookmarked:
                workingStrip(showAvailable: false)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 4) {
            Text(ImportStripLogic.headline(.grantedEmpty))
                .font(.system(size: 11, weight: .semibold, design: .default))
                .foregroundStyle(Theme.text)
            Text(ImportStripLogic.body(.grantedEmpty))
                .font(.system(size: 10, weight: .regular, design: .default))
                .foregroundStyle(Theme.textMuted)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }

    private func workingStrip(showAvailable: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if !model.imported.isEmpty {
                scrollRow(items: model.imported, imported: true)
            }
            Text(ImportStripLogic.body(stripState))
                .font(.system(size: 10, weight: .regular, design: .default))
                .foregroundStyle(Theme.textMuted)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            if model.collapseExtras {
                Text("Extras left of Super Spade are collapsed with a public spacer — not a per-icon steal.")
                    .font(.system(size: 10, weight: .regular, design: .default))
                    .foregroundStyle(Theme.textMuted)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if showAvailable {
                let extras = ImportStripLogic.available(
                    discovered: model.discovered,
                    imported: model.imported
                )
                scrollRow(items: extras, imported: false)
            }
        }
    }

    private func scrollRow(items: [DiscoveredExtra], imported: Bool) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(items) { extra in
                    Button {
                        if imported {
                            model.activateImported(extra)
                        } else {
                            model.importExtra(extra)
                        }
                    } label: {
                        HStack(spacing: 5) {
                            ExtraGlyph(extra: extra, size: 12)
                            Text(extra.title)
                                .font(.system(size: 11, weight: .medium, design: .default))
                                .lineLimit(1)
                        }
                        .foregroundStyle(Theme.text)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 6)
                        .background {
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay {
                                    Capsule().fill(imported ? Theme.lavender.opacity(0.28) : Theme.glassFill)
                                }
                                .overlay {
                                    Capsule().strokeBorder(Theme.glassBorder, lineWidth: 0.7)
                                }
                        }
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        if imported {
                            Button("Remove from bar") {
                                model.removeImported(id: extra.id)
                            }
                        }
                    }
                    .help(imported ? ExtraHideCopy.caption(extra.hideOutcome) : extra.iconSource.label)
                    .accessibilityLabel(imported ? "Imported \(extra.appName) \(extra.title). \(ExtraHideCopy.caption(extra.hideOutcome))" : "Import \(extra.appName) \(extra.title)")
                }
            }
        }
    }
}

struct ImportWell<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(8)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Theme.glassDeep.opacity(0.35))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Theme.glassBorder.opacity(0.9), style: StrokeStyle(lineWidth: 0.7, dash: [4, 3]))
                    }
            }
    }
}

/// Compact denied card — must not consume the fixed bubble height.
struct PermissionGate: View {
    @ObservedObject var model: AppModel
    var state: ImportStripState

    var body: some View {
        ImportWell {
            VStack(alignment: .leading, spacing: 6) {
                Text(ImportStripLogic.compactPrompt(state))
                    .font(.system(size: 10, weight: .regular, design: .default))
                    .foregroundStyle(Theme.textMuted)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 6) {
                    Button("Allow") {
                        model.requestAccessibility()
                    }
                    .buttonStyle(GlassPillButtonStyle())

                    Button("Settings") {
                        model.openSystemSettings()
                    }
                    .buttonStyle(GlassPillButtonStyle())

                    Button("Recheck") {
                        model.refreshPermissionsAndExtras()
                    }
                    .buttonStyle(GlassPillButtonStyle())

                    if state == .deniedWaiting {
                        Button("Quit") {
                            NSApplication.shared.terminate(nil)
                        }
                        .buttonStyle(GlassPillButtonStyle())
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ImportStripLogic.headline(state))
        .accessibilityHint(ImportStripLogic.body(state))
    }
}

struct GlassPillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 10, weight: .semibold, design: .default))
            .foregroundStyle(Theme.text)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay { Capsule().fill(Theme.glassFill) }
                    .overlay { Capsule().strokeBorder(Theme.glassBorder, lineWidth: 0.7) }
            }
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}
