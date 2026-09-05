import AppKit
import SwiftUI

struct OverflowPanel: View {
    @ObservedObject var model: AppModel

    var body: some View {
        GlassPanelChrome(width: Theme.overflowPanelWidth) {
            VStack(alignment: .leading, spacing: 12) {
                Text(model.overflowExpanded ? "Showing hidden extras" : "Hidden extras collapsed")
                    .font(.system(size: Theme.rowSize + 1, weight: .semibold, design: .default))
                    .foregroundStyle(Theme.islandText)

                Text("⌘-drag extras left of the hide tick, then collapse. Overflow hide uses a public status-item spacer — it does not grab other extras by identity. Hide other icons lives in Settings.")
                    .font(.system(size: 11, weight: .regular, design: .default))
                    .foregroundStyle(Theme.islandMuted)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Other extras")
                        .font(.system(size: Theme.rowSize, weight: .medium, design: .default))
                        .foregroundStyle(Theme.islandMuted)
                    if !model.accessibilityTrusted {
                        Text("Accessibility can list other extras. macOS still will not let this app hide them one-by-one without private APIs.")
                            .font(.system(size: 11, weight: .regular, design: .default))
                            .foregroundStyle(Theme.islandMuted)
                            .fixedSize(horizontal: false, vertical: true)
                        Button("Request Accessibility") {
                            MenuBarEnumerator.requestTrust()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                model.refreshExtras()
                            }
                        }
                        .buttonStyle(GlassActionButtonStyle())
                    } else if model.otherExtras.isEmpty {
                        Text("No other extras found. Collapse still hides whatever you ⌘-dragged left of the tick.")
                            .font(.system(size: 11, weight: .regular, design: .default))
                            .foregroundStyle(Theme.islandMuted)
                    } else {
                        ForEach(model.otherExtras.prefix(8)) { extra in
                            Text("\(extra.appName) — \(extra.title)")
                                .font(.system(size: Theme.rowSize, weight: .regular, design: .default))
                                .foregroundStyle(Theme.islandText)
                                .lineLimit(1)
                        }
                    }
                }

                HStack {
                    Button("Settings") { model.openSettings() }
                        .buttonStyle(GlassActionButtonStyle())
                    Spacer()
                    Button("Quit") { NSApplication.shared.terminate(nil) }
                        .buttonStyle(.plain)
                        .font(.system(size: Theme.rowSize, weight: .regular, design: .default))
                        .foregroundStyle(Theme.islandMuted)
                }
            }
        }
    }
}
