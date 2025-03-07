//
//  ReminderPermissionENV.swift
//
//  Created by Nikolai Nobadi on 3/6/25.
//

import Foundation
import UserNotifications

/// This class checks the current notification authorization status and requests permission when needed.
/// The `status` property is published so that UI components can react to permission changes.
final class ReminderPermissionENV: ObservableObject {
    /// The current authorization status for notifications.
    @Published var status: UNAuthorizationStatus = .notDetermined
    
    /// The notification manager responsible for requesting and checking permissions.
    private let manager: NnReminderManager
    
    /// The notification authorization options to request.
    private let options: UNAuthorizationOptions
    
    /// Initializes the environment object with a notification manager and authorization options.
    ///
    /// - Parameters:
    ///   - manager: The `NnReminderManager` responsible for handling notification permissions.
    ///   - options: The authorization options (e.g., `.alert`, `.sound`, `.badge`).
    init(manager: NnReminderManager, options: UNAuthorizationOptions) {
        self.manager = manager
        self.options = options
    }
}

// MARK: - Actions
extension ReminderPermissionENV {
    /// Checks the current notification permission status and updates `status`.
    ///
    /// This method does not request permissions; it only fetches the existing status.
    func checkPermissionStatus() {
        manager.checkForPermissionsWithoutRequest { [weak self] status in
            self?.status = status
        }
    }
    
    /// Requests notification permissions from the user.
    ///
    /// If granted, `status` is updated to `.authorized`; otherwise, it is set to `.denied`.
    func requestPermission() {
        Task {
            let granted = await manager.requestAuthPermission(options: options)
            await setStatus(granted: granted)
        }
    }
}

// MARK: - MainActor
@MainActor
private extension ReminderPermissionENV {
    /// Updates the `status` property based on whether the user granted permission.
    ///
    /// - Parameter granted: A boolean indicating whether the user granted permission.
    func setStatus(granted: Bool) {
        status = granted ? .authorized : .denied
    }
}
