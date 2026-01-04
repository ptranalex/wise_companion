import Foundation

enum GenerationMode: String, CaseIterable, Codable, Identifiable {
    case economy
    case premium

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .economy: return "Economy"
        case .premium: return "Premium"
        }
    }
}

enum PreferencesKeys {
    static let userPrompt = "userPrompt"
    static let mode = "mode"
    static let autoLaunchEnabled = "autoLaunchEnabled"
}

enum SecretsKeys {
    static let openAIAPIKeyAccount = "openai_api_key"
}


