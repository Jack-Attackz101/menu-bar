import ApplicationServices
import AppKit

struct ExternalMenuExtra: Identifiable, Hashable {
    let id: String
    let title: String
    let appName: String
}

/// Public Accessibility listing of other apps' menu extras.
/// macOS does not let us hide those extras with a public API — listing is the honest part.
enum MenuBarEnumerator {
    static func isTrusted() -> Bool {
        AXIsProcessTrusted()
    }

    static func requestTrust() {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [key: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    static func listExtras() -> [ExternalMenuExtra] {
        guard isTrusted() else { return [] }

        var found: [ExternalMenuExtra] = []
        let ourPID = ProcessInfo.processInfo.processIdentifier

        for app in NSWorkspace.shared.runningApplications {
            let pid = app.processIdentifier
            if pid == ourPID || pid <= 0 { continue }

            let axApp = AXUIElementCreateApplication(pid)
            guard let extrasBar = copyAttribute(axApp, "AXExtrasMenuBar") else { continue }
            guard let children = copyChildren(extrasBar) else { continue }

            let appName = app.localizedName ?? "App"
            for (index, child) in children.enumerated() {
                let title = copyString(child, kAXTitleAttribute as String)
                    ?? copyString(child, kAXDescriptionAttribute as String)
                    ?? copyString(child, kAXHelpAttribute as String)
                    ?? "Item \(index + 1)"
                found.append(
                    ExternalMenuExtra(
                        id: "\(pid).\(index).\(title)",
                        title: title,
                        appName: appName
                    )
                )
            }
        }

        return found.sorted { $0.appName.localizedCaseInsensitiveCompare($1.appName) == .orderedAscending }
    }

    private static func copyAttribute(_ element: AXUIElement, _ name: String) -> AXUIElement? {
        var value: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(element, name as CFString, &value)
        guard error == .success, let value else { return nil }
        return (value as! AXUIElement)
    }

    private static func copyChildren(_ element: AXUIElement) -> [AXUIElement]? {
        var value: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &value)
        guard error == .success else { return nil }
        return value as? [AXUIElement]
    }

    private static func copyString(_ element: AXUIElement, _ name: String) -> String? {
        var value: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(element, name as CFString, &value)
        guard error == .success else { return nil }
        return value as? String
    }
}
