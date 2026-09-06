import XCTest
@testable import MenuBar

final class FlipClockLogicTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    func testMidnightIsTwelveAM() {
        let date = date(hour: 0, minute: 5)
        let snap = FlipClockSnapshot.from(date: date, calendar: calendar)
        XCTAssertEqual(snap.hourTens, 1)
        XCTAssertEqual(snap.hourOnes, 2)
        XCTAssertEqual(snap.minuteTens, 0)
        XCTAssertEqual(snap.minuteOnes, 5)
        XCTAssertFalse(snap.isAfternoon)
        XCTAssertEqual(snap.meridiem, "AM")
    }

    func testThirteenFortySevenIsOneFortySevenPM() {
        let date = date(hour: 13, minute: 47)
        let snap = FlipClockSnapshot.from(date: date, calendar: calendar)
        XCTAssertEqual(snap.hourDigits, [0, 1])
        XCTAssertEqual(snap.minuteDigits, [4, 7])
        XCTAssertTrue(snap.isAfternoon)
        XCTAssertEqual(snap.meridiem, "PM")
    }

    func testNoonIsTwelvePM() {
        let snap = FlipClockSnapshot.from(date: date(hour: 12, minute: 0), calendar: calendar)
        XCTAssertEqual(snap.hourDigits, [1, 2])
        XCTAssertEqual(snap.minuteDigits, [0, 0])
        XCTAssertTrue(snap.isAfternoon)
    }

    func testTwelveHourWraps() {
        XCTAssertEqual(FlipClockSnapshot.twelveHour(from: 0), 12)
        XCTAssertEqual(FlipClockSnapshot.twelveHour(from: 12), 12)
        XCTAssertEqual(FlipClockSnapshot.twelveHour(from: 23), 11)
        XCTAssertEqual(FlipClockSnapshot.twelveHour(from: 24), 12)
    }

    private func date(hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 9
        components.day = 6
        components.hour = hour
        components.minute = minute
        components.second = 0
        return calendar.date(from: components)!
    }
}
