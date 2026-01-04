import SwiftUI

struct SettingsView: View {
    @AppStorage(PreferencesKeys.userPrompt) private var userPrompt: String = ""
    @AppStorage(PreferencesKeys.mode) private var modeRawValue: String = GenerationMode.economy.rawValue
    @AppStorage(PreferencesKeys.autoLaunchEnabled) private var autoLaunchEnabled: Bool = true

    let onBack: () -> Void

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

            Text("Note: this toggle is saved now; it will take effect when login-item wiring ships in PR5.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(minWidth: 360, minHeight: 300, alignment: .topLeading)
    }
}


