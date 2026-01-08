import SwiftUI

struct RootView: View {
    private enum Route {
        case quote
        case settings
    }

    @State private var route: Route = .quote
    private let environment: AppEnvironment

    @StateObject private var quoteViewModel: QuoteViewModel
    @StateObject private var settingsViewModel: SettingsViewModel

    init(environment: AppEnvironment = .live) {
        self.environment = environment
        _quoteViewModel = StateObject(wrappedValue: QuoteViewModel(
            quoteService: environment.quoteService,
            apiKeyStore: environment.apiKeyStore
        ))
        _settingsViewModel = StateObject(wrappedValue: SettingsViewModel(
            apiKeyStore: environment.apiKeyStore
        ))
    }

    var body: some View {
        switch route {
        case .quote:
            QuoteView(viewModel: quoteViewModel, onOpenSettings: { route = .settings })
        case .settings:
            SettingsView(viewModel: settingsViewModel, onBack: { route = .quote })
        }
    }
}


