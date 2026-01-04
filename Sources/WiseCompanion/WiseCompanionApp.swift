import AppKit

@main
final class WiseCompanionApp: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?

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
    }
}


