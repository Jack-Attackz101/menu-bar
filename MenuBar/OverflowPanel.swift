import AppKit
import SwiftUI

struct OverflowPanel: View {
    @ObservedObject var model: AppModel

    var body: some View {
        CreamPanelChrome(width: Theme.overflowPanelWidth) {
            VStack(alignment: .leading, spacing: 12) {
                Text(model.overflowExpanded ? "Showing hidden extras" : "Hidden extras collapsed")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.ink)

                Text("⌘-drag other menu bar items to the left of the cream tick, then collapse. That uses a public status-item spacer — not private Window Server calls.")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.ink.opacity(0.72))
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 6) {
                    Text("On the bar")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Theme.ink.opacity(0.6))
                    ForEach(BarWidget.allCases) { widget in
                        Toggle(widget.title, isOn: visibilityBinding(widget))
                            .toggleStyle(CheckboxToggleStyle())
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Theme.ink)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Other extras")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Theme.ink.opacity(0.6))
                    if !model.accessibilityTrusted {
                        Text("Accessibility can list other extras. macOS still will not let this app hide them one-by-one without private APIs.")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.ink.opacity(0.72))
                            .fixedSize(horizontal: false, vertical: true)
                        Button("Request Accessibility") {
                            MenuBarEnumerator.requestTrust()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                model.refreshExtras()
                            }
                        }
                        .buttonStyle(CreamInkButtonStyle())
                    } else if model.otherExtras.isEmpty {
                        Text("No other extras found. Collapse still hides whatever you ⌘-dragged left of the tick.")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.ink.opacity(0.72))
                    } else {
                        ForEach(model.otherExtras.prefix(8)) { extra in
                            Text("\(extra.appName) — \(extra.title)")
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.ink)
                                .lineLimit(1)
                        }
                    }
                }

                HStack {
                    Button("Settings") { model.openSettings() }
                        .buttonStyle(CreamInkButtonStyle())
                    Spacer()
                    Button("Quit") { NSApplication.shared.terminate(nil) }
                        .buttonStyle(.plain)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.ink.opacity(0.7))
                }
            }
        }
    }

    private func visibilityBinding(_ widget: BarWidget) -> Binding<Bool> {
        Binding(
            get: { model.isVisible(widget) },
            set: { model.setVisible(widget, $0) }
        )
    }
}

struct CreamInkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Theme.cream)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Theme.ink, in: RoundedRectangle(cornerRadius: 8, style: .circular))
            .opacity(configuration.isPressed ? 0.86 : 1)
    }
}
