import Foundation

enum ImportStripState: String, Equatable, Sendable {
    case denied
    case deniedWaiting
    case grantedEmpty
    case grantedAvailable
    case grantedAllBookmarked
}

/// Pure import-strip states so Finn can unit-test empty / denied / granted copy.
enum ImportStripLogic {
    static func state(
        trusted: Bool,
        prompted: Bool,
        discovered: [DiscoveredExtra],
        imported: [DiscoveredExtra]
    ) -> ImportStripState {
        if !trusted {
            return prompted ? .deniedWaiting : .denied
        }
        if discovered.isEmpty {
            return .grantedEmpty
        }
        return available(discovered: discovered, imported: imported).isEmpty
            ? .grantedAllBookmarked
            : .grantedAvailable
    }

    static func available(
        discovered: [DiscoveredExtra],
        imported: [DiscoveredExtra]
    ) -> [DiscoveredExtra] {
        discovered.filter { extra in
            !imported.contains(where: { $0.id == extra.id })
        }
    }

    static func headline(_ state: ImportStripState) -> String {
        switch state {
        case .denied:
            return "Accessibility needed"
        case .deniedWaiting:
            return "Waiting for Accessibility"
        case .grantedEmpty:
            return "No extras listed"
        case .grantedAvailable:
            return "Click to bookmark"
        case .grantedAllBookmarked:
            return "Bookmarked"
        }
    }

    static func body(_ state: ImportStripState) -> String {
        switch state {
        case .denied:
            return "Grant Accessibility to list real menu extras. Super Spade can bookmark their icons. Per-item hide is attempted with AXHidden; otherwise a public spacer collapses extras left of Super Spade. It cannot steal or embed another app’s extra."
        case .deniedWaiting:
            return "Return here after you grant access. If the list does not appear, quit Super Spade and reopen — macOS sometimes applies Accessibility only on the next launch."
        case .grantedEmpty:
            return "No AX extras listed. Super Spade does not invent placeholders. Some apps never expose AXExtrasMenuBar."
        case .grantedAvailable:
            return "Click a real extra to capture its icon and bookmark it. Hide is AXHidden when it works, otherwise extras left of Super Spade collapse via a public spacer."
        case .grantedAllBookmarked:
            return "All listed extras are bookmarked. Click to open · right-click to restore."
        }
    }
}
