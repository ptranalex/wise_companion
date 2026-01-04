import XCTest
@testable import WiseCompanion

final class DailyPolicyTests: XCTestCase {
    func test_dateKey_sameLocalDayDifferentTimes_matches() {
        let timeZone = TimeZone(secondsFromGMT: 0)!
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        let d1 = calendar.date(from: DateComponents(timeZone: timeZone, year: 2026, month: 1, day: 4, hour: 1, minute: 0))!
        let d2 = calendar.date(from: DateComponents(timeZone: timeZone, year: 2026, month: 1, day: 4, hour: 23, minute: 0))!

        let k1 = DailyPolicy.dateKey(for: d1, calendar: calendar, timeZone: timeZone)
        let k2 = DailyPolicy.dateKey(for: d2, calendar: calendar, timeZone: timeZone)

        XCTAssertEqual(k1, k2)
    }

    func test_dateKey_nextDay_changes() {
        let timeZone = TimeZone(secondsFromGMT: 0)!
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        let d1 = Date(timeIntervalSince1970: 1_700_000_000)
        let d2 = d1.addingTimeInterval(60 * 60 * 24)

        let k1 = DailyPolicy.dateKey(for: d1, calendar: calendar, timeZone: timeZone)
        let k2 = DailyPolicy.dateKey(for: d2, calendar: calendar, timeZone: timeZone)

        XCTAssertNotEqual(k1, k2)
    }
}


