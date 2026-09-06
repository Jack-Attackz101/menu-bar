import AppKit
import SwiftUI

/// One spade on the bar. Click opens the glass bubble. No chip row. No hover trays.
@MainActor
final class StatusBarController: NSObject {
    private var item: NSStatusItem!
    private let presenter = BubblePresenter()
    private var permissionTimer: Timer?

    func install() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.autosaveName = "SuperSpade.host"
        item.isVisible = true
        item.button?.imagePosition = .imageOnly
        item.button?.image = MenuBarSpade.image()
        item.button?.toolTip = Theme.productName
        item.button?.target = self
        item.button?.action = #selector(clickSpade)
        item.button?.sendAction(on: [.leftMouseUp])
        self.item = item

        AppModel.shared.refreshPermissionsAndExtras()
        startPermissionWatch()
    }

    func teardown() {
        permissionTimer?.invalidate()
        permissionTimer = nil
        presenter.dismiss()
        KeepAwakeController.shared.stop()
        if let item {
            NSStatusBar.system.removeStatusItem(item)
        }
    }

    private func startPermissionWatch() {
        let timer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { _ in
            Task { @MainActor in
                let model = AppModel.shared
                let trusted = MenuBarEnumerator.isTrusted()
                if trusted != model.accessibilityTrusted {
                    model.refreshPermissionsAndExtras()
                } else if trusted, model.discovered.isEmpty {
                    model.refreshPermissionsAndExtras()
                }
            }
        }
        timer.tolerance = 0.3
        RunLoop.main.add(timer, forMode: .common)
        permissionTimer = timer
    }

    @objc private func clickSpade() {
        presenter.toggle(under: item.button)
        if presenter.isVisible {
            AppModel.shared.refreshPermissionsAndExtras()
        }
    }
}
