import Combine
import Foundation

/// Shared bubble state. Init assigns stored properties from locals (main-actor safe).
@MainActor
final class AppModel: ObservableObject {
    static let shared = AppModel()

    @Published var imported: [DiscoveredExtra]
    @Published var discovered: [DiscoveredExtra]
    @Published var accessibilityTrusted: Bool
    @Published var showingSettings: Bool
    @Published var claude: UsageReading
    @Published var codex: UsageReading
    @Published var permissionPrompted: Bool
    @Published var pinned: Set<PinnableWidget>
    @Published var collapseExtras: Bool

    private let store: ImportStore
    private let pins: PinStore
    private let collapseKey: String
    private let defaults: UserDefaults
    private var usageTask: Task<Void, Never>?

    private init() {
        let store = ImportStore()
        let pins = PinStore()
        let defaults = UserDefaults.standard
        let collapseKey = "superSpade.collapseExtrasLeft"
        let imported = store.load()
        let pinned = pins.load()
        let trusted = MenuBarEnumerator.isTrusted()
        let usage = UsageStore.placeholderReadings()
        let collapse = defaults.bool(forKey: collapseKey)

        self.store = store
        self.pins = pins
        self.defaults = defaults
        self.collapseKey = collapseKey
        self.imported = imported
        self.discovered = []
        self.accessibilityTrusted = trusted
        self.showingSettings = false
        self.claude = usage.claude
        self.codex = usage.codex
        self.permissionPrompted = false
        self.pinned = pinned
        self.collapseExtras = collapse
    }

    func refreshPermissionsAndExtras() {
        let trusted = MenuBarEnumerator.isTrusted()
        accessibilityTrusted = trusted
        if trusted {
            discovered = MenuBarEnumerator.listExtras()
        } else {
            discovered = []
        }
    }

    func requestAccessibility() {
        permissionPrompted = true
        MenuBarEnumerator.requestTrust()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.refreshPermissionsAndExtras()
        }
    }

    func openSystemSettings() {
        permissionPrompted = true
        MenuBarEnumerator.openAccessibilitySettings()
    }

    func importExtra(_ extra: DiscoveredExtra) {
        var item = extra
        if let icon = MenuBarEnumerator.captureIcon(matching: extra) {
            item.iconPNG = icon.data
            item.iconSource = icon.source
        }
        if MenuBarEnumerator.attemptHide(matching: extra, hidden: true) {
            item.hideOutcome = .axHidden
        } else {
            setCollapseExtras(true)
            item.hideOutcome = .spacerCollapsed
        }
        imported = store.importExtra(item)
        refreshPermissionsAndExtras()
    }

    func removeImported(id: String) {
        if let extra = imported.first(where: { $0.id == id }) {
            _ = MenuBarEnumerator.attemptHide(matching: extra, hidden: false)
        }
        imported = store.remove(id: id)
        if imported.isEmpty {
            setCollapseExtras(false)
        }
    }

    func isImported(_ extra: DiscoveredExtra) -> Bool {
        imported.contains { $0.id == extra.id }
    }

    func activateImported(_ extra: DiscoveredExtra) {
        _ = MenuBarEnumerator.pressExtra(matching: extra)
    }

    func isPinned(_ widget: PinnableWidget) -> Bool {
        pinned.contains(widget)
    }

    func setPinned(_ widget: PinnableWidget, _ on: Bool) {
        pinned = pins.set(widget, pinned: on)
    }

    func setCollapseExtras(_ on: Bool) {
        collapseExtras = on
        defaults.set(on, forKey: collapseKey)
    }

    func refreshUsage() {
        claude = UsageStore.loading(from: claude)
        codex = UsageStore.loading(from: codex)
        usageTask?.cancel()
        usageTask = Task.detached { [weak self] in
            let pair = await UsageService.refresh()
            await MainActor.run {
                self?.claude = pair.claude
                self?.codex = pair.codex
            }
        }
    }
}
