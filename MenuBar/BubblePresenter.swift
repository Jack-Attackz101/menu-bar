import AppKit
import SwiftUI

/// Borderless glass bubble parked under the single spade. macOS 14 — no containerBackground.
@MainActor
final class BubblePresenter {
    private var panel: NSPanel?
    private var monitor: Any?

    var isVisible: Bool { panel?.isVisible == true }

    func toggle(under button: NSStatusBarButton?) {
        if isVisible {
            dismiss()
        } else {
            show(under: button)
        }
    }

    func show(under button: NSStatusBarButton?) {
        dismiss()

        let root = BubblePanel(model: AppModel.shared, keepAwake: KeepAwakeController.shared)
        let hosting = NSHostingView(rootView: root)
        let size = NSSize(width: Theme.bubbleWidth, height: Theme.bubbleHeight)
        hosting.frame = NSRect(origin: .zero, size: size)

        let panel = NSPanel(
            contentRect: hosting.frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .statusBar
        panel.collectionBehavior = [.transient, .moveToActiveSpace, .fullScreenAuxiliary]
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.contentView = hosting
        panel.setContentSize(size)

        if let button, let buttonWindow = button.window {
            let buttonRect = button.convert(button.bounds, to: nil)
            let screenRect = buttonWindow.convertToScreen(buttonRect)
            var origin = NSPoint(
                x: screenRect.maxX - size.width + 10,
                y: screenRect.minY - size.height - 6
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

        monitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            Task { @MainActor in
                self?.handleOutsideClick(event)
            }
        }
    }

    func dismiss() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
        panel?.orderOut(nil)
        panel = nil
        AppModel.shared.showingSettings = false
    }

    private func handleOutsideClick(_ event: NSEvent) {
        guard let panel else { return }
        let location = NSEvent.mouseLocation
        if !panel.frame.contains(location) {
            dismiss()
        }
    }
}
