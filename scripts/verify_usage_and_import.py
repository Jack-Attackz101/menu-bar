#!/usr/bin/env python3
"""Mirrors UsageStore / UsageDisplay / ImportStripLogic for Linux verification."""

from __future__ import annotations


def clamp_fraction(value: float) -> float:
    return min(max(value, 0.0), 1.0)


def percent_used(fraction: float) -> str:
    return f"{round(clamp_fraction(fraction) * 100)}%"


def remaining_label(used: float) -> str:
    left = 1 - clamp_fraction(used)
    return f"{round(left * 100)}% left"


def usage_line(used: float) -> str:
    return f"{percent_used(used)} used · {remaining_label(used)}"


def first_key(*values: str | None) -> str | None:
    matched = None
    for candidate in values:
        if candidate is None:
            continue
        if candidate.strip():
            matched = candidate
            break
    if matched is None:
        return None
    return matched.strip()


def parse_env_file(text: str) -> dict[str, str]:
    out: dict[str, str] = {}
    for raw in text.splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip()
        if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
            value = value[1:-1]
        if key:
            out[key] = value
    return out


def extra_identity_placeholder(title: str) -> bool:
    parts = title.strip().split()
    return title.strip().startswith("Item ") and bool(parts) and parts[-1].isdigit()


def import_state(trusted: bool, prompted: bool, discovered: list[str], imported: list[str]) -> str:
    if not trusted:
        return "deniedWaiting" if prompted else "denied"
    if not discovered:
        return "grantedEmpty"
    available = [item for item in discovered if item not in imported]
    return "grantedAllBookmarked" if not available else "grantedAvailable"


def reading(
    *,
    key: str | None,
    demo: float,
    force_empty: bool,
    force_demo: bool,
    snapshot: float | None,
    fetch_kind: str | None,
    fetch_used: float | None,
) -> tuple[str, float, str]:
    if force_empty:
        return ("empty", 0.0, "No key")
    if force_demo:
        return ("demo", clamp_fraction(demo), "demo")
    if fetch_kind == "ok" and fetch_used is not None:
        return ("live", clamp_fraction(fetch_used), "live")
    if fetch_kind == "unauthorized":
        return ("error", clamp_fraction(snapshot or 0), "Key cannot read usage")
    if fetch_kind == "unavailable":
        return ("error", clamp_fraction(snapshot or 0), "Couldn't refresh")
    if snapshot is not None:
        return ("live", clamp_fraction(snapshot), "live")
    if key:
        return ("loading", 0.0, "Updating…")
    return ("demo", clamp_fraction(demo), "demo")


def main() -> int:
    failed = 0

    def check(name: str, got, expected) -> None:
        nonlocal failed
        if got != expected:
            print(f"FAIL {name}: got {got!r} expected {expected!r}")
            failed += 1
        else:
            print(f"PASS {name}")

    check("usage_line_42", usage_line(0.42), "42% used · 58% left")
    check("usage_line_0", usage_line(0), "0% used · 100% left")
    check("first_key_trim", first_key("  sk-ant  ", "other"), "sk-ant")
    check("first_key_blank", first_key(None, "  ", ""), None)
    env = parse_env_file("# c\nANTHROPIC_API_KEY=from-file\nOPENAI_API_KEY='quoted'\n")
    check("env_file", env.get("ANTHROPIC_API_KEY"), "from-file")
    check("env_quote", env.get("OPENAI_API_KEY"), "quoted")
    check("denied", import_state(False, False, [], []), "denied")
    check("waiting", import_state(False, True, [], []), "deniedWaiting")
    check("placeholder", extra_identity_placeholder("Item 1"), True)
    check("not_placeholder", extra_identity_placeholder("Wi-Fi"), False)
    check("empty", import_state(True, True, [], []), "grantedEmpty")
    check("available", import_state(True, False, ["a", "b"], ["a"]), "grantedAvailable")
    check("bookmarked", import_state(True, False, ["a"], ["a"]), "grantedAllBookmarked")
    check("demo", reading(key=None, demo=0.42, force_empty=False, force_demo=False, snapshot=None, fetch_kind=None, fetch_used=None), ("demo", 0.42, "demo"))
    check("empty_flag", reading(key=None, demo=0.42, force_empty=True, force_demo=False, snapshot=None, fetch_kind=None, fetch_used=None), ("empty", 0.0, "No key"))
    check("loading", reading(key="sk", demo=0.42, force_empty=False, force_demo=False, snapshot=None, fetch_kind=None, fetch_used=None), ("loading", 0.0, "Updating…"))
    check("live", reading(key="sk", demo=0.42, force_empty=False, force_demo=False, snapshot=None, fetch_kind="ok", fetch_used=0.33), ("live", 0.33, "live"))
    check("error", reading(key="sk", demo=0.42, force_empty=False, force_demo=False, snapshot=None, fetch_kind="unauthorized", fetch_used=None), ("error", 0.0, "Key cannot read usage"))
    return failed


if __name__ == "__main__":
    raise SystemExit(main())
