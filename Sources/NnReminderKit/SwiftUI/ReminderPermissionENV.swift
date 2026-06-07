//
//  ReminderPermissionENV.swift
//
//  Created by Nikolai Nobadi on 3/6/25.
//

import Foundation
import UserNotifications

/// This class checks the current notification authorization status and requests permission when needed.
/// The `status` property is published so that UI components can react to permission changes.
@MainActor
final class ReminderPermissionENV: ObservableObject {
    @Published var status: UNAuthorizationStatus = .notDetermined
    
    private let delegate: PermissionDelegate
    private let options: UNAuthorizationOptions
    private let debugEnabled: Bool

    /// Initializes the environment object with a notification manager and authorization options.
    ///
    /// - Parameters:
    ///   - manager: The `NnReminderManager` responsible for handling notification permissions.
    ///   - options: The authorization options (e.g., `.alert`, `.sound`, `.badge`).
    ///   - debugEnabled: Whether debug messages are printed to the console. Defaults to `false`.
    init(delegate: PermissionDelegate, options: UNAuthorizationOptions, debugEnabled: Bool = false) {
        self.options = options
        self.delegate = delegate
        self.debugEnabled = debugEnabled
    }
}

// MARK: - Actions
extension ReminderPermissionENV {
    /// Checks the current notification permission status and updates `status`.
    ///
    /// This method does not request permissions; it only fetches the existing status.
    func checkPermissionStatus() async {
        let status = await delegate.checkForPermissionsWithoutRequest()

        ReminderKitLogger.log("Permission status updated to \(status.name)", isEnabled: debugEnabled)

        self.status = status
    }

    /// Requests notification permissions from the user.
    ///
    /// If granted, `status` is updated to `.authorized`; otherwise, it is set to `.denied`.
    func requestPermission() async {
        let granted = await delegate.requestAuthPermission(options: options)

        ReminderKitLogger.log("Permission request finished, setting status to \(granted ? "authorized" : "denied")", isEnabled: debugEnabled)

        status = granted ? .authorized : .denied
    }
}


// MARK: - Dependencies
protocol PermissionDelegate: Sendable {
    func checkForPermissionsWithoutRequest() async -> UNAuthorizationStatus
    func requestAuthPermission(options: UNAuthorizationOptions) async -> Bool
}
