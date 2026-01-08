import SwiftUI

struct AppEnvironment {
    let quoteService: any QuoteServicing
    let apiKeyStore: any APIKeyStoring

    static var live: AppEnvironment {
        let apiKeyStore = KeychainAPIKeyStore()
        let client = OpenAIClient(apiKeyProvider: {
            try apiKeyStore.loadAPIKey()
        })
        let quoteService = QuoteService(generator: client)

        return AppEnvironment(quoteService: quoteService, apiKeyStore: apiKeyStore)
    }
}

private struct AppEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppEnvironment = .live
}

extension EnvironmentValues {
    var appEnvironment: AppEnvironment {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}

