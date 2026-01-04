import Foundation

final class QuoteCacheStore {
    private let fileManager: FileManager
    private let fileURL: URL

    init(fileManager: FileManager = .default, baseDirectoryURL: URL? = nil) {
        self.fileManager = fileManager

        if let baseDirectoryURL {
            self.fileURL = baseDirectoryURL.appendingPathComponent("quote_cache.json", isDirectory: false)
        } else {
            let base = QuoteCacheStore.defaultAppSupportDirectoryURL(fileManager: fileManager)
            self.fileURL = base.appendingPathComponent("quote_cache.json", isDirectory: false)
        }
    }

    func load() -> QuoteCachePayload? {
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(QuoteCachePayload.self, from: data)
        } catch {
            return nil
        }
    }

    func save(_ payload: QuoteCachePayload) throws {
        try ensureParentDirectoryExists()

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(payload)
        try data.write(to: fileURL, options: [.atomic])
    }

    func clear() throws {
        guard fileManager.fileExists(atPath: fileURL.path) else { return }
        try fileManager.removeItem(at: fileURL)
    }

    // MARK: - Helpers

    private func ensureParentDirectoryExists() throws {
        let dir = fileURL.deletingLastPathComponent()
        try fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
    }

    private static func defaultAppSupportDirectoryURL(fileManager: FileManager) -> URL {
        let appSupport = (try? fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )) ?? fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support", isDirectory: true)

        let appFolderName = Bundle.main.bundleIdentifier ?? "WiseCompanion"
        return appSupport.appendingPathComponent(appFolderName, isDirectory: true)
    }
}


