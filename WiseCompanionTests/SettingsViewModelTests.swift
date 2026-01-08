import XCTest
@testable import WiseCompanion

final class SettingsViewModelTests: XCTestCase {
    @MainActor
    func test_loadExistingAPIKey_setsDraftAndStatus_whenPresent() {
        let store = RecordingAPIKeyStore(existing: "sk-123")
        let vm = SettingsViewModel(apiKeyStore: store)

        vm.loadExistingAPIKey()

        XCTAssertEqual(vm.apiKeyDraft, "sk-123")
        XCTAssertEqual(vm.apiKeyStatusText, "API key loaded from Keychain.")
    }

    @MainActor
    func test_saveAPIKey_trimsAndSaves() {
        let store = RecordingAPIKeyStore(existing: nil)
        let vm = SettingsViewModel(apiKeyStore: store)
        vm.apiKeyDraft = "  sk-abc  "

        vm.saveAPIKey()

        XCTAssertEqual(store.savedValues, ["sk-abc"])
        XCTAssertEqual(vm.apiKeyStatusText, "API key saved to Keychain.")
    }

    @MainActor
    func test_removeAPIKey_clearsDraftAndUpdatesStatus() {
        let store = RecordingAPIKeyStore(existing: "sk-123")
        let vm = SettingsViewModel(apiKeyStore: store)
        vm.apiKeyDraft = "sk-123"

        vm.removeAPIKey()

        XCTAssertEqual(store.deleteCalls, 1)
        XCTAssertEqual(vm.apiKeyDraft, "")
        XCTAssertEqual(vm.apiKeyStatusText, "API key removed from Keychain.")
    }
}

private final class RecordingAPIKeyStore: APIKeyStoring {
    private let existing: String?
    private(set) var savedValues: [String] = []
    private(set) var deleteCalls: Int = 0

    init(existing: String?) {
        self.existing = existing
    }

    func loadAPIKey() throws -> String? { existing }

    func saveAPIKey(_ value: String) throws {
        savedValues.append(value)
    }

    func deleteAPIKey() throws {
        deleteCalls += 1
    }
}

