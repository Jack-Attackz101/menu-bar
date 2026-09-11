# Thin on-bar chips (Sol stamp, locked)

Screen-visible Apple-thin chips. Not chunky pills. Not PR #2’s default five-chip host.

## Stamp

All on-bar chip chrome reads `ThinChipTokens` in `MenuBar/BarChip.swift`:

| Token | Locked now |
| --- | --- |
| height | 20 |
| paddingX | 5 |
| spacing | 3 |
| icon | 10 |
| font | 10 |
| stroke | 0.4 (hairline) |
| fill / border | white 0.08 / 0.26 |

Sol/Mira can retune those numbers without rewriting hosts. `ThinBarChip` + `CompactThinGlass` + `ChipRenderer` stay.

## Pin

Default bar is still **one ♠**. From the bubble (or Settings), pin:

- Keep awake — toggles from the chip
- Flip clock — compact `h:mm`, opens the bubble
- Claude / Codex — `C 42%  X 28%`, opens the bubble
- Weather — `72°`, opens the bubble

Unpin removes that `NSStatusItem`. Pinning recreates chips + the public spacer only — the host ♠ and open bubble stay.

Bubble **Pin** keeps the 20px glass stamp. **Unpin** is quiet text (no filled pill). Both keep a 44×28 hit box (`PinControlLogic`) so clock / usage are not 16pt trailing targets.
