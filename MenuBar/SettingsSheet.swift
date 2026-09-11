import AppKit
import SwiftUI

struct SettingsSheet: View {
    @ObservedObject var model: AppModel

    var body: some View {
        ScrollView {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(Theme.settingsHeader)
                    .font(.system(size: Theme.headerSize, weight: .semibold, design: .default))
                    .tracking(0.5)
                    .foregroundStyle(Theme.text)
                Text(Theme.aboutLine)
                    .font(.system(size: 11, weight: .regular, design: .default))
                    .foregroundStyle(Theme.textMuted)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Accessibility")
                    .font(.system(size: Theme.rowSize, weight: .medium, design: .default))
                    .foregroundStyle(Theme.textMuted)
                Text(model.accessibilityTrusted ? "Granted — import strip is live." : "Missing — prompt, then System Settings.")
                    .font(.system(size: 11, weight: .regular, design: .default))
                    .foregroundStyle(Theme.text)
                if !model.accessibilityTrusted {
                    HStack(spacing: 8) {
                        Button("Allow") { model.requestAccessibility() }
                            .buttonStyle(GlassPillButtonStyle())
                        Button("System Settings") { model.openSystemSettings() }
                            .buttonStyle(GlassPillButtonStyle())
                    }
                    HStack(spacing: 8) {
                        Button("Recheck") { model.refreshPermissionsAndExtras() }
                            .buttonStyle(GlassPillButtonStyle())
                        if model.permissionPrompted {
                            Button("Quit Super Spade") { NSApplication.shared.terminate(nil) }
                                .buttonStyle(GlassPillButtonStyle())
                        }
                    }
                    if model.permissionPrompted {
                        Text("If the strip does not flip after grant, quit and reopen Super Spade. macOS sometimes applies Accessibility only on the next launch.")
                            .font(.system(size: 10, weight: .regular, design: .default))
                            .foregroundStyle(Theme.textMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Menu bar chips")
                    .font(.system(size: Theme.rowSize, weight: .medium, design: .default))
                    .foregroundStyle(Theme.textMuted)
                Text("Pin widgets as Apple-thin chips. The ♠ still opens the bubble.")
                    .font(.system(size: 11, weight: .regular, design: .default))
                    .foregroundStyle(Theme.text)
                    .fixedSize(horizontal: false, vertical: true)
                ForEach(PinnableWidget.allCases) { widget in
                    HStack {
                        Text(widget.title)
                            .font(.system(size: 11, weight: .medium, design: .default))
                            .foregroundStyle(Theme.text)
                        Spacer()
                        PinAffordance(widget: widget, model: model)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Hide extras")
                    .font(.system(size: Theme.rowSize, weight: .medium, design: .default))
                    .foregroundStyle(Theme.textMuted)
                Text(model.collapseExtras
                     ? "Public spacer is collapsing extras left of Super Spade. That is not a per-icon steal."
                     : "Off. Import tries AXHidden first; if that fails, this spacer turns on.")
                    .font(.system(size: 11, weight: .regular, design: .default))
                    .foregroundStyle(Theme.text)
                    .fixedSize(horizontal: false, vertical: true)
                Button(model.collapseExtras ? "Restore extras" : "Collapse extras left of Super Spade") {
                    model.setCollapseExtras(!model.collapseExtras)
                }
                .buttonStyle(GlassPillButtonStyle())
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Usage")
                    .font(.system(size: Theme.rowSize, weight: .medium, design: .default))
                    .foregroundStyle(Theme.textMuted)
                Text("Keys stay in the process environment or ~/.config/super-spade/usage.env. Super Spade does not store secrets. See docs/USAGE-METER.md.")
                    .font(.system(size: 11, weight: .regular, design: .default))
                    .foregroundStyle(Theme.text)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack {
                Button("Back") { model.showingSettings = false }
                    .buttonStyle(GlassPillButtonStyle())
                Spacer()
                Button("Quit") { NSApplication.shared.terminate(nil) }
                    .buttonStyle(.plain)
                    .font(.system(size: Theme.rowSize, weight: .regular, design: .default))
                    .foregroundStyle(Theme.textMuted)
            }
        }
        }
    }
}
