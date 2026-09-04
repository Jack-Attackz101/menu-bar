# Menu Bar

Native macOS menu bar extra: one cream mango stamp in the bar, an ink panel that hangs off it, and a keep-awake control that actually prevents sleep.

This slice is the tray icon, the empty ink panel, and keep-awake only. Quota, weather, CPU, and calendar rows are not in yet.

Requires **macOS 14+** and **Xcode 15+**. The bundle display name is the working label **Menu Bar**.

## Run

1. Open `MenuBar.xcodeproj` in Xcode on a Mac (Apple Silicon is fine).
2. Select the **MenuBar** scheme and a signing team (or *Sign to Run Locally*).
3. Run (⌘R). There is no Dock icon (`LSUIElement`). Look in the menu bar for the **cream mango stamp**.

Command line (after signing is set):

```bash
xcodebuild -project MenuBar.xcodeproj -scheme MenuBar -configuration Debug -destination 'platform=macOS' build
```

This repo was scaffolded on Linux, so it has not been compiled here. First Mac QA should be a full Xcode build + the checks below.

## QA

**Tray + panel**
- One menu bar icon: cream (`#FFF9ED`) mango silhouette, not a template glyph, not a system symbol.
- Click opens a dark ink (`#24211D`) panel hanging off the bar — not a cream card, no glass, no sky photo.
- Cream type on ink. One print shadow (`4px 4px 0` ink). No extra glow.

**Keep awake**
- Yellow (`#FFC928`) rounded-rect control, 16px corners, not a pill.
- On: label becomes “Keeping awake”. Closing the panel must **not** drop the assertion (it lives on the app, not the panel).
- Confirm with:

```bash
pmset -g assertions
```

You should see `PreventUserIdleSystemSleep` and/or `PreventUserIdleDisplaySleep` named `Menu Bar keep-awake` (IOKit). If IOKit fails, the app falls back to `/usr/bin/caffeinate -dims`.

- Off: assertions (or the `caffeinate` process) clear. Quit also releases them.

**Dark menu bar**
- The tray stamp is cream on purpose. QA against a dark menu bar (dark wallpaper or dark appearance). A light bar will wash out the stamp.

## Layout later

Five rows are planned: quota, weather, CPU, calendar, keep-awake. This PR only ships keep-awake; the others are skipped, not stubbed as fake UI.
