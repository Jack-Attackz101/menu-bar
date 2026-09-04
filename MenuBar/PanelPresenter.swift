import AppKit
import SwiftUI

/// Borderless glass popover parked under a status item. macOS 14 path — no containerBackground.
final class PanelPresenter {
    private var panel: NSPanel?
    private var monitor: Any?

    func show<Content: View>(content: Content, under button: NSStatusBarButton?, size: NSSize) {
        dismiss()

        let hosting = NSHostingView(rootView: content)
        hosting.frame = NSRect(origin: .zero, size: size)

        let panel = NSPanel(
            contentRect: hosting.frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.level = .statusBar
        panel.collectionBehavior = [.transient, .moveToActiveSpace, .fullScreenAuxiliary]
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.contentView = hosting
        panel.setContentSize(size)

        if let button, let buttonWindow = button.window {
            let buttonRect = button.convert(button.bounds, to: nil)
            let screenRect = buttonWindow.convertToScreen(buttonRect)
            var origin = NSPoint(
                x: screenRect.maxX - size.width + 8,
                y: screenRect.minY - size.height - 4
            )
            if let screen = buttonWindow.screen ?? NSScreen.main {
                let visible = screen.visibleFrame
                origin.x = min(max(origin.x, visible.minX + 8), visible.maxX - size.width - 8)
                origin.y = max(origin.y, visible.minY + 8)
            }
            panel.setFrameOrigin(origin)
        }

        panel.orderFrontRegardless()
        self.panel = panel

        monitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.dismiss()
            AppModel.shared.overflowPanelOpen = false
            AppModel.shared.settingsPanelOpen = false
        }
    }

    func dismiss() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
        panel?.orderOut(nil)
        panel = nil
    }
}
