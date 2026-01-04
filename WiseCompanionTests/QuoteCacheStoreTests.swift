import XCTest
@testable import WiseCompanion

final class QuoteCacheStoreTests: XCTestCase {
    func test_saveThenLoad_roundTrips() throws {
        let dir = try makeTempDir()
        let store = QuoteCacheStore(baseDirectoryURL: dir)

        let payload = QuoteCachePayload(
            dateKey: "2026-01-04",
            mode: .economy,
            quote: "q",
            context: "c",
            createdAt: Date(timeIntervalSince1970: 1_700_000_000)
        )

        try store.save(payload)

        let loaded = store.load()
        XCTAssertEqual(loaded, payload)
    }

    func test_saveOverwrites_existing() throws {
        let dir = try makeTempDir()
        let store = QuoteCacheStore(baseDirectoryURL: dir)

        let p1 = QuoteCachePayload(dateKey: "2026-01-04", mode: .economy, quote: "q1", context: "c1", createdAt: Date(timeIntervalSince1970: 1))
        let p2 = QuoteCachePayload(dateKey: "2026-01-04", mode: .economy, quote: "q2", context: "c2", createdAt: Date(timeIntervalSince1970: 2))

        try store.save(p1)
        try store.save(p2)

        XCTAssertEqual(store.load(), p2)
    }

    private func makeTempDir() throws -> URL {
        let base = FileManager.default.temporaryDirectory
        let dir = base.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
}


