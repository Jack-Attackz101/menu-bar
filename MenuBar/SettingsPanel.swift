import AppKit
import SwiftUI

struct SettingsPanel: View {
    @ObservedObject var model: AppModel

    var body: some View {
        GlassPanelChrome(width: Theme.settingsPanelWidth) {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("super spade")
                        .font(.system(size: 15, weight: .semibold, design: .default))
                        .tracking(0.6)
                        .foregroundStyle(Theme.islandText)
                    Text("Super Spade 1.0")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(Theme.islandMuted)
                }

                Button("Open Control Center settings") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.ControlCenter-Settings.extension") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(GlassActionButtonStyle())

                Button("Refresh extra list") {
                    model.refreshExtras()
                }
                .buttonStyle(.plain)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.islandMuted)

                HStack {
                    Spacer()
                    Button("Quit") { NSApplication.shared.terminate(nil) }
                        .buttonStyle(.plain)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.islandMuted)
                }
            }
        }
    }
}
