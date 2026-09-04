import AppKit
import SwiftUI

/// Strips MenuBarExtra `.window` chrome (material / system shadow) so the ink notch can print once.
struct PanelWindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        WindowHookView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        (nsView as? WindowHookView)?.applyIfNeeded()
    }
}

private final class WindowHookView: NSView {
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        applyIfNeeded()
    }

    func applyIfNeeded() {
        guard let window else { return }
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovable = false
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        if #available(macOS 11.0, *) {
            window.toolbar = nil
        }
    }
}
