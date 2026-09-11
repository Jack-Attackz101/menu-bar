# Claude / Codex usage meter

The dual meter is labeled **Claude** and **Codex**. It is not a CPU graph.

Super Spade **never stores API keys** in the repo or in `UserDefaults`. Keys stay in the process environment or in a local file Finn/Jack create on the Mac.

## How Finn / Jack set keys

Pick one. Environment wins over the local env file.

### 1. Process environment (preferred)

Xcode scheme → Run → Arguments → Environment Variables:

| Key | Meter |
| --- | --- |
| `ANTHROPIC_API_KEY` (or `CLAUDE_API_KEY` / `CLAUDE_USAGE_KEY`) | Claude |
| `OPENAI_API_KEY` (or `CODEX_API_KEY` / `CODEX_USAGE_KEY`) | Codex |

Launch from a terminal:

```bash
ANTHROPIC_API_KEY=sk-ant-… OPENAI_API_KEY=sk-… open /path/to/MenuBar.app
```

### 2. Local env file (not committed)

```
~/.config/super-spade/usage.env
```

```
# comments ok
ANTHROPIC_API_KEY=sk-ant-…
OPENAI_API_KEY=sk-…
```

Keep this file off git. The app reads it at refresh time and does not copy it into defaults.

### 3. Local snapshot (live without org-admin APIs)

```
~/.config/super-spade/usage.json
```

or set `SUPER_SPADE_USAGE_FILE=/absolute/path/usage.json`.

```json
{
  "claude": { "used": 0.42 },
  "codexUsed": 0.28,
  "updatedAt": "2026-09-07T12:00:00Z"
}
```

`used` is 0…1. This path is treated as **live**.

## States Finn can smoke

| State | How to get it |
| --- | --- |
| **demo** | No keys and no snapshot (default). Finished bars: percent used + remaining + last updated. |
| **empty** | `SUPER_SPADE_USAGE_EMPTY=1` |
| **loading** | Keys present; brief Updating… while the fetch runs |
| **live** | Snapshot file, or a key that actually returns usage JSON (`used` / `used_percent`) |
| **error** | Keys present but the usage API 401/403/5xx or no network. Retry on the meter |

Personal keys usually cannot read org usage admin endpoints. That is expected: the meter shows **error** (retry) or you leave keys unset and keep **demo**.

`SUPER_SPADE_USAGE_DEMO=1` forces demo even if keys exist.
