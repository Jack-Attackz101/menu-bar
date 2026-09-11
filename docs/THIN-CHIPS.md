# Thin on-bar chips (Sol stamp, locked)

Screen-visible Apple-thin chips. Not chunky pills. Not PR #2’s default five-chip host.

## Stamp

All on-bar chip chrome reads `ThinChipTokens` in `MenuBar/BarChip.swift`:

| Token | Locked now |
| --- | --- |
| height | 22 |
| paddingX | 5 |
| spacing | 3 |
| icon | 11 |
| font | 11 |
| stroke | 0.55 |
| fill / border | white 0.10 / 0.30 |

Sol/Mira can retune those numbers without rewriting hosts. `ThinBarChip` + `CompactThinGlass` + `ChipRenderer` stay.

## Pin

Default bar is still **one ♠**. From the bubble (or Settings), pin:

- Keep awake — toggles from the chip
- Flip clock — compact `h:mm`, opens the bubble
- Claude / Codex — `C 42%  X 28%`, opens the bubble
- Weather — `72°`, opens the bubble

Unpin removes that `NSStatusItem`. Pinning recreates chips + the public spacer only — the host ♠ and open bubble stay.

Bubble **Pin / Unpin** chips keep the 22pt glass stamp with a 44×28 hit box (`PinControlLogic`) so clock / usage are not 16pt trailing targets.
