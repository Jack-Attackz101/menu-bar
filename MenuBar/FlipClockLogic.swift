import Foundation

/// Split-flap digits for a 12-hour flip clock. Pure so Finn can unit-test without AppKit.
struct FlipClockSnapshot: Equatable, Sendable {
    var hourTens: Int
    var hourOnes: Int
    var minuteTens: Int
    var minuteOnes: Int
    var isAfternoon: Bool

    var hourDigits: [Int] { [hourTens, hourOnes] }
    var minuteDigits: [Int] { [minuteTens, minuteOnes] }
    var meridiem: String { isAfternoon ? "PM" : "AM" }

    static func from(date: Date, calendar: Calendar = .current) -> FlipClockSnapshot {
        let hour24 = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let hour12 = Self.twelveHour(from: hour24)
        return FlipClockSnapshot(
            hourTens: hour12 / 10,
            hourOnes: hour12 % 10,
            minuteTens: minute / 10,
            minuteOnes: minute % 10,
            isAfternoon: hour24 >= 12
        )
    }

    /// 0…23 → 12, 1…11, 12, 1…11
    static func twelveHour(from hour24: Int) -> Int {
        let wrapped = ((hour24 % 24) + 24) % 24
        let hour12 = wrapped % 12
        return hour12 == 0 ? 12 : hour12
    }
}
