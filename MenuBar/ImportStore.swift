import Foundation

/// A discovered or imported menu extra. Identity is title + app, not a live AX handle.
struct DiscoveredExtra: Identifiable, Hashable, Codable, Sendable {
    var id: String
    var title: String
    var appName: String
    var bundleId: String?
    var iconPNG: Data?
    var iconSource: ExtraIconSource
    var hideOutcome: ExtraHideOutcome

    init(
        id: String,
        title: String,
        appName: String,
        bundleId: String? = nil,
        iconPNG: Data? = nil,
        iconSource: ExtraIconSource = .none,
        hideOutcome: ExtraHideOutcome = .stillVisible
    ) {
        self.id = id
        self.title = title
        self.appName = appName
        self.bundleId = bundleId
        self.iconPNG = iconPNG
        self.iconSource = iconSource
        self.hideOutcome = hideOutcome
    }

    var bookmarkLabel: String {
        title == appName ? title : "\(appName)"
    }
}

/// Persists click-imported extras (icon PNG + honest hide outcome).
struct ImportStore: Sendable {
    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, key: String = "superSpade.importedExtras") {
        self.defaults = defaults
        self.key = key
    }

    func load() -> [DiscoveredExtra] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([DiscoveredExtra].self, from: data)) ?? []
    }

    @discardableResult
    func importExtra(_ extra: DiscoveredExtra) -> [DiscoveredExtra] {
        var items = load()
        if let index = items.firstIndex(where: { $0.id == extra.id }) {
            items[index] = extra
            save(items)
            return items
        }
        items.append(extra)
        save(items)
        return items
    }

    @discardableResult
    func remove(id: String) -> [DiscoveredExtra] {
        let items = load().filter { $0.id != id }
        save(items)
        return items
    }

    func contains(id: String) -> Bool {
        load().contains { $0.id == id }
    }

    private func save(_ items: [DiscoveredExtra]) {
        if let data = try? JSONEncoder().encode(items) {
            defaults.set(data, forKey: key)
        }
    }
}
