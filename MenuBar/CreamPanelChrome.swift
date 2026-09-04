import SwiftUI

/// Tiny cream card — 16px corners, one print shadow. macOS 14 compatible (no containerBackground).
struct CreamPanelChrome<Content: View>: View {
    var width: CGFloat
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(14)
            .frame(width: width, alignment: .leading)
            .background(Theme.cream, in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .circular))
            .compositingGroup()
            .shadow(color: Theme.ink, radius: 0, x: Theme.printShadowOffset, y: Theme.printShadowOffset)
            .padding(.trailing, Theme.printShadowOffset)
            .padding(.bottom, Theme.printShadowOffset)
    }
}
