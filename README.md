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
| Menu bar | **One** thin ♠ by default. Optional Apple-thin chips when pinned (keep-awake / flip clock / usage / weather) |
| Click | Borderless `NSPanel` sharper glass bubble (not hover) |
| Top strip | Real AX extras only. Click captures icon + tries hide (AXHidden, else public left-of-spade spacer) |
| Flip clock | Object split-flap cards (housing, hinge, two-phase flip) — not a plain digital clock |
| Usage | **Claude** + **Codex** dual **bar** meters (not CPU). empty / loading / live / demo / error + last-updated + % used / remaining. Optional env or `~/.config/super-spade/usage.env`. Secrets are not stored |
| Keep awake | Real IOKit `PreventUserIdleSystemSleep` + `PreventUserIdleDisplaySleep`, process-owned. `/usr/bin/caffeinate -dims` if IOKit fails |
| Weather | Optional stub (`72°` / Clear · stub) |
| Settings | Gear in the corner. Header is lowercase **super spade** |

Chrome is sharper frost/aurora (tighter radius, hairline stroke). Peach / pink / lavender / sky / teal. No cream `#FFF9ED`, no ink stamp, no mango fruit, no `#FFC928` as brand. On-bar chips use the locked Sol stamp in `ThinChipTokens` (22pt, not chunky pills). See [`docs/THIN-CHIPS.md`](docs/THIN-CHIPS.md).

## Permissions

If Accessibility is missing, the import strip is an intentional denied well: **Allow Accessibility** (system prompt) → **Open System Settings** (Privacy & Security → Accessibility) → **Recheck**. After grant, the app flips to the working strip (poll + `applicationDidBecomeActive`). If TCC lags, **Quit Super Spade** and reopen.

Keep-awake, clock, and meters do not need Accessibility.

## Menu-item import (honest)

See [`docs/MENU-ITEM-IMPORT-LIMITS.md`](docs/MENU-ITEM-IMPORT-LIMITS.md).

Short version: Accessibility lists **real** extras and Super Spade captures their icon (AX image → frame grab → labeled app icon). Hide is `AXHidden` when it works; otherwise a **public spacer** collapses extras left of Super Spade. There is **no public per-icon steal**. No SkyLight. Details: [`docs/MENU-ITEM-IMPORT-LIMITS.md`](docs/MENU-ITEM-IMPORT-LIMITS.md).

## Usage keys (Finn / Jack)

See [`docs/USAGE-METER.md`](docs/USAGE-METER.md).

- Env: `ANTHROPIC_API_KEY` / `OPENAI_API_KEY` (aliases listed in that doc)
- Or `~/.config/super-spade/usage.env` (not committed)
- Or `~/.config/super-spade/usage.json` for a live snapshot without org-admin APIs
- Default with no keys: finished **demo** bars
- `SUPER_SPADE_USAGE_EMPTY=1` forces empty. `SUPER_SPADE_USAGE_DEMO=1` forces demo

## Run

1. Open `MenuBar.xcodeproj` on a Mac.
2. Select the **MenuBar** scheme and a signing team (or Sign to Run Locally).
3. Run (⌘R). No Dock icon (`LSUIElement`). Look for **one** thin spade on the menu bar. Click it.

```bash
xcodebuild -project MenuBar.xcodeproj -scheme MenuBar -configuration Debug -destination 'platform=macOS' build
xcodebuild -project MenuBar.xcodeproj -scheme MenuBar -destination 'platform=macOS' test
```

This tree was written on Linux and has not been compiled here.

Linux checks:

```bash
python3 scripts/verify_flip_clock.py
python3 scripts/verify_usage_and_import.py
python3 scripts/verify_pin_control.py
```

## Finn Mini — smoke (this slice)

Do these on a Mac without waiting on any later visual PR. Product name must be Super Spade.

1. **Compile** — `MenuBar` scheme, macOS 14+. Build must succeed (no `highlightsBy`, no 15-only `containerBackground`, `AppDelegate` uses `MainActor.assumeIsolated`, `AppModel` init assigns from locals). No Swift 6 CF-cast failures (`CFGetTypeID` / `unsafeBitCast` to `CFArray` unchanged).
2. **One refined ♠** by default. Click opens the sharper glass bubble. Pin keep-awake / clock / usage / weather — they land as **Apple-thin 22pt chips**, not chunky pills. Unpin removes them.
3. **Wow-frame visible** — tighter frost/aurora; object flip clock; Claude/Codex as **bar** meters.
4. **Meter states**
   - Default (no keys): **demo** — Claude / Codex labels, percent used + remaining, last-updated, not CPU.
   - `SUPER_SPADE_USAGE_EMPTY=1`: **empty** bar, “No key”.
   - Keys set, then revoke network / use a junk key: **loading** then **error** with Retry.
   - `~/.config/super-spade/usage.json` with `used` fractions: **live**.
5. **Import permission flow**
   - Accessibility off: **compact** denied card (Allow / Settings / Recheck). Flip clock, usage, keep-awake, weather, and Settings stay visible — the prompt must not fill the bubble.
   - After grant: strip flips to extras (or designed empty: “No extras listed” + click-to-bookmark copy).
   - If TCC lags: quit/reopen guidance + **Quit Super Spade**. Then the granted strip appears.
   - **No placeholders.** Only AX extras. Click one: exact icon in the strip (or labeled app icon) **and** hide attempt. If the extra is still on the system bar, the bookmark says so — no fake hide. Spacer collapse = extras *left of Super Spade*. Right-click restores.
6. **Keep-awake** — `pmset -g assertions` shows **`Super Spade keep-awake`**.
7. **Settings** — gear; header **super spade**. No mango / cream / ink.

```bash
pmset -g assertions
```

## Finn — full QA checklist

1. **Compile** — as above.
2. **One ♠** by default. Optional thin pinned chips. Not a default five-chip host. Not hover islands.
3. **Click opens the sharper bubble** — tighter frost/aurora. Peach / pink / lavender / sky / teal. No cream, ink, or mango chrome.
4. **Import strip** — denied / empty / granted as above.
5. **Flip clock** — digits are split cards that flip, not a single digital label.
6. **Claude + Codex** — dual bar meter, those two labels, not CPU.
7. **Keep-awake** — click the control. Close the bubble — assertion stays. Click again (or Quit) to clear.
8. **Settings** — gear in the corner. Header is lowercase **super spade**. Quit is muted.
9. **Finder / About** — **Super Spade**.
