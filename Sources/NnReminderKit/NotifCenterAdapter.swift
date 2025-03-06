//
//  NotifCenterAdapter.swift
//  
//
//  Created by Nikolai Nobadi on 3/5/25.
//

import UserNotifications

final class NotifCenterAdapter {
    private let notifCenter = UNUserNotificationCenter.current()
}


// MARK: - NotifCenter
extension NotifCenterAdapter: NotifCenter {
    func add(_ request: UNNotificationRequest) {
        notifCenter.add(request)
    }
    
    func removeAllPendingNotificationRequests() {
        notifCenter.removeAllPendingNotificationRequests()
    }
    
    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        notifCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        return try await notifCenter.requestAuthorization(options: options)
    }
    
    func setNotificationDelegate(_ delegate: UNUserNotificationCenterDelegate) {
        notifCenter.delegate = delegate
    }
    
    func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void) {
        notifCenter.getNotificationSettings(completionHandler: completionHandler)
    }
    
    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void) {
        notifCenter.getPendingNotificationRequests(completionHandler: completionHandler)
    }
}
