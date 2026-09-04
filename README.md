# Super Spade

Widgets **on the menu bar** as separate status items, plus overflow hide via a public `NSStatusItem` spacer.

Display name: **Super Spade**. Settings header: **super spade**. Host mark: a thin spade on aurora glass.

Requires **macOS 14+** and **Xcode 15+**. No macOS 15-only APIs (`containerBackground` is not used).

## What’s on the bar

Separate `NSStatusItem` chips, left → right toward the clock:

| Item | Chip | This slice |
| --- | --- | --- |
| Hide tick | Glass tick | Drop point for ⌘-drag overflow hide |
| Weather | Aurora glass chip | Stub (`—`) + hover island (stub data) |
| Quota | Aurora glass chip | Stub (`—`) + hover island scaffold |
| CPU | Aurora glass chip | Live `%` via `host_statistics` + hover island |
| Calendar | Aurora glass chip | Stub (`—`) + hover island scaffold |
| Keep awake | Aurora glass tap chip | **Works** — IOKit assertions, `caffeinate -dims` fallback |
| Overflow / host | Thin spade | Expand/collapse hide + frosted panel |

Hover weather, quota, CPU, or calendar for a glass island under the chip (soft join, no pointer). Keep-awake stays a tap chip. Click the spade to reveal/hide extras and open the frosted overflow panel. Settings / Quit live there.

## Overflow hide (honest)

**What this ships (public API, macOS 14+):** a status item’s `length` inflates (screen-width, capped at 6000pt) and pushes **everything to its left** off the extras region. Collapse / expand is the overflow control.

**How to use it**
1. Leave overflow **expanded** (tick visible).
2. Hold **⌘** and drag other third-party/system extras **to the left of the tick**.
3. Click the spade to collapse. Those extras should disappear. Click again to reveal them.

**What this will not do without private APIs**
- There is **no public API** to hide another app’s `NSStatusItem` by identity, reorder other extras, or punch a “show pad” of captured icons.
- Some third-party hosts do that with Window Server / SkyLight calls and Screen Recording. Those crash across OS updates; this repo does not use them.
- Accessibility can **list** other extras (`AXExtrasMenuBar`) and is optional here. It still cannot hide them one-by-one.
- System Settings → Control Center can hide some *system* extras. The settings panel links there.
- On very new macOS, Apple has started ignoring giant status-item lengths in some builds. If collapse does nothing, that is an OS limit, not a missing private hook.

**Permissions**
- None required for our widgets, keep-awake, CPU, or the spacer hide.
- **Accessibility** (optional): overflow panel can list other extras. System Settings → Privacy & Security → Accessibility. Sign with a **stable** team/certificate; ad-hoc signing drops the grant on every rebuild.
- **Screen Recording** is not requested. A future “show hidden icons in a tray” would need it (and still would not hide extras by identity on the public API).

## Run

1. Open `MenuBar.xcodeproj` on a Mac.
2. Select the **MenuBar** scheme and a signing team (or Sign to Run Locally).
3. Run (⌘R). No Dock icon (`LSUIElement`). Look at the menu bar chips.

```bash
xcodebuild -project MenuBar.xcodeproj -scheme MenuBar -configuration Debug -destination 'platform=macOS' build
```

This tree was written on Linux and has not been compiled here.

## QA

- Five widget chips plus the spade host mark are **on the bar**, not inside one list.
- Keep awake: click the glass chip → `pmset -g assertions` shows `Super Spade keep-awake`. Click again to clear.
- CPU chip updates after a couple of seconds (live).
- Hover weather (and quota / CPU / calendar): glass island appears under the chip with a soft join, not a hard pointer.
- Overflow: ⌘-drag another extra left of the tick, collapse, confirm it is gone; expand, confirm it returns.
- Settings header is lowercase **super spade**. About line is **Super Spade 1.0**. Quit is secondary.
- Chrome is aurora glass (peach / pink / lavender / sky / teal). No cream or ink product chrome.

## Later

Weather, quota, and calendar chips are on the bar; weather island data is still a stub until network is wired.
