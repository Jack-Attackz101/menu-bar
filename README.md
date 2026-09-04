# Bardeck

Host app that puts widgets **on the menu bar** as separate status items, plus a Bartender-style overflow that can hide extras to the left of a public spacer.

Display name: **Bardeck**. Settings header: **bardeck**. Neutral cream/ink host mark (three filled dots) — not a fruit stamp.

Requires **macOS 14+** and **Xcode 15+**. No macOS 15-only APIs (`containerBackground` is not used).

PR #1 (single mango-stamp panel) is a dead direction and is left unmerged.

## What’s on the bar

Separate `NSStatusItem` chips, left → right toward the clock:

| Item | Chip | This slice |
| --- | --- | --- |
| Hide tick | Cream handmade tick | Drop point for ⌘-drag hide |
| Weather | `#BFDDF3` pill | Stub (`—`) |
| Quota | cream pill | Stub (`—`) |
| CPU | cream pill | Live `%` via `host_statistics` |
| Calendar | cream pill | Stub (`—`) |
| Keep awake | `#FFC928` when on, cream when off | **Works** — IOKit assertions, `caffeinate -dims` fallback |
| Overflow / host | cream three-dot mark | Expand/collapse hide + cream panel |

Click keep-awake on the bar to toggle. Click the host mark to reveal/hide extras and open the cream overflow panel. Settings / Quit live in that tiny cream panel (16px corners), not as the main product.

## Bartender-style hide (honest)

**What this ships (public API, macOS 14+):** the Hidden Bar spacer trick. A status item’s `length` inflates (screen-width, capped at 6000pt) and pushes **everything to its left** off the extras region. Collapse / expand is the overflow control.

**How to use it**
1. Leave overflow **expanded** (cream tick visible).
2. Hold **⌘** and drag other third-party/system extras **to the left of the tick**.
3. Click the three-dot host mark to collapse. Those extras should disappear. Click again to reveal them.

**What this will not do without private APIs**
- There is **no public API** to hide another app’s `NSStatusItem` by identity, reorder other extras, or punch a Bartender “show pad” of captured icons.
- Bartender / Ice do that with Window Server / SkyLight calls and Screen Recording. Those crash across OS updates; this repo does not use them.
- Accessibility can **list** other extras (`AXExtrasMenuBar`) and is optional here. It still cannot hide them one-by-one.
- System Settings → Control Center can hide some *system* extras. The settings panel links there.
- On very new macOS, Apple has started ignoring giant status-item lengths in some builds. If collapse does nothing, that is an OS limit, not a missing private hook.

**Permissions**
- None required for our widgets, keep-awake, CPU, or the spacer hide.
- **Accessibility** (optional): overflow panel can list other extras. System Settings → Privacy & Security → Accessibility. Sign with a **stable** team/certificate; ad-hoc signing drops the grant on every rebuild.
- **Screen Recording** is not requested. A future “show hidden icons in a tray” would need it (and still would not be a full Ice clone).

## Run

1. Open `MenuBar.xcodeproj` on a Mac.
2. Select the **MenuBar** scheme and a signing team (or Sign to Run Locally).
3. Run (⌘R). No Dock icon (`LSUIElement`). Look at the menu bar chips.

```bash
xcodebuild -project MenuBar.xcodeproj -scheme MenuBar -configuration Debug -destination 'platform=macOS' build
```

This tree was written on Linux and has not been compiled here.

## QA

- Five widget chips plus the cream host mark are **on the bar**, not inside one list.
- Keep awake: click the yellow/cream chip → `pmset -g assertions` shows `Bardeck keep-awake`. Click again to clear. Closing nothing should drop it — there is no widget panel to close.
- CPU chip updates after a couple of seconds.
- Overflow: ⌘-drag another extra left of the tick, collapse, confirm it is gone; expand, confirm it returns.
- Overflow panel is cream, 16px corners. Settings header is lowercase **bardeck**. Quit is secondary.
- No mango / fruit tray identity.

## Later

Weather, quota, and calendar chips are on the bar but not wired to data yet.
