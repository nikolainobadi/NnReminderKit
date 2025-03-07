import UserNotifications

/// An adapter for `UNUserNotificationCenter` that conforms to `NotifCenter`.
///
/// This class provides a wrapper around `UNUserNotificationCenter` to allow easier dependency injection and testing.
final class NotifCenterAdapter {
    /// The shared instance of `UNUserNotificationCenter`.
    private let notifCenter = UNUserNotificationCenter.current()
}

// MARK: - NotifCenter
extension NotifCenterAdapter: NotifCenter {
    /// Schedules a notification request asynchronously.
    ///
    /// - Parameter request: The `UNNotificationRequest` to be added.
    /// - Throws: An error if the notification request fails to be scheduled.
    func add(_ request: UNNotificationRequest) async throws {
        try await notifCenter.add(request)
    }
    
    /// Schedules a notification request with a completion handler.
    ///
    /// - Parameters:
    ///   - request: The `UNNotificationRequest` to be added.
    ///   - completion: A closure that receives an optional error if the operation fails.
    func add(_ request: UNNotificationRequest, completion: ((Error?) -> Void)?) {
        notifCenter.add(request, withCompletionHandler: completion)
    }
    
    /// Removes all pending notification requests.
    func removeAllPendingNotificationRequests() {
        notifCenter.removeAllPendingNotificationRequests()
    }
    
    /// Removes specific pending notification requests based on their identifiers.
    ///
    /// - Parameter identifiers: An array of notification request identifiers to be removed.
    func removePendingNotificationRequests(identifiers: [String]) {
        notifCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    /// Requests notification authorization with specified options.
    ///
    /// - Parameter options: The authorization options, such as `.alert`, `.badge`, and `.sound`.
    /// - Returns: A Boolean indicating whether permission was granted.
    /// - Throws: An error if authorization fails.
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        return try await notifCenter.requestAuthorization(options: options)
    }
    
    /// Sets the delegate for `UNUserNotificationCenter`.
    ///
    /// - Parameter delegate: The object conforming to `UNUserNotificationCenterDelegate` that will handle notification-related events.
    func setNotificationDelegate(_ delegate: UNUserNotificationCenterDelegate) {
        notifCenter.delegate = delegate
    }
    
    /// Retrieves the current notification authorization status.
    ///
    /// - Parameter completion: A closure that receives the current `UNAuthorizationStatus`.
    func getAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        notifCenter.getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }
    
    /// Fetches all pending notification requests.
    ///
    /// - Parameter completion: A closure that receives an array of `UNNotificationRequest` objects.
    func getPendingNotificationRequests(completion: @escaping ([UNNotificationRequest]) -> Void) {
        notifCenter.getPendingNotificationRequests(completionHandler: completion)
    }
}
