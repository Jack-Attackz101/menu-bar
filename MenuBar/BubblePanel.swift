import AppKit
import SwiftUI

/// Click-opened aurora glass bubble. Not a hover tray. Not a chip row.
struct BubblePanel: View {
    @ObservedObject var model: AppModel
    @ObservedObject var keepAwake: KeepAwakeController

    var body: some View {
        GlassBubbleChrome {
            ZStack(alignment: .topTrailing) {
                if model.showingSettings {
                    SettingsSheet(model: model)
                } else {
                    ScrollView {
                        mainStack
                    }
                    .scrollIndicators(.hidden)
                }

                Button {
                    model.showingSettings.toggle()
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.text.opacity(0.86))
                        .padding(8)
                        .background {
                            Circle()
                                .fill(Color.white.opacity(0.12))
                                .overlay {
                                    Circle().strokeBorder(Theme.glassBorder, lineWidth: 0.6)
                                }
                        }
                }
                .buttonStyle(.plain)
                .fixedSize()
                .contentShape(Circle())
                .accessibilityLabel("Settings")
                .offset(x: 2, y: -2)
                .zIndex(1)
            }
        }
        .onAppear {
            model.refreshPermissionsAndExtras()
            model.refreshUsage()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            model.refreshPermissionsAndExtras()
        }
    }

    private var mainStack: some View {
        VStack(alignment: .leading, spacing: 10) {
            ImportStrip(model: model)

            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    pinHeader(.flipClock)
                    FlipClockView()
                }
            }

            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    pinHeader(.usage)
                    DualUsageMeter(
                        claude: model.claude,
                        codex: model.codex,
                        onRetry: { model.refreshUsage() }
                    )
                }
            }

            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 6) {
                    PinAffordance(widget: .keepAwake, model: model)
                    KeepAwakeWidget(keepAwake: keepAwake)
                }
                VStack(alignment: .leading, spacing: 6) {
                    PinAffordance(widget: .weather, model: model)
                    WeatherStub()
                        .frame(width: 118)
                }
            }

        }
        .padding(.trailing, 28)
        .padding(.bottom, 4)
    }

    private func pinHeader(_ widget: PinnableWidget) -> some View {
        HStack(spacing: 8) {
            Text(widget.title)
                .font(.system(size: 11, weight: .semibold, design: .default))
                .foregroundStyle(Theme.textMuted)
            Spacer(minLength: 8)
            PinAffordance(widget: widget, model: model)
        }
    }
}
