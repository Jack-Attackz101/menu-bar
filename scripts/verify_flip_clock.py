"""Mirrors FlipClockLogic.twelveHour / snapshot digits for Linux verification."""


def twelve_hour(hour24: int) -> int:
    wrapped = ((hour24 % 24) + 24) % 24
    hour12 = wrapped % 12
    return 12 if hour12 == 0 else hour12


def snapshot(hour24: int, minute: int):
    hour12 = twelve_hour(hour24)
    return {
        "hour": [hour12 // 10, hour12 % 10],
        "minute": [minute // 10, minute % 10],
        "pm": hour24 >= 12,
    }


def main() -> int:
    cases = [
        ((0, 5), {"hour": [1, 2], "minute": [0, 5], "pm": False}),
        ((13, 47), {"hour": [0, 1], "minute": [4, 7], "pm": True}),
        ((12, 0), {"hour": [1, 2], "minute": [0, 0], "pm": True}),
        ((23, 11), {"hour": [1, 1], "minute": [1, 1], "pm": True}),
    ]
    failed = 0
    for (h, m), expected in cases:
        got = snapshot(h, m)
        if got != expected:
            print(f"FAIL {h:02d}:{m:02d} got {got} expected {expected}")
            failed += 1
        else:
            print(f"PASS {h:02d}:{m:02d} {got}")
    if twelve_hour(24) != 12:
        print("FAIL twelve_hour(24)")
        failed += 1
    else:
        print("PASS twelve_hour(24) == 12")
    return failed


if __name__ == "__main__":
    raise SystemExit(main())
