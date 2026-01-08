import Foundation
import os.log

/// Logging policy (MVP):
/// - Never log secrets (API keys) or user-provided prompts.
/// - Prefer high-level event logs (cache hit/miss, request succeeded/failed) with no payloads.
/// - Keep logs minimal; they should be safe to paste into bug reports.
enum AppLog {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "WiseCompanion"

    // Toggle this if you ever need to completely silence logs.
    // (We still avoid sensitive data regardless of this flag.)
    static var isEnabled: Bool = true

    static let quote = Logger(subsystem: subsystem, category: "quote")
    static let network = Logger(subsystem: subsystem, category: "network")
}

extension Logger {
    func safeInfo(_ message: String) {
        guard AppLog.isEnabled else { return }
        info("\(message, privacy: .public)")
    }

    func safeError(_ message: String) {
        guard AppLog.isEnabled else { return }
        error("\(message, privacy: .public)")
    }
}



