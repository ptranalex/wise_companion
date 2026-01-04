import SwiftUI

struct QuoteView: View {
    @AppStorage(PreferencesKeys.userPrompt) private var userPrompt: String = ""
    @AppStorage(PreferencesKeys.mode) private var modeRawValue: String = GenerationMode.economy.rawValue

    let onOpenSettings: () -> Void

    private let quote = "Start the day by choosing one thing to do with care."
    private let context =
        "Your attention is your most valuable resource. When you decide where it goes before the day decides for you, you keep your agency. Let today be guided by a single intentional commitment."

    private var mode: GenerationMode {
        GenerationMode(rawValue: modeRawValue) ?? .economy
    }

    @State private var hasAPIKey: Bool? = nil

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

            Text("“\(quote)”")
                .font(.title3)
                .fontWeight(.semibold)
                .fixedSize(horizontal: false, vertical: true)

            Text(context)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

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
        .onAppear(perform: refreshHasAPIKey)
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
}


