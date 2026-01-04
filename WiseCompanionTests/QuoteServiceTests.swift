import XCTest
@testable import WiseCompanion

final class QuoteServiceTests: XCTestCase {
    func test_loadToday_returnsCached_whenValid() async throws {
        let dir = try makeTempDir()
        let store = QuoteCacheStore(baseDirectoryURL: dir)

        let fixedCreatedAt = Date(timeIntervalSince1970: 1_704_000_000)
        let cached = QuoteCachePayload(
            dateKey: "2026-01-04",
            mode: .economy,
            quote: "q",
            context: "c",
            createdAt: fixedCreatedAt
        )
        try store.save(cached)

        let generator = StubGenerator { _, _, _ in
            XCTFail("Should not generate when cache is valid")
            return cached
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let nowDate = calendar.date(from: DateComponents(timeZone: calendar.timeZone, year: 2026, month: 1, day: 4, hour: 12, minute: 0))!

        let service = QuoteService(
            cacheStore: store,
            generator: generator,
            calendar: calendar,
            timeZone: calendar.timeZone,
            now: { nowDate }
        )

        let result = try await service.loadToday(userPrompt: "", mode: .economy)
        XCTAssertEqual(result, cached)
    }

    func test_loadToday_generatesAndPersists_whenMissing() async throws {
        let dir = try makeTempDir()
        let store = QuoteCacheStore(baseDirectoryURL: dir)

        let generated = QuoteCachePayload(
            dateKey: "2026-01-04",
            mode: .premium,
            quote: "q2",
            context: "c2",
            createdAt: Date(timeIntervalSince1970: 1)
        )

        let generator = StubGenerator { dateKey, _, mode in
            XCTAssertEqual(dateKey, "2026-01-04")
            XCTAssertEqual(mode, .premium)
            return generated
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let nowDate = calendar.date(from: DateComponents(timeZone: calendar.timeZone, year: 2026, month: 1, day: 4, hour: 12, minute: 0))!

        let service = QuoteService(
            cacheStore: store,
            generator: generator,
            calendar: calendar,
            timeZone: calendar.timeZone,
            now: { nowDate }
        )

        let result = try await service.loadToday(userPrompt: "", mode: .premium)
        XCTAssertEqual(result.quote, "q2")
        XCTAssertEqual(store.load(), generated)
    }

    func test_loadToday_modeFlip_regenerates() async throws {
        let dir = try makeTempDir()
        let store = QuoteCacheStore(baseDirectoryURL: dir)

        let fixedCreatedAt = Date(timeIntervalSince1970: 1)
        let cached = QuoteCachePayload(
            dateKey: "2026-01-04",
            mode: .economy,
            quote: "q",
            context: "c",
            createdAt: fixedCreatedAt
        )
        try store.save(cached)

        let generated = QuoteCachePayload(
            dateKey: "2026-01-04",
            mode: .premium,
            quote: "qp",
            context: "cp",
            createdAt: Date(timeIntervalSince1970: 2)
        )

        let generator = CountingGenerator { _, _, _ in generated }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let nowDate = calendar.date(from: DateComponents(timeZone: calendar.timeZone, year: 2026, month: 1, day: 4, hour: 12, minute: 0))!

        let service = QuoteService(
            cacheStore: store,
            generator: generator,
            calendar: calendar,
            timeZone: calendar.timeZone,
            now: { nowDate }
        )

        let result = try await service.loadToday(userPrompt: "", mode: .premium)
        XCTAssertEqual(result, generated)
        XCTAssertEqual(generator.calls, 1)
        XCTAssertEqual(store.load(), generated)
    }

    func test_loadToday_cancel_doesNotPersist() async throws {
        let dir = try makeTempDir()
        let store = QuoteCacheStore(baseDirectoryURL: dir)

        let generator = StubGenerator { dateKey, _, mode in
            _ = dateKey
            _ = mode
            try await Task.sleep(nanoseconds: 2_000_000_000)
            return QuoteCachePayload(dateKey: "2026-01-04", mode: .economy, quote: "q", context: "c", createdAt: Date())
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let nowDate = calendar.date(from: DateComponents(timeZone: calendar.timeZone, year: 2026, month: 1, day: 4, hour: 12, minute: 0))!

        let service = QuoteService(
            cacheStore: store,
            generator: generator,
            calendar: calendar,
            timeZone: calendar.timeZone,
            now: { nowDate }
        )

        let task = Task {
            _ = try await service.loadToday(userPrompt: "", mode: .economy)
        }

        task.cancel()
        _ = await task.result

        XCTAssertNil(store.load())
    }

    private func makeTempDir() throws -> URL {
        let base = FileManager.default.temporaryDirectory
        let dir = base.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
}

private final class StubGenerator: QuoteGenerating {
    typealias Handler = (String, String, GenerationMode) async throws -> QuoteCachePayload
    private let handler: Handler

    init(handler: @escaping Handler) { self.handler = handler }

    func generateDailyQuote(dateKey: String, userPrompt: String, mode: GenerationMode) async throws -> QuoteCachePayload {
        try await handler(dateKey, userPrompt, mode)
    }
}

private final class CountingGenerator: QuoteGenerating {
    typealias Handler = (String, String, GenerationMode) async throws -> QuoteCachePayload
    private let handler: Handler
    private(set) var calls: Int = 0

    init(handler: @escaping Handler) { self.handler = handler }

    func generateDailyQuote(dateKey: String, userPrompt: String, mode: GenerationMode) async throws -> QuoteCachePayload {
        calls += 1
        return try await handler(dateKey, userPrompt, mode)
    }
}


