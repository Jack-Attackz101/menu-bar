import AppKit
import SwiftUI

struct SettingsSheet: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
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
                Text("Usage")
                    .font(.system(size: Theme.rowSize, weight: .medium, design: .default))
                    .foregroundStyle(Theme.textMuted)
                Text("Claude and Codex meters read optional keys from the process environment or ~/.config/super-spade/usage.env. Super Spade does not store secrets in the repo or UserDefaults. Personal keys usually cannot read org usage APIs — then the meter stays demo or shows an error you can retry. A local usage.json snapshot is treated as live.")
                    .font(.system(size: 11, weight: .regular, design: .default))
                    .foregroundStyle(Theme.text)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Finn/Jack: see docs/USAGE-METER.md. SUPER_SPADE_USAGE_EMPTY=1 forces the empty state. SUPER_SPADE_USAGE_DEMO=1 forces demo.")
                    .font(.system(size: 10, weight: .regular, design: .default))
                    .foregroundStyle(Theme.textMuted)
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
