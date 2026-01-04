import Foundation

enum GenerationMode: String, CaseIterable, Identifiable {
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


