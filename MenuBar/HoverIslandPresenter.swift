import AppKit
import SwiftUI

/// Shows a dark frost island under an on-bar chip. Hide is delayed so the
/// cursor can move from the chip into the island. Soft-join, no triangle.
@MainActor
final class HoverIslandPresenter {
    private var panel: NSPanel?
    private var hideWork: DispatchWorkItem?
    private var currentKind: BarWidget?

    func show(kind: BarWidget, from item: NSStatusItem) {
        hideWork?.cancel()
        hideWork = nil
        if kind == .keepAwake {
            return
        }
        if currentKind == kind, panel?.isVisible == true {
            return
        }
        hide()

        let root: AnyView
        switch kind {
        case .weather:
            root = AnyView(WeatherIsland().onHover { [weak self] inside in
                self?.handleIslandHover(inside)
            })
        case .quota:
            root = AnyView(QuotaIsland().onHover { [weak self] inside in
                self?.handleIslandHover(inside)
            })
        case .cpu:
            root = AnyView(CPUIsland(cpu: CPUMonitor.shared).onHover { [weak self] inside in
                self?.handleIslandHover(inside)
            })
        case .calendar:
            root = AnyView(CalendarIsland().onHover { [weak self] inside in
                self?.handleIslandHover(inside)
            })
        case .keepAwake:
            return
        }

        let hosting = NSHostingView(rootView: root)
        hosting.sizingOptions = [.intrinsicContentSize]
        let fitted = hosting.fittingSize
        hosting.frame = NSRect(origin: .zero, size: fitted)

        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: fitted),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .statusBar
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.contentView = hosting
        panel.setContentSize(fitted)

        if let button = item.button, let window = button.window {
            let buttonScreen = button.convert(button.bounds, to: nil)
            let screenRect = window.convertToScreen(buttonScreen)
            var x = screenRect.midX - fitted.width / 2
            let y = screenRect.minY - fitted.height + 6
            if let visible = window.screen?.visibleFrame ?? NSScreen.main?.visibleFrame {
                x = min(max(x, visible.minX + 8), visible.maxX - fitted.width - 8)
            }
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }

        panel.orderFrontRegardless()
        self.panel = panel
        currentKind = kind
    }

    func scheduleHide() {
        hideWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.hide()
        }
        hideWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22, execute: work)
    }

    func hide() {
        hideWork?.cancel()
        hideWork = nil
        panel?.orderOut(nil)
        panel = nil
        currentKind = nil
    }

    private func handleIslandHover(_ inside: Bool) {
        if inside {
            hideWork?.cancel()
            hideWork = nil
        } else {
            scheduleHide()
        }
    }
}
