import AppKit
import SwiftUI

@main
struct MenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // Status item + NSPanel bubble. No WindowGroup, no Dock window.
        Settings {
            EmptyView()
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBar: StatusBarController?

    nonisolated func applicationDidFinishLaunching(_ notification: Notification) {
        // Delegate callbacks are nonisolated; the run loop delivers them on the main thread.
        MainActor.assumeIsolated {
            NSApp.setActivationPolicy(.accessory)
            let controller = StatusBarController()
            controller.install()
            self.statusBar = controller
        }
    }

    nonisolated func applicationWillTerminate(_ notification: Notification) {
        MainActor.assumeIsolated {
            KeepAwakeController.shared.stop()
            self.statusBar?.teardown()
            self.statusBar = nil
        }
    }

    nonisolated func applicationDidBecomeActive(_ notification: Notification) {
        MainActor.assumeIsolated {
            AppModel.shared.refreshPermissionsAndExtras()
        }
    }
}
