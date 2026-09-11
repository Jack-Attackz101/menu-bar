import Foundation

enum PinnableWidget: String, CaseIterable, Codable, Identifiable, Sendable {
    case keepAwake
    case flipClock
    case usage
    case weather

    var id: String { rawValue }

    var title: String {
        switch self {
        case .keepAwake: return "Keep awake"
        case .flipClock: return "Flip clock"
        case .usage: return "Claude / Codex"
        case .weather: return "Weather"
        }
    }
}

/// Pins Super Spade widgets onto the menu bar as thin chips. Not a default chip row.
struct PinStore: Sendable {
    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, key: String = "superSpade.pinnedWidgets") {
        self.defaults = defaults
        self.key = key
    }

    func load() -> Set<PinnableWidget> {
        let raw = defaults.stringArray(forKey: key) ?? []
        return Set(raw.compactMap(PinnableWidget.init(rawValue:)))
    }

    @discardableResult
    func set(_ widget: PinnableWidget, pinned: Bool) -> Set<PinnableWidget> {
        var items = load()
        if pinned {
            items.insert(widget)
        } else {
            items.remove(widget)
        }
        defaults.set(items.map(\.rawValue).sorted(), forKey: key)
        return items
    }
}
