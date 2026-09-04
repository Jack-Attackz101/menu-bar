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
        // MenuBarExtra .window ships a material backdrop on 14; hide it so the
        // SwiftUI ink shape is the only fill (no glass / cream card).
        stripMaterial(from: window.contentView)
        DispatchQueue.main.async { [weak self] in
            guard let self, let window = self.window else { return }
            self.stripMaterial(from: window.contentView)
        }
    }

    private func stripMaterial(from view: NSView?) {
        guard let view else { return }
        if view is NSVisualEffectView {
            view.isHidden = true
            view.alphaValue = 0
        }
        for subview in view.subviews {
            stripMaterial(from: subview)
        }
    }
}
