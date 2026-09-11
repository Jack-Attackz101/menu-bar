#!/usr/bin/env python3
"""Contract checks for pin-to-bar reliability (clock / usage vs keep-awake / weather)."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(rel: str) -> str:
    return (ROOT / rel).read_text()


def main() -> int:
    failed = 0

    def check(name: str, cond: bool, detail: str = "") -> None:
        nonlocal failed
        if cond:
            print(f"PASS {name}")
        else:
            failed += 1
            suffix = f" — {detail}" if detail else ""
            print(f"FAIL {name}{suffix}")

    bar = read("MenuBar/BarChip.swift")
    bubble = read("MenuBar/BubblePanel.swift")
    status = read("MenuBar/StatusBarController.swift")
    logic = read("MenuBar/PinControlLogic.swift") if (ROOT / "MenuBar/PinControlLogic.swift").exists() else ""
    enumerator = read("MenuBar/MenuBarEnumerator.swift")
    import_strip = read("MenuBar/ImportStrip.swift")
    import_logic = read("MenuBar/ImportStripLogic.swift")

    check(
        "pin_logic_file",
        "enum PinControlLogic" in logic,
        "PinControlLogic.swift missing",
    )
    check(
        "min_hit_height_28",
        "minHitHeight: CGFloat = 28" in logic,
        "clock/usage pins need a 28pt hit height",
    )
    check(
        "min_hit_width_44",
        "minHitWidth: CGFloat = 44" in logic,
        "clock/usage pins need a 44pt hit width",
    )
    check(
        "visual_height_matches_thin_chip",
        "visualHeight: CGFloat = 22" in logic and "static let height: CGFloat = 22" in bar,
        "on-bar Apple-thin 22pt stamp must stay",
    )
    check(
        "unique_pin_identifiers",
        all(
            f'super-spade.pin.{name}' in logic
            for name in ("keepAwake", "flipClock", "usage", "weather")
        )
        or "super-spade.pin.\\(widget.rawValue)" in logic
        or 'super-spade.pin.\\(widget.rawValue)' in logic,
        "stable AX identifiers for each pin",
    )
    # Raw string in Swift source is: "super-spade.pin.\(widget.rawValue)"
    check(
        "pin_identifier_template",
        "super-spade.pin." in logic and "widget.rawValue" in logic,
        "identifier must be unique per widget, not a shared Pin label",
    )
    check(
        "pin_affordance_uses_metrics",
        "PinControlLogic.minHitHeight" in bar and "contentShape" in bar,
        "PinAffordance must use the larger hit box + contentShape",
    )
    check(
        "pin_tap_not_scroll_delayed",
        "PrimitiveButtonStyle" in bar or "onTapGesture" in bar,
        "ScrollView-hosted Button needs an immediate tap style",
    )
    check(
        "clock_pin_has_leading_title",
        "pinHeader(.flipClock)" in bubble or "PinnableWidget.flipClock.title" in bubble,
        "clock pin must sit in a titled header, not a Spacer-only trailing chip",
    )
    check(
        "usage_pin_has_leading_title",
        "pinHeader(.usage)" in bubble or "PinnableWidget.usage.title" in bubble,
        "usage pin must sit in a titled header, not a Spacer-only trailing chip",
    )
    check(
        "clock_usage_not_spacer_only_row",
        "func pinHeader" in bubble and "widget.title" in bubble,
        "Spacer-only HStack is what automation misses on clock/usage",
    )
    check(
        "settings_hit_box_constrained",
        "fixedSize()" in bubble and "contentShape" in bubble,
        "settings gear must not expand over trailing clock/usage pins",
    )
    check(
        "pinned_does_not_rebuild_host",
        "$pinned" in status and "rebuildItems()" not in _pinned_sink(status),
        "pin must not dismiss the bubble / destroy the host",
    )
    check(
        "sync_chips_preserves_host",
        "syncChips" in status and "removeStatusItem(host" not in _sync_chips(status),
        "chip sync may recreate chips + spacer only",
    )
    check(
        "collapse_does_not_rebuild",
        "$collapseExtras" in status and "applySpacerLength" in status,
        "collapse still only changes spacer length",
    )
    check(
        "cgimage_typeid_intact",
        "CGImage.typeID" in enumerator and "CGImageGetTypeID" not in enumerator,
        "leave the Finn compile fix alone",
    )
    check(
        "denied_well_scroll_intact",
        "ScrollView" in bubble
        and "compactPrompt" in import_logic
        and "Compact denied card" in import_strip,
        "leave denied-well scroll fixes intact",
    )
    check(
        "chip_order_rightmost_first",
        "allCases.reversed()" in logic or "allCases.reversed()" in status,
        "first-created chip stays rightmost",
    )

    return failed


def _pinned_sink(status: str) -> str:
    start = status.find("$pinned")
    if start < 0:
        return status
    return status[start : start + 400]


def _sync_chips(status: str) -> str:
    start = status.find("func syncChips")
    if start < 0:
        return ""
    return status[start : start + 900]


if __name__ == "__main__":
    raise SystemExit(main())
