import Foundation

enum QuoteCacheValidation {
    static func isValid(
        payload: QuoteCachePayload?,
        todayDateKey: String,
        mode: GenerationMode
    ) -> Bool {
        guard let payload else { return false }
        return payload.dateKey == todayDateKey && payload.mode == mode
    }
}


