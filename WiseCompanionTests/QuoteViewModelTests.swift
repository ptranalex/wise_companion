import XCTest
@testable import WiseCompanion

final class QuoteViewModelTests: XCTestCase {
    @MainActor
    func test_loadOnce_missingKey_doesNotCallService() async {
        let keyStore = FakeAPIKeyStore(key: nil)
        let service = FakeQuoteService(result: .success(QuoteCachePayload(
            dateKey: "2026-01-04",
            mode: .economy,
            quote: "q",
            context: "c",
            createdAt: Date(timeIntervalSince1970: 1)
        )))

        let vm = QuoteViewModel(quoteService: service, apiKeyStore: keyStore)
        vm.refreshHasAPIKey()
        vm.isLoading = true
        await vm.loadOnce(userPrompt: "", mode: .economy)

        let calls = await service.calls
        XCTAssertEqual(calls, 0)
        XCTAssertEqual(vm.hasAPIKey, false)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.payload)
        XCTAssertNil(vm.errorMessage)
    }

    @MainActor
    func test_loadOnce_success_setsPayload() async {
        let keyStore = FakeAPIKeyStore(key: "sk-test")
        let expected = QuoteCachePayload(
            dateKey: "2026-01-04",
            mode: .premium,
            quote: "q2",
            context: "c2",
            createdAt: Date(timeIntervalSince1970: 2)
        )
        let service = FakeQuoteService(result: .success(expected))

        let vm = QuoteViewModel(quoteService: service, apiKeyStore: keyStore)
        vm.refreshHasAPIKey()
        vm.isLoading = true
        await vm.loadOnce(userPrompt: "u", mode: .premium)

        XCTAssertEqual(vm.payload, expected)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isMissingKeyError)
    }

    @MainActor
    func test_loadOnce_missingKeyError_setsHelpfulMessage() async {
        let keyStore = FakeAPIKeyStore(key: "sk-test")
        let service = FakeQuoteService(result: .failure(OpenAIClientError.missingAPIKey))

        let vm = QuoteViewModel(quoteService: service, apiKeyStore: keyStore)
        vm.refreshHasAPIKey()
        vm.isLoading = true
        await vm.loadOnce(userPrompt: "", mode: .economy)

        XCTAssertNil(vm.payload)
        XCTAssertFalse(vm.isLoading)
        XCTAssertTrue(vm.isMissingKeyError)
        XCTAssertEqual(vm.errorMessage, "Add an API key in Settings to enable generation.")
    }
}

private final class FakeAPIKeyStore: APIKeyStoring {
    private let key: String?

    init(key: String?) {
        self.key = key
    }

    func loadAPIKey() throws -> String? { key }
    func saveAPIKey(_ value: String) throws { _ = value }
    func deleteAPIKey() throws {}
}

private actor FakeQuoteService: QuoteServicing {
    enum Result {
        case success(QuoteCachePayload)
        case failure(Error)
    }

    private let result: Result
    private(set) var calls: Int = 0

    init(result: Result) {
        self.result = result
    }

    func loadToday(userPrompt: String, mode: GenerationMode) async throws -> QuoteCachePayload {
        _ = userPrompt
        _ = mode
        calls += 1
        switch result {
        case .success(let payload):
            return payload
        case .failure(let error):
            throw error
        }
    }
}

