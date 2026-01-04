import SwiftUI

struct QuoteView: View {
    @AppStorage(PreferencesKeys.userPrompt) private var userPrompt: String = ""
    @AppStorage(PreferencesKeys.mode) private var modeRawValue: String = GenerationMode.economy.rawValue

    let onOpenSettings: () -> Void

    private var mode: GenerationMode {
        GenerationMode(rawValue: modeRawValue) ?? .economy
    }

    @State private var hasAPIKey: Bool? = nil
    @State private var isLoading: Bool = false
    @State private var payload: QuoteCachePayload? = nil
    @State private var errorMessage: String? = nil
    @State private var isMissingKeyError: Bool = false
    @State private var loadTask: Task<Void, Never>? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if hasAPIKey == false {
                VStack(alignment: .leading, spacing: 6) {
                    Text("OpenAI API key required")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text("Add your API key in Settings to enable daily quote generation.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Button("Open Settings", action: onOpenSettings)
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
                .padding(10)
                .background(Color.secondary.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            if isLoading {
                HStack(spacing: 10) {
                    ProgressView()
                        .controlSize(.small)
                    Text("Generating today’s quote…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if let errorMessage {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Couldn’t load today’s quote")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 10) {
                        Button("Retry") { load() }
                            .buttonStyle(.bordered)
                            .controlSize(.small)

                        if isMissingKeyError || hasAPIKey == false {
                            Button("Open Settings", action: onOpenSettings)
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                        }
                    }
                }
                .padding(10)
                .background(Color.secondary.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            if let payload {
                Text("“\(payload.quote)”")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .fixedSize(horizontal: false, vertical: true)

                Text(payload.context)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else if !isLoading, errorMessage == nil {
                Text("“…”")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                Text("Loading…")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            HStack(spacing: 10) {
                Text(Date.now, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("•")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(mode.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Button(action: onOpenSettings) {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(.plain)
                .help("Settings")
            }
        }
        .padding(16)
        .frame(minWidth: 360, minHeight: 260, alignment: .topLeading)
        .onAppear {
            refreshHasAPIKey()
            load()
        }
        .onChange(of: modeRawValue) { _ in
            load()
        }
        .onDisappear {
            loadTask?.cancel()
            loadTask = nil
        }
    }

    private func refreshHasAPIKey() {
        do {
            let store = KeychainStore()
            let key = try store.loadString(account: SecretsKeys.openAIAPIKeyAccount)
            hasAPIKey = (key?.isEmpty == false)
        } catch {
            // If Keychain is unavailable, treat as missing to guide user to Settings.
            hasAPIKey = false
        }
    }

    private func load() {
        loadTask?.cancel()
        errorMessage = nil
        isMissingKeyError = false
        isLoading = true

        loadTask = Task {
            do {
                // Don't start a network call if we already know we're missing a key.
                if hasAPIKey == false {
                    await MainActor.run {
                        isLoading = false
                    }
                    return
                }

                let result = try await AppServices.quoteService.loadToday(userPrompt: userPrompt, mode: mode)
                await MainActor.run {
                    payload = result
                    isLoading = false
                }
            } catch is CancellationError {
                // Silent: user closed the popover or changed mode.
                await MainActor.run {
                    isLoading = false
                }
            } catch let e as OpenAIClientError {
                await MainActor.run {
                    payload = nil
                    isMissingKeyError = (e == .missingAPIKey)
                    errorMessage = mapErrorMessage(e)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    payload = nil
                    errorMessage = "Unexpected error. Please try again."
                    isLoading = false
                }
            }
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


