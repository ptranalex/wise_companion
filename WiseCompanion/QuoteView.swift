import SwiftUI

struct QuoteView: View {
    @AppStorage(PreferencesKeys.userPrompt) private var userPrompt: String = ""
    @AppStorage(PreferencesKeys.mode) private var modeRawValue: String = GenerationMode.economy.rawValue
    @ObservedObject var viewModel: QuoteViewModel

    let onOpenSettings: () -> Void

    private var mode: GenerationMode {
        GenerationMode(rawValue: modeRawValue) ?? .economy
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.hasAPIKey == false {
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

            if viewModel.isLoading {
                HStack(spacing: 10) {
                    ProgressView()
                        .controlSize(.small)
                    Text("Generating today’s quote…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if let errorMessage = viewModel.errorMessage {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Couldn’t load today’s quote")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 10) {
                        Button("Retry") { viewModel.startLoad(userPrompt: userPrompt, mode: mode) }
                            .buttonStyle(.bordered)
                            .controlSize(.small)

                        if viewModel.isMissingKeyError || viewModel.hasAPIKey == false {
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

            if let payload = viewModel.payload {
                Text("“\(payload.quote)”")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .fixedSize(horizontal: false, vertical: true)

                Text(payload.context)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else if !viewModel.isLoading, viewModel.errorMessage == nil {
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
            viewModel.onAppear(userPrompt: userPrompt, mode: mode)
        }
        .onChange(of: modeRawValue) { _ in
            viewModel.startLoad(userPrompt: userPrompt, mode: mode)
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }
}


