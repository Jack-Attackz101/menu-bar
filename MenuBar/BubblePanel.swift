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
                    mainStack
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
                .accessibilityLabel("Settings")
                .offset(x: 2, y: -2)
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
        VStack(alignment: .leading, spacing: 12) {
            ImportStrip(model: model)

            GlassCard {
                FlipClockView()
            }

            GlassCard {
                DualUsageMeter(claude: model.claude, codex: model.codex)
            }

            HStack(spacing: 8) {
                KeepAwakeWidget(keepAwake: keepAwake)
                WeatherStub()
                    .frame(width: 118)
            }

            Spacer(minLength: 0)
        }
        .padding(.trailing, 28)
    }
}
