import SwiftUI

struct SettingsView: View {
    @AppStorage(PreferencesKeys.userPrompt) private var userPrompt: String = ""
    @AppStorage(PreferencesKeys.mode) private var modeRawValue: String = GenerationMode.economy.rawValue
    @AppStorage(PreferencesKeys.autoLaunchEnabled) private var autoLaunchEnabled: Bool = true

    let onBack: () -> Void

    @State private var apiKeyDraft: String = ""
    @State private var apiKeyStatusText: String? = nil
    @State private var isAPIKeyVisible: Bool = false
    @State private var autoLaunchStatusText: String? = nil

    private var mode: GenerationMode {
        GenerationMode(rawValue: modeRawValue) ?? .economy
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button("Back", action: onBack)
                    .buttonStyle(.plain)

                Spacer()

                Text("Settings")
                    .font(.headline)

                Spacer()

                // Keep header visually balanced.
                Color.clear.frame(width: 44, height: 1)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Prompt")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                TextEditor(text: $userPrompt)
                    .font(.body)
                    .frame(minHeight: 90)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color.secondary.opacity(0.25))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text("This guides the daily quote (themes, tone, perspective).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Mode")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Picker("Mode", selection: $modeRawValue) {
                    ForEach(GenerationMode.allCases) { m in
                        Text(m.displayName).tag(m.rawValue)
                    }
                }
                .pickerStyle(.segmented)

                Text("Economy uses stricter limits; Premium favors higher quality (still capped).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Toggle("Launch on login", isOn: $autoLaunchEnabled)
                .onChange(of: autoLaunchEnabled) { newValue in
                    autoLaunchStatusText = AutoLaunchManager.syncFromPreferences(autoLaunchEnabled: newValue)
                }

            if let autoLaunchStatusText {
                Text(autoLaunchStatusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Managed via macOS Login Items. If this fails, you can control it in System Settings → Login Items.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("OpenAI API Key")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                HStack(spacing: 8) {
                    Group {
                        if isAPIKeyVisible {
                            TextField("sk-…", text: $apiKeyDraft)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            SecureField("sk-…", text: $apiKeyDraft)
                                .textFieldStyle(.roundedBorder)
                        }
                    }

                    Button(action: { isAPIKeyVisible.toggle() }) {
                        Image(systemName: isAPIKeyVisible ? "eye.slash" : "eye")
                    }
                    .buttonStyle(.plain)
                    .help(isAPIKeyVisible ? "Hide" : "Show")
                }

                HStack(spacing: 10) {
                    Button("Save") { saveAPIKey() }
                        .disabled(apiKeyDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    Button("Remove key", role: .destructive) { removeAPIKey() }

                    Spacer()
                }

                if let apiKeyStatusText {
                    Text(apiKeyStatusText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Stored securely in macOS Keychain. Wise Companion never transmits it anywhere except to OpenAI.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(minWidth: 360, minHeight: 300, alignment: .topLeading)
        .onAppear(perform: loadExistingAPIKey)
    }

    private func loadExistingAPIKey() {
        do {
            let store = KeychainStore()
            if let existing = try store.loadString(account: SecretsKeys.openAIAPIKeyAccount), !existing.isEmpty {
                apiKeyDraft = existing
                apiKeyStatusText = "API key loaded from Keychain."
            } else {
                apiKeyStatusText = "No API key saved yet."
            }
        } catch {
            apiKeyStatusText = "Could not read API key from Keychain."
        }
    }

    private func saveAPIKey() {
        do {
            let store = KeychainStore()
            try store.saveString(apiKeyDraft.trimmingCharacters(in: .whitespacesAndNewlines), account: SecretsKeys.openAIAPIKeyAccount)
            apiKeyStatusText = "API key saved to Keychain."
        } catch {
            apiKeyStatusText = "Could not save API key to Keychain."
        }
    }

    private func removeAPIKey() {
        do {
            let store = KeychainStore()
            try store.delete(account: SecretsKeys.openAIAPIKeyAccount)
            apiKeyDraft = ""
            apiKeyStatusText = "API key removed from Keychain."
        } catch {
            apiKeyStatusText = "Could not remove API key from Keychain."
        }
    }
}


