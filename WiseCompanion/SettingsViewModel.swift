import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var apiKeyDraft: String = ""
    @Published var apiKeyStatusText: String? = nil
    @Published var isAPIKeyVisible: Bool = false

    private let apiKeyStore: any APIKeyStoring

    init(apiKeyStore: any APIKeyStoring) {
        self.apiKeyStore = apiKeyStore
    }

    func loadExistingAPIKey() {
        do {
            if let existing = try apiKeyStore.loadAPIKey(), !existing.isEmpty {
                apiKeyDraft = existing
                apiKeyStatusText = "API key loaded from Keychain."
            } else {
                apiKeyStatusText = "No API key saved yet."
            }
        } catch {
            apiKeyStatusText = "Could not read API key from Keychain."
        }
    }

    func saveAPIKey() {
        do {
            let trimmed = apiKeyDraft.trimmingCharacters(in: .whitespacesAndNewlines)
            try apiKeyStore.saveAPIKey(trimmed)
            apiKeyStatusText = "API key saved to Keychain."
        } catch {
            apiKeyStatusText = "Could not save API key to Keychain."
        }
    }

    func removeAPIKey() {
        do {
            try apiKeyStore.deleteAPIKey()
            apiKeyDraft = ""
            apiKeyStatusText = "API key removed from Keychain."
        } catch {
            apiKeyStatusText = "Could not remove API key from Keychain."
        }
    }
}

