import AppKit

@main
final class WiseCompanionApp: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?
    private let defaults = UserDefaults.standard

    static func main() {
        let app = NSApplication.shared
        let delegate = WiseCompanionApp()
        app.delegate = delegate

        // Menu bar utility: no Dock icon, no menu bar app menu.
        app.setActivationPolicy(.accessory)

        app.run()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        menuBarController = MenuBarController()

        // Sync the login item registration with the stored preference.
        // Default is ON via Settings' AppStorage default value.
        let enabled = defaults.object(forKey: PreferencesKeys.autoLaunchEnabled) as? Bool ?? true
        _ = AutoLaunchManager.syncFromPreferences(autoLaunchEnabled: enabled)
    }
}


