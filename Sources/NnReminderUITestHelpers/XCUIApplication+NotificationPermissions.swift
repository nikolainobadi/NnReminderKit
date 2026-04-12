import XCTest

/// The user's response to the notification permission alert during a UI test.
public enum NotificationPermissionResponse {
    /// Tap "Don't Allow" to deny notification permission.
    case deny
    /// Tap "Allow" to grant notification permission.
    case allow
}

extension XCUIApplication {
    /// Dismisses the iOS notification permission alert that appears when an app requests authorization via `UNUserNotificationCenter`.
    ///
    /// Call this after launching your app when you expect the notification permission dialog to appear.
    ///
    /// ```swift
    /// let app = XCUIApplication()
    /// app.launch()
    /// app.handleNotificationPermissionAlert(.allow)
    /// ```
    ///
    /// - Parameters:
    ///   - response: The permission alert action to take — either ``NotificationPermissionResponse/allow`` or ``NotificationPermissionResponse/deny``. Default is `.allow`
    ///   - timeout: Maximum time in seconds to wait for the alert to appear. Defaults to `3`.
    public func handleNotificationPermissionAlert(_ response: NotificationPermissionResponse = .allow, timeout: TimeInterval = 3) {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let buttonLabel: String = switch response {
        case .deny: "Don\u{2019}t Allow"
        case .allow: "Allow"
        }
        let alertButton = springboard.alerts.firstMatch.scrollViews.buttons[buttonLabel]
        if alertButton.waitForExistence(timeout: timeout) {
            alertButton.tap()
        }
    }
}
