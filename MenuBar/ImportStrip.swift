import SwiftUI

/// Bookmarks-style strip: discover extras, click to import into Super Spade's bar.
struct ImportStrip: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Import")
                    .font(.system(size: Theme.rowSize, weight: .semibold, design: .default))
                    .foregroundStyle(Theme.text)
                Spacer()
                if model.accessibilityTrusted {
                    Text("click to add")
                        .font(.system(size: 10, weight: .regular, design: .default))
                        .foregroundStyle(Theme.textMuted)
                }
            }

            if !model.accessibilityTrusted {
                PermissionGate(model: model)
            } else {
                workingStrip
            }
        }
    }

    private var workingStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !model.imported.isEmpty {
                scrollRow(items: model.imported, imported: true)
            }
            let available = model.discovered.filter { extra in
                !model.imported.contains(where: { $0.id == extra.id })
            }
            if model.discovered.isEmpty {
                Text("No other extras found. Some apps do not expose AXExtrasMenuBar.")
                    .font(.system(size: 10, weight: .regular, design: .default))
                    .foregroundStyle(Theme.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            } else if available.isEmpty {
                Text("Every discovered extra is already in the bar. Right-click a chip to remove it.")
                    .font(.system(size: 10, weight: .regular, design: .default))
                    .foregroundStyle(Theme.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                scrollRow(items: available, imported: false)
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
                                .stroke(Theme.text.opacity(0.8), lineWidth: 1)
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

struct PermissionGate: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Accessibility is needed to list other menu bar extras. Super Spade still cannot hide or steal them.")
                .font(.system(size: 11, weight: .regular, design: .default))
                .foregroundStyle(Theme.textMuted)
                .fixedSize(horizontal: false, vertical: true)

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

            if model.permissionPrompted {
                Text("If listing does not appear after grant, quit and reopen Super Spade.")
                    .font(.system(size: 10, weight: .regular, design: .default))
                    .foregroundStyle(Theme.textMuted)
            }
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Theme.glassBorder, lineWidth: 0.7)
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
