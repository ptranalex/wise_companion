import Foundation

protocol QuoteGenerating {
    func generateDailyQuote(dateKey: String, userPrompt: String, mode: GenerationMode) async throws -> QuoteCachePayload
}

extension OpenAIClient: QuoteGenerating {}

protocol QuoteServicing {
    func loadToday(userPrompt: String, mode: GenerationMode) async throws -> QuoteCachePayload
}

extension QuoteService: QuoteServicing {}

actor QuoteService {
    private let cacheStore: QuoteCacheStore
    private let generator: QuoteGenerating
    private let calendar: Calendar
    private let timeZone: TimeZone
    private let now: () -> Date

    init(
        cacheStore: QuoteCacheStore = QuoteCacheStore(),
        generator: QuoteGenerating,
        calendar: Calendar = .current,
        timeZone: TimeZone = .current,
        now: @escaping () -> Date = { Date() }
    ) {
        self.cacheStore = cacheStore
        self.generator = generator
        self.calendar = calendar
        self.timeZone = timeZone
        self.now = now
    }

    func loadToday(userPrompt: String, mode: GenerationMode) async throws -> QuoteCachePayload {
        let dateKey = DailyPolicy.dateKey(for: now(), calendar: calendar, timeZone: timeZone)

        if let cached = cacheStore.load(),
           QuoteCacheValidation.isValid(payload: cached, todayDateKey: dateKey, mode: mode)
        {
            AppLog.quote.safeInfo("Quote cache hit (dateKey=\(dateKey), mode=\(mode.rawValue))")
            return cached
        }

        AppLog.quote.safeInfo("Quote cache miss (dateKey=\(dateKey), mode=\(mode.rawValue))")
        try Task.checkCancellation()
        let generated = try await generator.generateDailyQuote(dateKey: dateKey, userPrompt: userPrompt, mode: mode)
        try Task.checkCancellation()
        try cacheStore.save(generated)
        return generated
    }
}

enum AppServices {
    static let quoteService: QuoteService = {
        let keychain = KeychainStore()
        let client = OpenAIClient(apiKeyProvider: {
            try keychain.loadString(account: SecretsKeys.openAIAPIKeyAccount)
        })
        return QuoteService(generator: client)
    }()
}


