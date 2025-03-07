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
    func add(_ request: UNNotificationRequest) async throws {
        try await notifCenter.add(request)
    }
    
    func add(_ request: UNNotificationRequest, completion: ((Error?) -> Void)?) {
        notifCenter.add(request, withCompletionHandler: completion)
    }
    
    func removeAllPendingNotificationRequests() {
        notifCenter.removeAllPendingNotificationRequests()
    }
    
    func removePendingNotificationRequests(identifiers: [String]) {
        notifCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        return try await notifCenter.requestAuthorization(options: options)
    }
    
    func setNotificationDelegate(_ delegate: UNUserNotificationCenterDelegate) {
        notifCenter.delegate = delegate
    }
    
    func getAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        notifCenter.getNotificationSettings {
            completion($0.authorizationStatus)
        }
    }
    
    func getPendingNotificationRequests(completion: @escaping ([UNNotificationRequest]) -> Void) {
        notifCenter.getPendingNotificationRequests(completionHandler: completion)
    }
}
