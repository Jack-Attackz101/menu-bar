# Super Spade

Widgets on the menu bar as separate status items, plus overflow hide via a public `NSStatusItem` spacer.

**Identity (locked)**
- Display name / About / keep-awake assertion: **Super Spade**
- Settings header: **super spade**
- Assertion in `pmset`: **`Super Spade keep-awake`**
- Host mark: thin spade on aurora glass

Xcode target / scheme / folder `MenuBar` and bundle id `com.jack-attackz101.menu-bar` are internals, not the product name.

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
| Keep awake | Aurora glass **tap** chip | IOKit assertions, `caffeinate -dims` fallback |
| Overflow / host | Thin spade | Expand/collapse hide + frosted panel |

Hover weather, quota, CPU, or calendar for a glass island under the chip (soft capsule join, no triangle pointer). Keep-awake is tap-only — no island. Click the spade to reveal/hide extras and open the frosted overflow panel. Settings / Quit live there.

Chrome: peach / pink / lavender / sky / teal mesh, frosted chips, big continuous corners, clean sans, thin icons.

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
- None required for widgets, keep-awake, CPU, or the spacer hide.
- **Accessibility** (optional): overflow panel can list other extras. System Settings → Privacy & Security → Accessibility. Sign with a **stable** team/certificate; ad-hoc signing drops the grant on every rebuild.
- **Screen Recording** is not requested.

## Run

1. Open `MenuBar.xcodeproj` on a Mac.
2. Select the **MenuBar** scheme and a signing team (or Sign to Run Locally).
3. Run (⌘R). No Dock icon (`LSUIElement`). Look at the chips on the menu bar.

```bash
xcodebuild -project MenuBar.xcodeproj -scheme MenuBar -configuration Debug -destination 'platform=macOS' build
```

This tree was written on Linux and has not been compiled here.

## Finn — morning QA

Do these in order on a Mac. Product name must be Super Spade everywhere a person can see it.

1. **Compile** — `MenuBar` scheme, macOS 14+ destination. Build must succeed (no `highlightsBy`, no 15-only `containerBackground`, AppDelegate / AppModel init order intact).
2. **Five chips on the bar** — weather, quota, CPU, calendar, keep-awake, plus the spade host and hide tick. Separate status items, not one panel list.
3. **Keep-awake** — click the chip (tap only, no hover island). `pmset -g assertions` shows **`Super Spade keep-awake`**. Click again to clear.
4. **Overflow hide** — overflow expanded, tick visible → ⌘-drag another extra **left of the tick** → click the spade to collapse → extra gone → click again to restore.
5. **No mango** — no cream `#FFF9ED`, no ink `#24211D`, no fruit / mango-stamp chrome. Finder / About says **Super Spade**. Settings header is lowercase **super spade**.
6. **Aurora glass + hover islands** — chips are frosted peach / pink / lavender / sky / teal. Hover weather (same for quota / CPU / calendar): island sits under the chip with a **soft capsule join**, not a hard triangle pointer. Keep-awake stays tap-only.

Also: CPU chip should show a live `%` after a couple of seconds.

## Later

Weather, quota, and calendar chips are on the bar; weather island data is still a stub until network is wired.
