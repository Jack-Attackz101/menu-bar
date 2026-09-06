import Foundation

/// A discovered or imported menu extra. Identity is title + app, not a live AX handle.
struct DiscoveredExtra: Identifiable, Hashable, Codable, Sendable {
    var id: String
    var title: String
    var appName: String

    init(id: String, title: String, appName: String) {
        self.id = id
        self.title = title
        self.appName = appName
    }

    var bookmarkLabel: String {
        title == appName ? title : "\(appName)"
    }
}

/// Persists click-imported extras. Does not hide, move, or embed other apps' status items.
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
        if items.contains(where: { $0.id == extra.id }) {
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
