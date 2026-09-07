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
        VStack(alignment: .leading, spacing: 8) {
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
        VStack(spacing: 8) {
            ThinSpade()
                .fill(Theme.text.opacity(0.28))
                .frame(width: 16, height: 16)
            Text(ImportStripLogic.headline(.grantedEmpty))
                .font(.system(size: 12, weight: .semibold, design: .default))
                .foregroundStyle(Theme.text)
            Text(ImportStripLogic.body(.grantedEmpty))
                .font(.system(size: 10, weight: .regular, design: .default))
                .foregroundStyle(Theme.textMuted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }

    private func workingStrip(showAvailable: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if !model.imported.isEmpty {
                scrollRow(items: model.imported, imported: true)
            }
            Text(ImportStripLogic.body(stripState))
                .font(.system(size: 10, weight: .regular, design: .default))
                .foregroundStyle(Theme.textMuted)
                .fixedSize(horizontal: false, vertical: true)
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
                            ThinSpade()
                                .fill(Theme.text.opacity(0.86))
                                .frame(width: 8, height: 8)
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
                    .accessibilityLabel(imported ? "Imported \(extra.appName) \(extra.title)" : "Import \(extra.appName) \(extra.title)")
                }
            }
        }
    }
}

struct ImportWell<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(12)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Theme.glassDeep.opacity(0.35))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Theme.glassBorder.opacity(0.9), style: StrokeStyle(lineWidth: 0.8, dash: [4, 3]))
                    }
            }
    }
}

struct PermissionGate: View {
    @ObservedObject var model: AppModel
    var state: ImportStripState

    var body: some View {
        ImportWell {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    ThinSpade()
                        .fill(Theme.text.opacity(0.34))
                        .frame(width: 14, height: 14)
                    Text(ImportStripLogic.headline(state))
                        .font(.system(size: 12, weight: .semibold, design: .default))
                        .foregroundStyle(Theme.text)
                }

                Text(ImportStripLogic.body(state))
                    .font(.system(size: 11, weight: .regular, design: .default))
                    .foregroundStyle(Theme.textMuted)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 6) {
                    Text("1. Allow the system prompt")
                        .font(.system(size: 10, weight: .medium, design: .default))
                        .foregroundStyle(Theme.text)
                    Text("2. Confirm Super Spade in System Settings → Privacy & Security → Accessibility")
                        .font(.system(size: 10, weight: .medium, design: .default))
                        .foregroundStyle(Theme.text)
                    Text("3. Return here. If TCC lags, quit and reopen.")
                        .font(.system(size: 10, weight: .medium, design: .default))
                        .foregroundStyle(Theme.text)
                }

                HStack(spacing: 8) {
                    Button("Allow Accessibility") {
                        model.requestAccessibility()
                    }
                    .buttonStyle(GlassPillButtonStyle())

                    Button("Open System Settings") {
                        model.openSystemSettings()
                    }
                    .buttonStyle(GlassPillButtonStyle())
                }

                HStack(spacing: 8) {
                    Button("Recheck") {
                        model.refreshPermissionsAndExtras()
                    }
                    .buttonStyle(GlassPillButtonStyle())

                    if state == .deniedWaiting {
                        Button("Quit Super Spade") {
                            NSApplication.shared.terminate(nil)
                        }
                        .buttonStyle(GlassPillButtonStyle())
                    }
                }
            }
        }
    }
}

struct GlassPillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11, weight: .semibold, design: .default))
            .foregroundStyle(Theme.text)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay { Capsule().fill(Theme.glassFill) }
                    .overlay { Capsule().strokeBorder(Theme.glassBorder, lineWidth: 0.7) }
            }
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}
