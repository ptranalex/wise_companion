import XCTest
@testable import WiseCompanion

final class QuoteCacheValidationTests: XCTestCase {
    func test_validation_sameDaySameMode_valid() {
        let payload = QuoteCachePayload(
            dateKey: "2026-01-04",
            mode: .premium,
            quote: "q",
            context: "c",
            createdAt: Date()
        )

        XCTAssertTrue(QuoteCacheValidation.isValid(payload: payload, todayDateKey: "2026-01-04", mode: .premium))
    }

    func test_validation_sameDayModeChanged_invalid() {
        let payload = QuoteCachePayload(
            dateKey: "2026-01-04",
            mode: .economy,
            quote: "q",
            context: "c",
            createdAt: Date()
        )

        XCTAssertFalse(QuoteCacheValidation.isValid(payload: payload, todayDateKey: "2026-01-04", mode: .premium))
    }
}


