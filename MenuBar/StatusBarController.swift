import AppKit
import Combine
import SwiftUI

/// Hosts that ignore hits so `NSStatusBarButton` still receives clicks.
final class ClickThroughHostingView: NSHostingView<AnyView> {
    override func hitTest(_ point: NSPoint) -> NSView? { nil }
}

/// Owns every status item. Created first → sits further right on the bar.
@MainActor
final class StatusBarController: NSObject {
    private let model = AppModel.shared
    private let keepAwake = KeepAwakeController.shared
    private let cpu = CPUMonitor.shared
    private let presenter = PanelPresenter()
    private let islands = HoverIslandPresenter()

    private var overflowItem: NSStatusItem!
    private var keepAwakeItem: NSStatusItem!
    private var calendarItem: NSStatusItem!
    private var cpuItem: NSStatusItem!
    private var quotaItem: NSStatusItem!
    private var weatherItem: NSStatusItem!
    private var hideItem: NSStatusItem!

    private var observers: [AnyCancellable] = []
    private var didScheduleInitialCollapse = false

    func install() {
        overflowItem = makeItem(autosave: "MenuBar.overflow", length: NSStatusItem.variableLength)
        keepAwakeItem = makeItem(autosave: "MenuBar.keepAwake", length: NSStatusItem.variableLength)
        calendarItem = makeItem(autosave: "MenuBar.calendar", length: NSStatusItem.variableLength)
        cpuItem = makeItem(autosave: "MenuBar.cpu", length: NSStatusItem.variableLength)
        quotaItem = makeItem(autosave: "MenuBar.quota", length: NSStatusItem.variableLength)
        weatherItem = makeItem(autosave: "MenuBar.weather", length: NSStatusItem.variableLength)
        hideItem = makeItem(autosave: "MenuBar.hide", length: 18)

        overflowItem.button?.toolTip = "Show or hide extras"
        keepAwakeItem.button?.toolTip = "Keep awake"
        calendarItem.button?.toolTip = "Calendar"
        cpuItem.button?.toolTip = "CPU"
        quotaItem.button?.toolTip = "Quota"
        weatherItem.button?.toolTip = "Weather"
        hideItem.button?.toolTip = "⌘-drag extras left of this tick to hide them when collapsed"

        overflowItem.button?.target = self
        overflowItem.button?.action = #selector(clickOverflow)
        keepAwakeItem.button?.target = self
        keepAwakeItem.button?.action = #selector(clickKeepAwake)

        cpu.start()
        bind()
        applyAll()
        scheduleInitialCollapseIfNeeded()
    }

    func teardown() {
        keepAwake.stop()
        islands.hide()
        presenter.dismiss()
        for item in [overflowItem, keepAwakeItem, calendarItem, cpuItem, quotaItem, weatherItem, hideItem] {
            if let item {
                NSStatusBar.system.removeStatusItem(item)
            }
        }
    }

    private func makeItem(autosave: String, length: CGFloat) -> NSStatusItem {
        let item = NSStatusBar.system.statusItem(withLength: length)
        item.autosaveName = autosave
        item.isVisible = true
        item.button?.imagePosition = .imageOnly
        return item
    }

    private func bind() {
        model.$visibleWidgets
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.applyVisibility() }
            .store(in: &observers)

        model.$overflowExpanded
            .receive(on: DispatchQueue.main)
            .sink { [weak self] expanded in
                self?.applyHideLength(expanded: expanded)
                self?.applyHideTick(expanded: expanded)
                if !expanded {
                    self?.islands.hide()
                    if self?.model.settingsPanelOpen != true {
                        self?.presenter.dismiss()
                    }
                }
            }
            .store(in: &observers)

        model.$overflowPanelOpen
            .receive(on: DispatchQueue.main)
            .sink { [weak self] open in
                if open {
                    self?.islands.hide()
                    self?.presentOverflow()
                }
            }
            .store(in: &observers)

        model.$settingsPanelOpen
            .receive(on: DispatchQueue.main)
            .sink { [weak self] open in
                if open {
                    self?.islands.hide()
                    self?.presentSettings()
                }
            }
            .store(in: &observers)

