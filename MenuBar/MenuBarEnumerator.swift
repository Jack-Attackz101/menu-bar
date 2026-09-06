import ApplicationServices
import AppKit
import CoreFoundation

/// Public Accessibility listing of other apps' menu extras (`AXExtrasMenuBar`).
/// macOS has no public API to hide, steal, or embed those extras.
enum MenuBarEnumerator {
    static func isTrusted() -> Bool {
        AXIsProcessTrusted()
    }

    static func requestTrust() {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [key: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    static func openAccessibilitySettings() {
        let urls = [
            "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Accessibility",
            "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        ]
        for string in urls {
            guard let url = URL(string: string) else { continue }
            if NSWorkspace.shared.open(url) {
                return
            }
        }
    }

    static func listExtras() -> [DiscoveredExtra] {
        guard isTrusted() else { return [] }

        var found: [DiscoveredExtra] = []
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
                    DiscoveredExtra(
                        id: "\(appName).\(title).\(index)",
                        title: title,
                        appName: appName
                    )
                )
            }
        }

        return found.sorted { $0.appName.localizedCaseInsensitiveCompare($1.appName) == .orderedAscending }
    }

    /// Best-effort AXPress on a rematched extra. Cannot relocate the system icon.
    @discardableResult
    static func pressExtra(matching extra: DiscoveredExtra) -> Bool {
        guard isTrusted() else { return false }

        let ourPID = ProcessInfo.processInfo.processIdentifier
        for app in NSWorkspace.shared.runningApplications {
            let pid = app.processIdentifier
            if pid == ourPID || pid <= 0 { continue }
            let appName = app.localizedName ?? "App"
            if appName != extra.appName { continue }

            let axApp = AXUIElementCreateApplication(pid)
            guard let extrasBar = copyAttribute(axApp, "AXExtrasMenuBar") else { continue }
            guard let children = copyChildren(extrasBar) else { continue }

            for child in children {
                let title = copyString(child, kAXTitleAttribute as String)
                    ?? copyString(child, kAXDescriptionAttribute as String)
                    ?? copyString(child, kAXHelpAttribute as String)
                if title == extra.title {
                    let error = AXUIElementPerformAction(child, kAXPressAction as CFString)
                    return error == .success
                }
            }
        }
        return false
    }

    private static func copyAttribute(_ element: AXUIElement, _ name: String) -> AXUIElement? {
        var value: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(element, name as CFString, &value)
        guard error == .success, let value else { return nil }
        return axUIElement(from: value)
    }

    private static func copyChildren(_ element: AXUIElement) -> [AXUIElement]? {
        var value: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &value)
        guard error == .success, let value else { return nil }
        guard CFGetTypeID(value) == CFArrayGetTypeID() else { return nil }
        let cfArray = unsafeBitCast(value, to: CFArray.self)
        let count = CFArrayGetCount(cfArray)
        var children: [AXUIElement] = []
        children.reserveCapacity(count)
        for index in 0..<count {
            guard let raw = CFArrayGetValueAtIndex(cfArray, index) as UnsafeRawPointer? else {
                continue
            }
            let item = Unmanaged<AnyObject>.fromOpaque(raw).takeUnretainedValue()
            if let child = axUIElement(from: item) {
                children.append(child)
            }
        }
        return children
    }

    private static func copyString(_ element: AXUIElement, _ name: String) -> String? {
        var value: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(element, name as CFString, &value)
        guard error == .success else { return nil }
        return value as? String
    }

    /// `AXUIElement` is a CF type, so `as? AXUIElement` always succeeds. Check the type ID first.
    static func axUIElement(from value: CFTypeRef) -> AXUIElement? {
        guard CFGetTypeID(value) == AXUIElementGetTypeID() else { return nil }
        return unsafeBitCast(value, to: AXUIElement.self)
    }
}
