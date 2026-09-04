import AppKit
import SwiftUI

@main
struct MenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // Status items are installed by AppDelegate. No WindowGroup, no Dock window.
        Settings {
            EmptyView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let statusBar = StatusBarController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        statusBar.install()
    }

    func applicationWillTerminate(_ notification: Notification) {
        statusBar.teardown()
    }
}
