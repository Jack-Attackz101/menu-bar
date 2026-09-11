import Foundation

enum ExtraIconSource: String, Codable, Equatable, Sendable {
    case axImage
    case axFrame
    case appIcon
    case none

    var label: String {
        switch self {
        case .axImage: return "AX icon"
        case .axFrame: return "AX frame"
        case .appIcon: return "app icon"
        case .none: return "no icon"
        }
    }
}

enum ExtraHideOutcome: String, Codable, Equatable, Sendable {
    case axHidden
    case spacerCollapsed
    case stillVisible
}

enum ExtraIdentity {
    static func isPlaceholderTitle(_ title: String) -> Bool {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let last = trimmed.split(separator: " ").last, last.allSatisfy(\.isNumber) else {
            return false
        }
        return trimmed.hasPrefix("Item ")
    }

    static func firstReal(_ values: String?...) -> String? {
        guard let matched = values.first(where: { candidate in
            guard let candidate else { return false }
            let trimmed = candidate.trimmingCharacters(in: .whitespacesAndNewlines)
            return !trimmed.isEmpty && !isPlaceholderTitle(trimmed)
        }), let value = matched else {
            return nil
        }
        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Real AX extras only. Untitled extras keep the app name. "Item N" is never shipped.
    static func resolvedTitle(
        axTitle: String?,
        axDescription: String?,
        axHelp: String?,
        appName: String
    ) -> String? {
        if let title = firstReal(axTitle, axDescription, axHelp) {
            return title
        }
        let app = appName.trimmingCharacters(in: .whitespacesAndNewlines)
        if app.isEmpty || isPlaceholderTitle(app) {
            return nil
        }
        return app
    }
}

enum ExtraHideCopy {
    static func caption(_ outcome: ExtraHideOutcome) -> String {
        switch outcome {
        case .axHidden:
            return "Hidden with Accessibility"
        case .spacerCollapsed:
            return "Collapsed left of Super Spade (public spacer)"
        case .stillVisible:
            return "Bookmarked — still on the system bar"
        }
    }
}

enum OverflowSpacer {
    static let expandedLength: CGFloat = 0.5
    static let minimumCollapsed: CGFloat = 800
    static let maximumCollapsed: CGFloat = 6000

    static func length(collapsed: Bool, screenWidth: CGFloat) -> CGFloat {
        if !collapsed {
            return expandedLength
        }
        return min(max(screenWidth, minimumCollapsed), maximumCollapsed)
    }
}
