import Combine
import Foundation

enum BarWidget: String, CaseIterable, Identifiable {
    case weather
    case quota
    case cpu
    case calendar
    case keepAwake

    var id: String { rawValue }

    var title: String {
        switch self {
        case .weather: return "Weather"
        case .quota: return "Quota"
        case .cpu: return "CPU"
        case .calendar: return "Calendar"
        case .keepAwake: return "Keep awake"
        }
    }
}

/// Shared UI state for bar visibility, overflow collapse, and the cream panels.
final class AppModel: ObservableObject {
    static let shared = AppModel()

    @Published var visibleWidgets: Set<BarWidget>
    @Published var overflowExpanded: Bool
    @Published var overflowPanelOpen = false
    @Published var settingsPanelOpen = false
    @Published var accessibilityTrusted = false
    @Published var otherExtras: [ExternalMenuExtra] = []

    private let visibleKey = "visibleWidgets"
    private let expandedKey = "overflowExpanded"

    private init() {
        if let stored = UserDefaults.standard.array(forKey: visibleKey) as? [String] {
            visibleWidgets = Set(stored.compactMap(BarWidget.init(rawValue:)))
            if visibleWidgets.isEmpty {
                visibleWidgets = Set(BarWidget.allCases)
            }
        } else {
            visibleWidgets = Set(BarWidget.allCases)
        }
        overflowExpanded = UserDefaults.standard.object(forKey: expandedKey) as? Bool ?? true
        accessibilityTrusted = MenuBarEnumerator.isTrusted()
    }

    func isVisible(_ widget: BarWidget) -> Bool {
        visibleWidgets.contains(widget)
    }

    func setVisible(_ widget: BarWidget, _ on: Bool) {
        if on {
            visibleWidgets.insert(widget)
        } else {
            visibleWidgets.remove(widget)
        }
        UserDefaults.standard.set(visibleWidgets.map(\.rawValue), forKey: visibleKey)
    }

    func toggleOverflowExpanded() {
        overflowExpanded.toggle()
        UserDefaults.standard.set(overflowExpanded, forKey: expandedKey)
        if overflowExpanded {
            overflowPanelOpen = true
            refreshExtras()
        } else {
            overflowPanelOpen = false
            settingsPanelOpen = false
        }
    }

    func openSettings() {
        settingsPanelOpen = true
        overflowPanelOpen = false
    }

    func refreshExtras() {
        accessibilityTrusted = MenuBarEnumerator.isTrusted()
        otherExtras = MenuBarEnumerator.listExtras()
    }
}
