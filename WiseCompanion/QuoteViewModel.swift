import Foundation

@MainActor
final class QuoteViewModel: ObservableObject {
    @Published var hasAPIKey: Bool? = nil
    @Published var isLoading: Bool = false
    @Published var payload: QuoteCachePayload? = nil
    @Published var errorMessage: String? = nil
    @Published var isMissingKeyError: Bool = false

    private let quoteService: any QuoteServicing
    private let apiKeyStore: any APIKeyStoring

    private var loadTask: Task<Void, Never>?

    init(quoteService: any QuoteServicing, apiKeyStore: any APIKeyStoring) {
        self.quoteService = quoteService
        self.apiKeyStore = apiKeyStore
    }

    func onAppear(userPrompt: String, mode: GenerationMode) {
        refreshHasAPIKey()
        startLoad(userPrompt: userPrompt, mode: mode)
    }

    func onDisappear() {
        cancelLoad()
    }

    func refreshHasAPIKey() {
        do {
            let key = try apiKeyStore.loadAPIKey()?.trimmingCharacters(in: .whitespacesAndNewlines)
            hasAPIKey = (key?.isEmpty == false)
        } catch {
            // If Keychain is unavailable, treat as missing to guide user to Settings.
            hasAPIKey = false
        }
    }

    func cancelLoad() {
        loadTask?.cancel()
        loadTask = nil
    }

    func startLoad(userPrompt: String, mode: GenerationMode) {
        cancelLoad()
        errorMessage = nil
        isMissingKeyError = false
        isLoading = true

        loadTask = Task { [weak self] in
            guard let self else { return }
            await self.loadOnce(userPrompt: userPrompt, mode: mode)
        }
    }

    func loadOnce(userPrompt: String, mode: GenerationMode) async {
        // Don't start a network call if we already know we're missing a key.
        if hasAPIKey == false {
            isLoading = false
            return
        }

        do {
            let result = try await quoteService.loadToday(userPrompt: userPrompt, mode: mode)
            payload = result
            isLoading = false
        } catch is CancellationError {
            // Silent: user closed the popover or changed mode.
            isLoading = false
        } catch let e as OpenAIClientError {
            payload = nil
            isMissingKeyError = (e == .missingAPIKey)
            errorMessage = mapErrorMessage(e)
            isLoading = false
        } catch {
            payload = nil
            errorMessage = "Unexpected error. Please try again."
            isLoading = false
        }
    }

    private func mapErrorMessage(_ e: OpenAIClientError) -> String {
        switch e {
        case .missingAPIKey:
            return "Add an API key in Settings to enable generation."
        case .timedOut:
            return "The request timed out. Check your connection and try again."
        case .apiErrorMessage(let message):
            return message
        case .httpStatus(let code):
            return "Network error (HTTP \(code)). Try again."
        case .invalidQuoteJSON:
            return "The response couldn’t be parsed. Please retry."
        case .invalidResponse, .decodingFailed:
            return "The response was invalid. Please retry."
        }
    }
}

