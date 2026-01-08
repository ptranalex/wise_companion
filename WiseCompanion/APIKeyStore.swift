import Foundation

protocol APIKeyStoring {
    func loadAPIKey() throws -> String?
    func saveAPIKey(_ value: String) throws
    func deleteAPIKey() throws
}

final class KeychainAPIKeyStore: APIKeyStoring {
    private let keychain: KeychainStore
    private let account: String

    init(
        keychain: KeychainStore = KeychainStore(),
        account: String = SecretsKeys.openAIAPIKeyAccount
    ) {
        self.keychain = keychain
        self.account = account
    }

    func loadAPIKey() throws -> String? {
        try keychain.loadString(account: account)
    }

    func saveAPIKey(_ value: String) throws {
        try keychain.saveString(value, account: account)
    }

    func deleteAPIKey() throws {
        try keychain.delete(account: account)
    }
}

