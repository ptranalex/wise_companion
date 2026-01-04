import SwiftUI

struct RootView: View {
    private enum Route {
        case quote
        case settings
    }

    @State private var route: Route = .quote

    var body: some View {
        switch route {
        case .quote:
            QuoteView(onOpenSettings: { route = .settings })
        case .settings:
            SettingsView(onBack: { route = .quote })
        }
    }
}


