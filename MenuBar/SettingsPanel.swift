import AppKit
import SwiftUI

struct SettingsPanel: View {
    @ObservedObject var model: AppModel

    var body: some View {
        GlassPanelChrome(width: Theme.settingsPanelWidth) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("super spade")
                        .font(.system(size: Theme.headerSize, weight: .semibold, design: .default))
                        .tracking(0.5)
                        .foregroundStyle(Theme.islandText)
                    Text("Super Spade 1.0")
                        .font(.system(size: 11, weight: .regular, design: .default))
                        .foregroundStyle(Theme.islandMuted)
                }

                Toggle("Hide other icons", isOn: hideOtherIconsBinding)
                    .toggleStyle(SuperSpadePillToggle())

                Text("⌘-drag extras left of the hide tick first. This uses overflow hide — a public spacer, not a private grab.")
                    .font(.system(size: 11, weight: .regular, design: .default))
                    .foregroundStyle(Theme.islandMuted)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 8) {
                    Text("On the bar")
                        .font(.system(size: Theme.rowSize, weight: .medium, design: .default))
                        .foregroundStyle(Theme.islandMuted)
                    ForEach(BarWidget.allCases) { widget in
                        Toggle(widget.title, isOn: visibilityBinding(widget))
                            .toggleStyle(SuperSpadePillToggle())
                    }
                }

                Button("Open Control Center settings") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.ControlCenter-Settings.extension") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(GlassActionButtonStyle())

                HStack {
                    Spacer()
                    Button("Quit") { NSApplication.shared.terminate(nil) }
                        .buttonStyle(.plain)
                        .font(.system(size: Theme.rowSize, weight: .regular, design: .default))
                        .foregroundStyle(Theme.islandMuted)
                }
            }
        }
    }

    private var hideOtherIconsBinding: Binding<Bool> {
        Binding(
            get: { model.hideOtherIcons },
            set: { model.setHideOtherIcons($0) }
        )
    }

    private func visibilityBinding(_ widget: BarWidget) -> Binding<Bool> {
        Binding(
            get: { model.isVisible(widget) },
            set: { model.setVisible(widget, $0) }
        )
    }
}
