# Super Spade

One thin spade on the Mac menu bar. Click opens an aurora-glass bubble — not a row of chips, not hover trays.

**Identity (locked)**

- Product / About / Finder: **Super Spade**
- Settings header: **super spade**
- Keep-awake assertion: **`Super Spade keep-awake`**
- Bar mark: thin ♠ on a small aurora-glass pill

Xcode target / scheme / folder `MenuBar` and bundle id `com.jack-attackz101.menu-bar` are internals.

Requires **macOS 14+** and **Xcode 15+**. No macOS 15-only APIs (`containerBackground` is not used). `NSStatusBarButton.highlightsBy` is not used.

This PR is a **new slice**. It does not continue PR #2 (chips-on-bar / hover islands) and does not touch PR #1.

## What’s in the bubble

| Surface | What ships |
| --- | --- |
| Menu bar | **One** `NSStatusItem` — thin spade on aurora glass |
| Click | Borderless `NSPanel` glass bubble (not hover) |
| Top strip | Bookmarks-style import of other extras (click to add) |
| Flip clock | Split-flap digits, 12-hour + AM/PM — not a plain digital clock |
| Usage | **Claude** + **Codex** dual meter (not CPU). Optional `ANTHROPIC_API_KEY` / `OPENAI_API_KEY` in the environment; still a labeled stub because personal keys are not org usage APIs. Secrets are not stored |
| Keep awake | Real IOKit `PreventUserIdleSystemSleep` + `PreventUserIdleDisplaySleep`, process-owned. `/usr/bin/caffeinate -dims` if IOKit fails |
| Weather | Optional stub (`72°` / Clear · stub) |
| Settings | Gear in the corner. Header is lowercase **super spade** |

Chrome is mesh/aurora glass (peach / pink / lavender / sky / teal), big continuous corners. No cream `#FFF9ED`, no ink stamp, no mango fruit, no `#FFC928` as brand.

## Permissions

If Accessibility is missing, the import strip prompts → **Allow Accessibility** (system prompt) and **Open System Settings**. After grant, the app flips to the working strip (poll + `applicationDidBecomeActive`).

Keep-awake, clock, and meters do not need Accessibility.

## Menu-item import (honest)

See [`docs/MENU-ITEM-IMPORT-LIMITS.md`](docs/MENU-ITEM-IMPORT-LIMITS.md).

Short version: Accessibility can **list** extras (`AXExtrasMenuBar`) and Super Spade can **bookmark** them. macOS has **no public API** to hide, steal, or embed another app’s status item. Import is a bookmark + optional `AXPress`, not Bartender.

## Run

1. Open `MenuBar.xcodeproj` on a Mac.
2. Select the **MenuBar** scheme and a signing team (or Sign to Run Locally).
3. Run (⌘R). No Dock icon (`LSUIElement`). Look for **one** thin spade on the menu bar. Click it.

```bash
xcodebuild -project MenuBar.xcodeproj -scheme MenuBar -configuration Debug -destination 'platform=macOS' build
xcodebuild -project MenuBar.xcodeproj -scheme MenuBar -destination 'platform=macOS' test
```

This tree was written on Linux and has not been compiled here.

Linux check for flip-clock math:

```bash
python3 scripts/verify_flip_clock.py
```

## Finn — QA checklist

Do these on a Mac. Product name must be Super Spade everywhere a person can see it.

1. **Compile** — `MenuBar` scheme, macOS 14+ destination. Build must succeed (no `highlightsBy`, no 15-only `containerBackground`, `AppDelegate` uses `MainActor.assumeIsolated` in `applicationDidFinishLaunching`, `AppModel` init assigns from locals).
2. **One spade** — a single status item. Not five chips. Not a hide tick. Not hover islands.
3. **Click opens the bubble** — aurora / mesh glass, big rounded corners. Peach / pink / lavender / sky / teal. No cream, ink, or mango chrome.
4. **Import strip** — if Accessibility is off: prompt + System Settings (Privacy & Security → Accessibility). Grant it, return to the app, strip flips to discovered extras. If it does not, quit and reopen (TCC sometimes applies only on the next launch). Click an extra to import it into Super Spade’s bar (the strip). Right-click to remove. Drag is optional and not required.
5. **Flip clock** — digits are split cards that flip, not a single digital label.
6. **Claude + Codex** — dual meter, those two labels, not CPU. Without keys: “no API key · stub”.
7. **Keep-awake** — click the control. `pmset -g assertions` shows **`Super Spade keep-awake`**. Close the bubble — assertion stays. Click again (or Quit) to clear.
8. **Settings** — gear in the corner. Header is lowercase **super spade**. Quit is muted.
9. **Finder / About** — **Super Spade**.

```bash
pmset -g assertions
```
