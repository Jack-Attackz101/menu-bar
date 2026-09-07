# Menu-item import — honest limits

Super Spade can **discover** and **bookmark** other menu extras. It cannot become Bartender.

## What this slice does (public APIs)

1. **List** other extras with Accessibility `AXExtrasMenuBar` after the user grants Accessibility.
2. **Click-to-import** those rows into Super Spade’s own bookmarks strip (persisted locally).
3. **Best-effort activate**: clicking an imported bookmark rematches title + app and sends `AXPress`. That opens the other extra’s own menu if Accessibility can see it. It does **not** move the icon into Super Spade.

## What macOS will not allow without private APIs

There is **no public API** to:

- Hide another app’s `NSStatusItem` by identity
- Reorder or steal other extras onto our bar
- Embed another app’s live status-item view inside the bubble
- Punch a “show pad” of captured third-party icons
- Reliably enumerate extras that never expose `AXExtrasMenuBar` (many template glyphs have empty titles)

Hosts that do those things use Window Server / SkyLight / Screen Recording hooks. They break across OS updates. This repo does not.

## Permissions

- **None** for the spade, bubble, flip clock, keep-awake, weather stub, or usage meter.
- **Accessibility** for discovery + AXPress.
  1. **Allow Accessibility** (system prompt).
  2. **Open System Settings** → Privacy & Security → Accessibility (deep link).
  3. Return to Super Spade. The strip flips to the working / empty-granted state (it polls while the status item is installed, and again on `applicationDidBecomeActive`).
  4. If TCC lags and listing still does not appear, **quit and reopen Super Spade**. macOS sometimes applies Accessibility only on the next launch. Recheck is also on the denied well.
- Sign with a **stable** team. Ad-hoc / Sign to Run Locally drops the Accessibility grant on every rebuild.
- **Screen Recording is not requested.**

## Import strip states (designed, not broken)

- **Denied** — frosted well + steps. Not a blank hole.
- **Denied, waiting** — same well plus quit/reopen recovery.
- **Granted, empty** — intentional “No extras listed” well. Click-to-bookmark copy stays visible so the next extra is obvious.
- **Granted, available** — “Click to bookmark”.
- **Granted, all bookmarked** — click to open, right-click to remove.

## What “import” means here

Import is a **bookmark in the bubble**, not a relocation of the system icon. The other extra stays where macOS put it. Right-click an imported chip to remove it from Super Spade’s strip.