        keepAwake.$isEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.applyKeepAwakeChip() }
            .store(in: &observers)

        cpu.$percent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.applyCPUChip() }
            .store(in: &observers)
    }

    private func applyAll() {
        applyKeepAwakeChip()
        applyCPUChip()
        applyHoverChip(weatherItem, kind: .weather, view: ChipArtwork.weather(label: "—"), length: 54)
        applyHoverChip(quotaItem, kind: .quota, view: ChipArtwork.quota(label: "—"), length: 56)
        applyHoverChip(calendarItem, kind: .calendar, view: ChipArtwork.calendar(label: "—"), length: 50)
        installClickThrough(overflowItem, view: ChipArtwork.overflow(), length: 34)
        applyVisibility()
        applyHideTick(expanded: true)
        applyHideLength(expanded: true)
    }

    private func applyVisibility() {
        weatherItem.isVisible = model.isVisible(.weather)
        quotaItem.isVisible = model.isVisible(.quota)
        cpuItem.isVisible = model.isVisible(.cpu)
        calendarItem.isVisible = model.isVisible(.calendar)
        keepAwakeItem.isVisible = model.isVisible(.keepAwake)
        overflowItem.isVisible = true
        hideItem.isVisible = true
    }

    private func applyHideLength(expanded: Bool) {
        hideItem.length = expanded ? 18 : Self.collapseLength()
    }

    private func applyHideTick(expanded: Bool) {
        if expanded {
            installClickThrough(hideItem, view: ChipArtwork.hideTick(), length: 18)
        } else {
            clearHost(hideItem)
            hideItem.button?.image = nil
            hideItem.button?.title = ""
        }
    }

    private func applyKeepAwakeChip() {
        installClickThrough(
            keepAwakeItem,
            view: ChipArtwork.keepAwake(on: keepAwake.isEnabled),
            length: 64
        )
    }

    private func applyCPUChip() {
        let label = cpu.percent.map { "\($0)%" } ?? "CPU"
        applyHoverChip(cpuItem, kind: .cpu, view: ChipArtwork.cpu(label: label), length: 68)
    }

    private func applyHoverChip<V: View>(_ item: NSStatusItem, kind: BarWidget, view: V, length: CGFloat) {
        let wrapped = AnyView(
            view.onHover { [weak self] inside in
                guard let self else { return }
                if inside {
                    self.islands.show(kind: kind, from: item)
                } else {
                    self.islands.scheduleHide()
                }
            }
        )
        installHosting(item, view: wrapped, length: length, clickThrough: false)
    }

    private func installClickThrough<V: View>(_ item: NSStatusItem, view: V, length: CGFloat) {
        installHosting(item, view: AnyView(view), length: length, clickThrough: true)
    }

    private func installHosting(_ item: NSStatusItem, view: AnyView, length: CGFloat, clickThrough: Bool) {
        item.length = length
        item.button?.image = nil
        item.button?.title = ""
        guard let button = item.button else { return }

        if let existing = button.subviews.first(where: { $0 is NSHostingView<AnyView> }) as? NSHostingView<AnyView> {
            existing.rootView = view
            existing.frame = NSRect(x: 0, y: 0, width: length, height: Theme.chipHeight)
            return
        }

        clearHost(item)
        let host: NSHostingView<AnyView> = clickThrough
            ? ClickThroughHostingView(rootView: view)
            : NSHostingView(rootView: view)
        host.frame = NSRect(x: 0, y: 0, width: length, height: Theme.chipHeight)
        host.autoresizingMask = [.width, .height]
        button.addSubview(host)
    }

    private func clearHost(_ item: NSStatusItem) {
        item.button?.subviews.forEach { subview in
            if subview is NSHostingView<AnyView> {
                subview.removeFromSuperview()
            }
        }
    }

    private func scheduleInitialCollapseIfNeeded() {
        guard !didScheduleInitialCollapse else { return }
        didScheduleInitialCollapse = true
        guard !model.overflowExpanded else { return }
        // Let extras settle before the first inflate — public spacer hide.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { [weak self] in
            guard let self, !self.model.overflowExpanded else { return }
            self.applyHideLength(expanded: false)
            self.applyHideTick(expanded: false)
        }
    }

    private static func collapseLength() -> CGFloat {
        let widest = NSScreen.screens.map(\.frame.width).max() ?? 1440
        return min(max(widest, 900), 6000)
    }

    @objc private func clickOverflow() {
        islands.hide()
        model.toggleOverflowExpanded()
    }

    @objc private func clickKeepAwake() {
        keepAwake.toggle()
    }

    private func presentOverflow() {
        presenter.show(
            content: OverflowPanel(model: model),
            under: overflowItem.button,
            size: NSSize(width: Theme.overflowPanelWidth, height: 320)
        )
    }

    private func presentSettings() {
        presenter.show(
            content: SettingsPanel(model: model),
            under: overflowItem.button,
            size: NSSize(width: Theme.settingsPanelWidth, height: 420)
        )
    }
}
