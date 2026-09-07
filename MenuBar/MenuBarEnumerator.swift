import ApplicationServices
import AppKit
import CoreFoundation
import CoreGraphics

/// Public Accessibility listing of other apps' menu extras (`AXExtrasMenuBar`).
/// Per-item hide/steal/embed of another app's `NSStatusItem` is not a public API.
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
            let bundleId = app.bundleIdentifier
            for (index, child) in children.enumerated() {
                guard let title = ExtraIdentity.resolvedTitle(
                    axTitle: copyString(child, kAXTitleAttribute as String),
                    axDescription: copyString(child, kAXDescriptionAttribute as String),
                    axHelp: copyString(child, kAXHelpAttribute as String),
                    appName: appName
                ) else { continue }

                let icon = captureIcon(from: child, app: app)
                found.append(
                    DiscoveredExtra(
                        id: "\(bundleId ?? appName).\(title).\(index)",
                        title: title,
                        appName: appName,
                        bundleId: bundleId,
                        iconPNG: icon?.data,
                        iconSource: icon?.source ?? .none
                    )
                )
            }
        }

        return found.sorted { $0.appName.localizedCaseInsensitiveCompare($1.appName) == .orderedAscending }
    }

    /// Best-effort AXPress on a rematched extra. Cannot relocate the system icon.
    @discardableResult
    static func pressExtra(matching extra: DiscoveredExtra) -> Bool {
        guard let child = findElement(matching: extra) else { return false }
        let error = AXUIElementPerformAction(child, kAXPressAction as CFString)
        return error == .success
    }

    /// Attempt `AXHidden`. Returns true only when the attribute accepts the write.
    @discardableResult
    static func attemptHide(matching extra: DiscoveredExtra, hidden: Bool) -> Bool {
        guard isTrusted(), let child = findElement(matching: extra) else { return false }
        let value: CFBoolean = hidden ? kCFBooleanTrue : kCFBooleanFalse
        let error = AXUIElementSetAttributeValue(child, kAXHiddenAttribute as CFString, value)
        return error == .success
    }

    static func captureIcon(matching extra: DiscoveredExtra) -> (data: Data, source: ExtraIconSource)? {
        guard let child = findElement(matching: extra) else {
            return appIconData(bundleId: extra.bundleId, appName: extra.appName)
        }
        let app = NSWorkspace.shared.runningApplications.first { running in
            if let bundleId = extra.bundleId {
                return running.bundleIdentifier == bundleId
            }
            return (running.localizedName ?? "App") == extra.appName
        }
        return captureIcon(from: child, app: app)
    }

    /// `AXUIElement` is a CF type, so `as? AXUIElement` always succeeds. Check the type ID first.
    static func axUIElement(from value: CFTypeRef) -> AXUIElement? {
        guard CFGetTypeID(value) == AXUIElementGetTypeID() else { return nil }
        return unsafeBitCast(value, to: AXUIElement.self)
    }

    static func cgImage(from value: CFTypeRef) -> CGImage? {
        guard CFGetTypeID(value) == CGImageGetTypeID() else { return nil }
        return unsafeBitCast(value, to: CGImage.self)
    }

    private static func findElement(matching extra: DiscoveredExtra) -> AXUIElement? {
        guard isTrusted() else { return nil }
        let ourPID = ProcessInfo.processInfo.processIdentifier
        for app in NSWorkspace.shared.runningApplications {
            let pid = app.processIdentifier
            if pid == ourPID || pid <= 0 { continue }
            let name = app.localizedName ?? "App"
            let bundleMatches = extra.bundleId != nil && app.bundleIdentifier == extra.bundleId
            let nameMatches = name == extra.appName
            if !bundleMatches && !nameMatches { continue }

            let axApp = AXUIElementCreateApplication(pid)
            guard let extrasBar = copyAttribute(axApp, "AXExtrasMenuBar") else { continue }
            guard let children = copyChildren(extrasBar) else { continue }

            for child in children {
                let title = ExtraIdentity.resolvedTitle(
                    axTitle: copyString(child, kAXTitleAttribute as String),
                    axDescription: copyString(child, kAXDescriptionAttribute as String),
                    axHelp: copyString(child, kAXHelpAttribute as String),
                    appName: app.localizedName ?? extra.appName
                )
                if title == extra.title {
                    return child
                }
            }
        }
        return nil
    }

    private static func captureIcon(
        from element: AXUIElement,
        app: NSRunningApplication?
    ) -> (data: Data, source: ExtraIconSource)? {
        if let image = copyAXImage(element), let data = pngData(from: image) {
            return (data, .axImage)
        }
        if let image = copyFrameImage(element), let data = pngData(from: image) {
            return (data, .axFrame)
        }
        return appIconData(bundleId: app?.bundleIdentifier, appName: app?.localizedName)
    }

    private static func copyAXImage(_ element: AXUIElement) -> NSImage? {
        for name in ["AXImage"] {
            var value: CFTypeRef?
            let error = AXUIElementCopyAttributeValue(element, name as CFString, &value)
            guard error == .success, let value else { continue }
            if let cgImage = cgImage(from: value) {
                return NSImage(cgImage: cgImage, size: .zero)
            }
        }
        return nil
    }

    private static func copyFrameImage(_ element: AXUIElement) -> NSImage? {
        guard let rect = copyFrame(element), rect.width >= 4, rect.height >= 4 else { return nil }
        let top = NSScreen.screens.map(\.frame.maxY).max() ?? 0
        let quartz = CGRect(
            x: rect.minX,
            y: top - rect.maxY,
            width: rect.width,
            height: rect.height
        )
        guard let cgImage = CGWindowListCreateImage(
            quartz,
            [.optionOnScreenOnly, .excludeDesktopElements],
            kCGNullWindowID,
            [.bestResolution]
        ) else { return nil }
        if isMostlyEmpty(cgImage) {
            return nil
        }
        return NSImage(cgImage: cgImage, size: NSSize(width: rect.width, height: rect.height))
    }

    private static func isMostlyEmpty(_ image: CGImage) -> Bool {
        image.width < 2 || image.height < 2
    }

    private static func appIconData(bundleId: String?, appName: String?) -> (data: Data, source: ExtraIconSource)? {
        let app = NSWorkspace.shared.runningApplications.first { running in
            if let bundleId {
                return running.bundleIdentifier == bundleId
            }
            return running.localizedName == appName
        }
        guard let icon = app?.icon, let data = pngData(from: icon) else { return nil }
        return (data, .appIcon)
    }

    private static func pngData(from image: NSImage) -> Data? {
        guard let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff) else { return nil }
        return rep.representation(using: .png, properties: [:])
    }

    private static func copyFrame(_ element: AXUIElement) -> CGRect? {
        guard let origin = copyCGPoint(element, kAXPositionAttribute as String),
              let size = copyCGSize(element, kAXSizeAttribute as String) else { return nil }
        return CGRect(origin: origin, size: size)
    }

    private static func copyCGPoint(_ element: AXUIElement, _ name: String) -> CGPoint? {
        var value: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(element, name as CFString, &value)
        guard error == .success, let value else { return nil }
        guard CFGetTypeID(value) == AXValueGetTypeID() else { return nil }
        let ax = unsafeBitCast(value, to: AXValue.self)
        var point = CGPoint.zero
        guard AXValueGetValue(ax, .cgPoint, &point) else { return nil }
        return point
    }

    private static func copyCGSize(_ element: AXUIElement, _ name: String) -> CGSize? {
        var value: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(element, name as CFString, &value)
        guard error == .success, let value else { return nil }
        guard CFGetTypeID(value) == AXValueGetTypeID() else { return nil }
        let ax = unsafeBitCast(value, to: AXValue.self)
        var size = CGSize.zero
        guard AXValueGetValue(ax, .cgSize, &size) else { return nil }
        return size
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
}
