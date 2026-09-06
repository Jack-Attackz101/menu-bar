import AppKit
import SwiftUI

struct SettingsSheet: View {
    @ObservedObject var model: AppModel
    @State private var claudeKey = UserDefaults.standard.string(forKey: UsageStore.claudeDefaultsKey) ?? ""
    @State private var codexKey = UserDefaults.standard.string(forKey: UsageStore.codexDefaultsKey) ?? ""

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
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Usage keys (optional)")
                    .font(.system(size: Theme.rowSize, weight: .medium, design: .default))
                    .foregroundStyle(Theme.textMuted)
                keyField("Claude", text: $claudeKey) {
                    model.setClaudeKey(claudeKey)
                }
                keyField("Codex", text: $codexKey) {
                    model.setCodexKey(codexKey)
                }
                Text("Personal keys do not unlock org usage dashboards. The dual meter stays a labeled stub unless a live admin API is added later.")
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

    private func keyField(_ label: String, text: Binding<String>, save: @escaping () -> Void) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .default))
                .foregroundStyle(Theme.text)
                .frame(width: 52, alignment: .leading)
            SecureField("optional", text: text)
                .textFieldStyle(.plain)
                .font(.system(size: 11, weight: .regular, design: .monospaced))
                .foregroundStyle(Theme.text)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.white.opacity(0.10))
                }
                .onSubmit(save)
        }
    }
}
