import AppKit
import SwiftUI

struct SettingsPanel: View {
    @ObservedObject var model: AppModel

    var body: some View {
        CreamPanelChrome(width: Theme.settingsPanelWidth) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Settings")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.ink)

                Text("Working label: Menu Bar. No product name.")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.ink.opacity(0.7))

                Button("Open Control Center settings") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.ControlCenter-Settings.extension") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(CreamInkButtonStyle())

                Button("Refresh extra list") {
                    model.refreshExtras()
                }
                .buttonStyle(.plain)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.ink.opacity(0.75))

                HStack {
                    Spacer()
                    Button("Quit") { NSApplication.shared.terminate(nil) }
                        .buttonStyle(.plain)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.ink.opacity(0.7))
                }
            }
        }
    }
}
