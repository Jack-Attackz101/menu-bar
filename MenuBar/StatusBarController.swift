import AppKit
import Combine
import SwiftUI

/// Host spade always. Optional Apple-thin widget chips. Optional public hide spacer.
@MainActor
final class StatusBarController: NSObject {
    private var host: NSStatusItem?
    private var spacer: NSStatusItem?
    private var chips: [PinnableWidget: NSStatusItem] = [:]
    private let presenter = BubblePresenter()
    private var permissionTimer: Timer?
    private var chipTimer: Timer?
    private var observers = Set<AnyCancellable>()

    func install() {
        rebuildItems()
        AppModel.shared.refreshPermissionsAndExtras()
        startPermissionWatch()
        startChipClock()
        AppModel.shared.$pinned
            .combineLatest(AppModel.shared.$collapseExtras)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, _ in
                self?.rebuildItems()
            }
            .store(in: &observers)
        AppModel.shared.$claude
            .combineLatest(AppModel.shared.$codex)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, _ in
                self?.refreshChipImages()
            }
            .store(in: &observers)
        KeepAwakeController.shared.$isEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshChipImages()
            }
            .store(in: &observers)
    }

    func teardown() {
        permissionTimer?.invalidate()
        permissionTimer = nil
        chipTimer?.invalidate()
        chipTimer = nil
        observers.removeAll()
        presenter.dismiss()
        KeepAwakeController.shared.stop()
        removeAllItems()
    }

    private func rebuildItems() {
        let visible = presenter.isVisible
        let anchor = host?.button
        if visible {
            presenter.dismiss()
        }
        removeAllItems()

        // First created sits rightmost. Spacer last so it is leftmost of Super Spade.
        installHost()
        for widget in PinnableWidget.allCases.reversed() where AppModel.shared.isPinned(widget) {
            installChip(widget)
        }
        installSpacer()
        refreshChipImages()
        applySpacerLength()
        if visible {
            presenter.show(under: anchor ?? host?.button)
        }
    }

    private func removeAllItems() {
        if let host {
            NSStatusBar.system.removeStatusItem(host)
        }
        if let spacer {
            NSStatusBar.system.removeStatusItem(spacer)
        }
        for item in chips.values {
            NSStatusBar.system.removeStatusItem(item)
        }
        host = nil
        spacer = nil
        chips = [:]
    }

    private func installHost() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.autosaveName = "SuperSpade.host"
        item.isVisible = true
        item.button?.imagePosition = .imageOnly
        item.button?.image = MenuBarSpade.image()
        item.button?.toolTip = Theme.productName
        item.button?.target = self
        item.button?.action = #selector(clickSpade)
        item.button?.sendAction(on: [.leftMouseUp])
        host = item
    }

    private func installSpacer() {
        let item = NSStatusBar.system.statusItem(withLength: OverflowSpacer.expandedLength)
        item.autosaveName = "SuperSpade.spacer"
        item.isVisible = true
        item.button?.title = ""
        item.button?.toolTip = AppModel.shared.collapseExtras
            ? "Extras left of Super Spade are collapsed. Click to restore."
            : "Public spacer. Importing an extra collapses extras left of Super Spade."
        item.button?.target = self
        item.button?.action = #selector(clickSpacer)
        spacer = item
    }

    private func installChip(_ widget: PinnableWidget) {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.autosaveName = "SuperSpade.chip.\(widget.rawValue)"
        item.isVisible = true
        item.button?.imagePosition = .imageOnly
        item.button?.toolTip = widget.title
        item.button?.target = self
        item.button?.action = #selector(clickChip(_:))
        item.button?.identifier = NSUserInterfaceItemIdentifier(widget.rawValue)
        chips[widget] = item
    }

    private func applySpacerLength() {
        let width = host?.button?.window?.screen?.frame.width ?? NSScreen.main?.frame.width ?? 1440
        spacer?.length = OverflowSpacer.length(
            collapsed: AppModel.shared.collapseExtras,
            screenWidth: width
        )
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

    private func startChipClock() {
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                self.refreshChipImages()
                self.applySpacerLength()
            }
        }
        timer.tolerance = 0.2
        RunLoop.main.add(timer, forMode: .common)
        chipTimer = timer
    }

    private func refreshChipImages() {
        let model = AppModel.shared
        if let item = chips[.keepAwake] {
            item.button?.image = ChipRenderer.image(
                for: ThinChipArtwork.keepAwake(on: KeepAwakeController.shared.isEnabled)
            )
        }
        if let item = chips[.flipClock] {
            let snap = FlipClockSnapshot.from(date: Date())
            item.button?.image = ChipRenderer.image(
                for: ThinChipArtwork.flipClock(label: snap.compactLabel)
            )
        }
        if let item = chips[.usage] {
            item.button?.image = ChipRenderer.image(
                for: ThinChipArtwork.usage(
                    claude: UsageDisplay.percentUsed(model.claude.fraction),
                    codex: UsageDisplay.percentUsed(model.codex.fraction)
                )
            )
        }
        if let item = chips[.weather] {
            item.button?.image = ChipRenderer.image(
                for: ThinChipArtwork.weather(label: "72°")
            )
        }
    }

    @objc private func clickSpade() {
        presenter.toggle(under: host?.button)
        if presenter.isVisible {
            AppModel.shared.refreshPermissionsAndExtras()
        }
    }

    @objc private func clickSpacer() {
        AppModel.shared.setCollapseExtras(!AppModel.shared.collapseExtras)
    }

    @objc private func clickChip(_ sender: Any?) {
        let identifier = (sender as? NSStatusBarButton)?.identifier?.rawValue
            ?? (sender as? NSButton)?.identifier?.rawValue
        guard let raw = identifier, let widget = PinnableWidget(rawValue: raw) else {
            presenter.toggle(under: host?.button)
            return
        }
        switch widget {
        case .keepAwake:
            KeepAwakeController.shared.toggle()
            refreshChipImages()
        case .flipClock, .usage, .weather:
            presenter.toggle(under: chips[widget]?.button ?? host?.button)
        }
    }
}
