//
//  ReminderPermissionENV.swift
//  
//
//  Created by Nikolai Nobadi on 3/6/25.
//

import Foundation
import UserNotifications

final class ReminderPermissionENV: ObservableObject {
    @Published var status: UNAuthorizationStatus = .notDetermined
    
    private let manager: NnReminderManager
    private let options: UNAuthorizationOptions
    
    init(manager: NnReminderManager, options: UNAuthorizationOptions) {
        self.manager = manager
        self.options = options
    }
}


// MARK: - Actions
extension ReminderPermissionENV {
    func checkPermissionStatus() {
        manager.checkForPermissionsWithoutRequest { [weak self] status in
            self?.status = status
        }
    }
    
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
    func setStatus(granted: Bool) {
        status = granted ? .authorized : .denied
    }
}
