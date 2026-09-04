import AppKit
import SwiftUI

enum ChipImage {
    @MainActor
    static func nsImage<V: View>(from view: V, scale: CGFloat = 2) -> NSImage {
        let renderer = ImageRenderer(content: view)
        renderer.scale = scale
        let image = renderer.nsImage ?? NSImage(size: NSSize(width: 18, height: 18))
        image.isTemplate = false
        return image
    }
}
