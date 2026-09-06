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
                Text("Claude and Codex meters read optional `ANTHROPIC_API_KEY` / `OPENAI_API_KEY` from the process environment. Personal keys do not unlock org usage APIs, so the dual meter stays a labeled stub. Super Spade does not store secrets.")
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
