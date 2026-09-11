# Menu-item import — honest limits

Super Spade lists **real Accessibility extras only**. It does not invent placeholder items (`Item 1`). It cannot become Bartender.

## What this slice does (public APIs)

1. **List** other extras with Accessibility `AXExtrasMenuBar` after the user grants Accessibility. Untitled extras keep the app name. Synthesized `Item N` titles are dropped.
2. **Click-to-import** captures the extra’s icon when possible, then bookmarks it in Super Spade’s strip (PNG persisted locally — not a secret).
3. **Icon capture order (honest):**
   1. AX `AXImage` if the extra exposes a `CGImage` (`CFGetTypeID` checked first)
   2. Frame grab of the extra’s AX position/size via public `CGWindowListCreateImage` (fails closed if empty / Screen Recording blocked)
   3. Host app icon, labeled **app icon** — not pretended to be the extra’s glyph
4. **Hide attempt:** write `AXHidden` on that extra. If it sticks, the bookmark says **Hidden with Accessibility**.
5. **If AX hide fails:** turn on a **public spacer** that inflates left of Super Spade (`NSStatusItem` length, cap 6000pt). That collapses extras *left of Super Spade*. It is **not** a per-icon steal. The bookmark says so.
6. **Activate:** rematch title + app and `AXPress`. Opens the other extra’s own menu if Accessibility can still see it.

## What macOS will not allow without private APIs

There is **no public API** to:

- Hide another app’s `NSStatusItem` **by identity**
- Reorder or steal other extras onto our bar
- Embed another app’s live status-item view inside the bubble
- Guarantee an exact template glyph when AX exposes no image and frame capture is blocked
- Reliably enumerate extras that never expose `AXExtrasMenuBar`

Hosts that do those things use Window Server / SkyLight / Screen Recording hooks. They break across OS updates. This repo does **not** call SkyLight or private Window Server APIs. Super Spade will not fake a hide: if the extra is still on the system bar, the bookmark says **still on the system bar**.

## Permissions

- **None** for the spade, bubble, flip clock, keep-awake, weather stub, usage meter, or pinning Super Spade’s own thin chips.
- **Accessibility** for listing, icon/frame attributes, `AXHidden`, and `AXPress`.
- **Screen Recording is not requested.** Frame-grab icons may fail; we fall back to the app icon and label it.
- Sign with a **stable** team. Ad-hoc / Sign to Run Locally drops the Accessibility grant on every rebuild.

## Import strip states

- **Denied / waiting** — designed well + System Settings + quit/reopen.
- **Granted, empty** — no AX extras. No placeholders.
- **Granted, available** — click a real extra to capture icon + hide attempt.
- **Granted, all bookmarked** — click to open, right-click to restore (`AXHidden` off; spacer clears when the last bookmark is removed).

## On-bar chips (our widgets)

Keep-awake / flip clock / Claude·Codex / weather can **pin** from the bubble as Apple-thin `NSStatusItem` chips (Sol stamp in `ThinChipTokens`). That is Super Spade pinning its own items — not stealing someone else’s extra.
