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
    
    /// Initializes the environment object with a notification manager and authorization options.
    ///
    /// - Parameters:
    ///   - manager: The `NnReminderManager` responsible for handling notification permissions.
    ///   - options: The authorization options (e.g., `.alert`, `.sound`, `.badge`).
    init(delegate: PermissionDelegate, options: UNAuthorizationOptions) {
        self.options = options
        self.delegate = delegate
    }
}

// MARK: - Actions
extension ReminderPermissionENV {
    /// Checks the current notification permission status and updates `status`.
    ///
    /// This method does not request permissions; it only fetches the existing status.
    func checkPermissionStatus() async {
        let status = await delegate.checkForPermissionsWithoutRequest()
        
        self.status = status
    }
    
    /// Requests notification permissions from the user.
    ///
    /// If granted, `status` is updated to `.authorized`; otherwise, it is set to `.denied`.
    func requestPermission() async {
        let granted = await delegate.requestAuthPermission(options: options)
        
        status = granted ? .authorized : .denied
    }
}


// MARK: - Dependencies
protocol PermissionDelegate: Sendable {
    func checkForPermissionsWithoutRequest() async -> UNAuthorizationStatus
    func requestAuthPermission(options: UNAuthorizationOptions) async -> Bool
}
