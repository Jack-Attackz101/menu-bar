import AppKit
import Combine
import SwiftUI

/// Owns every status item. Created first → sits further right on the bar.
@MainActor
final class StatusBarController: NSObject {
    private let model = AppModel.shared
    private let keepAwake = KeepAwakeController.shared
    private let cpu = CPUMonitor.shared
    private let presenter = PanelPresenter()

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
        hideItem = makeItem(autosave: "MenuBar.hide", length: 10)

        overflowItem.button?.toolTip = "Show or hide extras"
        keepAwakeItem.button?.toolTip = "Keep awake"
        calendarItem.button?.toolTip = "Calendar (stub)"
        cpuItem.button?.toolTip = "CPU"
        quotaItem.button?.toolTip = "Quota (stub)"
        weatherItem.button?.toolTip = "Weather (stub)"
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
        item.button?.highlightsBy = []
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
                    self?.presenter.dismiss()
                }
            }
            .store(in: &observers)

        model.$overflowPanelOpen
            .receive(on: DispatchQueue.main)
            .sink { [weak self] open in
                if open {
                    self?.presentOverflow()
                }
            }
            .store(in: &observers)

        model.$settingsPanelOpen
            .receive(on: DispatchQueue.main)
            .sink { [weak self] open in
                if open { self?.presentSettings() }
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
        applyStubChip(weatherItem, view: ChipArtwork.weather(label: "—"))
        applyStubChip(quotaItem, view: ChipArtwork.quota(label: "—"))
        applyStubChip(calendarItem, view: ChipArtwork.calendar(label: "—"))
        applyStubChip(overflowItem, view: ChipArtwork.overflow())
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
        hideItem.length = expanded ? 10 : Self.collapseLength()
    }

    private func applyHideTick(expanded: Bool) {
        if expanded {
            applyStubChip(hideItem, view: ChipArtwork.hideTick())
        } else {
            hideItem.button?.image = nil
            hideItem.button?.title = ""
        }
    }

    private func applyKeepAwakeChip() {
        applyStubChip(keepAwakeItem, view: ChipArtwork.keepAwake(on: keepAwake.isEnabled))
    }

    private func applyCPUChip() {
        let label = cpu.percent.map { "\($0)%" } ?? "CPU"
        applyStubChip(cpuItem, view: ChipArtwork.cpu(label: label))
    }

    private func applyStubChip<V: View>(_ item: NSStatusItem, view: V) {
        let image = ChipImage.nsImage(from: view)
        item.button?.image = image
        item.button?.image?.isTemplate = false
    }

    private func scheduleInitialCollapseIfNeeded() {
        guard !didScheduleInitialCollapse else { return }
        didScheduleInitialCollapse = true
        guard !model.overflowExpanded else { return }
        // Let extras settle before the first inflate — Hidden Bar lesson.
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
        model.toggleOverflowExpanded()
    }

    @objc private func clickKeepAwake() {
        keepAwake.toggle()
    }

    private func presentOverflow() {
        let size = NSSize(width: Theme.overflowPanelWidth + Theme.printShadowOffset,
                          height: 420)
        presenter.show(
            content: OverflowPanel(model: model),
            under: overflowItem.button,
            size: size
        )
    }

    private func presentSettings() {
        let size = NSSize(width: Theme.settingsPanelWidth + Theme.printShadowOffset,
                          height: 200)
        presenter.show(
            content: SettingsPanel(model: model),
            under: overflowItem.button,
            size: size
        )
    }
}
