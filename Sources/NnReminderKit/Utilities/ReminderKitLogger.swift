//
//  ReminderKitLogger.swift
//  NnReminderKit
//
//  Created by Nikolai Nobadi on 6/6/26.
//

import UserNotifications

/// Internal helper for printing debug messages.
///
/// Messages are printed with an `[NnReminderKit]` prefix and only when debug logging is enabled.
enum ReminderKitLogger {
    /// Prints a debug message to the console when logging is enabled.
    ///
    /// - Parameters:
    ///   - message: The message to print.
    ///   - isEnabled: Whether debug logging is enabled. When `false`, nothing is printed.
    static func log(_ message: String, isEnabled: Bool) {
        if isEnabled {
            print("[NnReminderKit] \(message)")
        }
    }
}


// MARK: - Extension Dependencies
extension UNAuthorizationStatus {
    /// A readable name for the authorization status, used in debug log messages.
    var name: String {
        switch self {
        case .notDetermined: return "notDetermined"
        case .denied: return "denied"
        case .authorized: return "authorized"
        case .provisional: return "provisional"
        case .ephemeral: return "ephemeral"
        @unknown default: return "unknown"
        }
    }
}
