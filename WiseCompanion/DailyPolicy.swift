import Foundation

enum DailyPolicy {
    static func dateKey(
        for date: Date,
        calendar: Calendar = .current,
        timeZone: TimeZone = .current
    ) -> String {
        var cal = calendar
        cal.timeZone = timeZone

        let formatter = DateFormatter()
        formatter.calendar = cal
        formatter.timeZone = timeZone
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"

        return formatter.string(from: date)
    }
}


