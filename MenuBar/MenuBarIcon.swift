import AppKit
import SwiftUI

enum MenuBarIcon {
    /// Cream mango stamp for the status item. Not a template — keep `#FFF9ED` on the dark bar.
    static func creamStamp(pointSize: CGFloat = 18) -> NSImage {
        let size = NSSize(width: pointSize, height: pointSize)
        let image = NSImage(size: size, flipped: true) { rect in
            NSGraphicsContext.current?.imageInterpolation = .high
            Theme.creamNS.setFill()
            let inset = rect.insetBy(dx: pointSize * 0.06, dy: pointSize * 0.06)
            NSBezierPath(cgPath: MangoGeometry.stampPath(in: inset)).fill()
            return true
        }
        image.isTemplate = false
        return image
    }
}

struct MenuBarLabel: View {
    var body: some View {
        Image(nsImage: MenuBarIcon.creamStamp())
            .renderingMode(.original)
            .interpolation(.high)
            .accessibilityLabel("Menu Bar")
    }
}
