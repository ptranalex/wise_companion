import Foundation
import ServiceManagement

enum AutoLaunchManager {
    static func setEnabled(_ enabled: Bool) throws {
        if enabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }
    }

    static func syncFromPreferences(autoLaunchEnabled: Bool) -> String? {
        do {
            try setEnabled(autoLaunchEnabled)
            return autoLaunchEnabled ? "Launch on login enabled." : "Launch on login disabled."
        } catch {
            return "Could not update login-item setting. You can manage it in System Settings → Login Items."
        }
    }
}


