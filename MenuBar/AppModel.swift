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

    private let store: ImportStore

    private init() {
        let store = ImportStore()
        let imported = store.load()
        let trusted = MenuBarEnumerator.isTrusted()
        let usage = UsageStore.readingsFromEnvironment()

        self.store = store
        self.imported = imported
        self.discovered = []
        self.accessibilityTrusted = trusted
        self.showingSettings = false
        self.claude = usage.claude
        self.codex = usage.codex
        self.permissionPrompted = false
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
        imported = store.importExtra(extra)
    }

    func removeImported(id: String) {
        imported = store.remove(id: id)
    }

    func isImported(_ extra: DiscoveredExtra) -> Bool {
        imported.contains { $0.id == extra.id }
    }

    func activateImported(_ extra: DiscoveredExtra) {
        _ = MenuBarEnumerator.pressExtra(matching: extra)
    }

    func refreshUsage() {
        let usage = UsageStore.readingsFromEnvironment()
        claude = usage.claude
        codex = usage.codex
    }
}
