//
//  NnReminderManager.swift
//
//
//  Created by Nikolai Nobadi on 3/5/25.
//

import UserNotifications

/// Manages scheduling, canceling, and retrieving reminders using `UserNotifications`.
public actor NnReminderManager {
    /// Notification center dependency for handling notifications.
    private let notifCenter: NotifCenter
    
    /// Initializes `NnReminderManager` with a custom notification center.
    ///
    /// - Parameter notifCenter: An object conforming to `NotifCenter` to handle notification operations.
    init(notifCenter: NotifCenter) {
        self.notifCenter = notifCenter
    }
}


// MARK: - Setup
public extension NnReminderManager {
    /// Default initializer using `NotifCenterAdapter` for interacting with `UserNotifications`.
    init() {
        self.init(notifCenter: NotifCenterAdapter())
    }
    
    /// Sets the delegate for handling notification interactions.
    ///
    /// - Parameter delegate: The object conforming to `UNUserNotificationCenterDelegate` that will handle notification-related events.
    func setNotificationDelegate(_ delegate: UNUserNotificationCenterDelegate) {
        notifCenter.setNotificationDelegate(delegate)
    }
}


// MARK: - Auth
public extension NnReminderManager {
    /// Requests notification authorization from the user.
    ///
    /// - Parameter options: The notification options, such as `.alert`, `.badge`, and `.sound`.
    /// - Returns: `true` if authorization is granted, otherwise `false`.
    @discardableResult
    func requestAuthPermission(options: UNAuthorizationOptions) async -> Bool {
        return (try? await notifCenter.requestAuthorization(options: options)) ?? false
    }
    
    /// Checks the current notification authorization status asynchronously.
    ///
    /// - Returns: The current `UNAuthorizationStatus`.
    func checkForPermissionsWithoutRequest() async -> UNAuthorizationStatus {
        return await withCheckedContinuation { continuation in
            checkForPermissionsWithoutRequest { status in
                continuation.resume(returning: status)
            }
        }
    }
    
    /// Checks the current notification authorization status.
    ///
    /// - Parameter completion: A closure receiving the current `UNAuthorizationStatus`.
    func checkForPermissionsWithoutRequest(completion: @escaping (UNAuthorizationStatus) -> Void) {
        notifCenter.getAuthorizationStatus { status in
            completion(status)
        }
    }
}

// MARK: - Cancel
public extension NnReminderManager {
    /// Cancels all scheduled reminders.
    func cancelAllReminders() {
        notifCenter.removeAllPendingNotificationRequests()
    }
}


// MARK: - CountdownReminder
public extension NnReminderManager {
    /// Schedules a countdown reminder asynchronously.
    ///
    /// - Parameter reminder: The `CountdownReminder` to schedule.
    /// - Throws: An error if scheduling fails.
    func scheduleCountdownReminder(_ reminder: CountdownReminder) async throws {
        let request = NotificationRequestFactory.makeCountdownReminderRequest(for: reminder)
        try await notifCenter.add(request)
    }
    
    /// Schedules a countdown reminder with a completion handler.
    ///
    /// - Parameters:
    ///   - reminder: The `CountdownReminder` to schedule.
    ///   - completion: A closure receiving an optional error if scheduling fails.
    func scheduleCountdownReminder(_ reminder: CountdownReminder, completion: ((Error?) -> Void)? = nil) {
        let request = NotificationRequestFactory.makeCountdownReminderRequest(for: reminder)
        notifCenter.add(request, completion: completion)
    }
    
    /// Cancels a specific countdown reminder.
    ///
    /// - Parameter reminder: The `CountdownReminder` to cancel.
    func cancelCountdownReminder(_ reminder: CountdownReminder) {
        notifCenter.removePendingNotificationRequests(identifiers: [reminder.id])
    }
    
    /// Loads all pending countdown reminders asynchronously.
    ///
    /// - Returns: An array of `CountdownReminder` objects.
    func loadAllCountdownReminders() async -> [CountdownReminder] {
        return await withCheckedContinuation { continuation in
            loadAllCountdownReminders { reminders in
                continuation.resume(returning: reminders)
            }
        }
    }
    
    /// Loads all pending countdown reminders.
    ///
    /// - Parameter completion: A closure receiving an array of `CountdownReminder` objects.
    func loadAllCountdownReminders(completion: @escaping ([CountdownReminder]) -> Void) {
        notifCenter.getPendingNotificationRequests { requests in
            var reminders: [CountdownReminder] = []
            
            for request in requests {
                guard let trigger = request.trigger as? UNTimeIntervalNotificationTrigger else {
                    continue
                }
                
                let reminder = CountdownReminder(
                    id: request.identifier,
                    title: request.content.title,
                    message: request.content.body,
                    repeating: trigger.repeats,
                    timeInterval: trigger.timeInterval
                )
                
                reminders.append(reminder)
            }
            
            completion(reminders)
        }
    }
}


// MARK: - WeekdayReminder
public extension NnReminderManager {
    /// Schedules a recurring calendar reminder asynchronously.
    ///
    /// - Parameter reminder: The `WeekdayReminder` to schedule.
    /// - Throws: An error if scheduling fails.
    func scheduleRecurringReminder(_ reminder: WeekdayReminder) async throws {
        try await scheduleMultiTriggerReminder(reminder)
    }
    
    /// Schedules a recurring calendar reminder with a completion handler.
    ///
    /// - Parameters:
    ///   - reminder: The `WeekdayReminder` to schedule.
    ///   - completion: A closure receiving an optional error if scheduling fails.
    func scheduleRecurringReminder(_ reminder: WeekdayReminder, completion: ((Error?) -> Void)? = nil) {
        for request in NotificationRequestFactory.makeMultiTriggerReminderRequests(for: reminder) {
            notifCenter.add(request, completion: completion)
        }
    }
    
    /// Cancels a specific calendar reminder.
    ///
    /// - Parameter reminder: The `WeekdayReminder` to cancel.
    func cancelCalendarReminder(_ reminder: WeekdayReminder) {
        cancelMultiTriggerReminder(reminder)
    }
    
    /// Loads all pending calendar reminders asynchronously.
    ///
    /// - Returns: An array of `WeekdayReminder` objects.
    func loadAllCalendarReminders() async -> [WeekdayReminder] {
        return await withCheckedContinuation { continuation in
            loadAllCalendarReminders { reminders in
                continuation.resume(returning: reminders)
            }
        }
    }
    
    /// Loads all pending calendar reminders.
    ///
    /// - Parameter completion: A closure receiving an array of `WeekdayReminder` objects.
    func loadAllCalendarReminders(completion: @escaping ([WeekdayReminder]) -> Void) {
        notifCenter.getPendingNotificationRequests { requests in
            var groupedReminders: [String: (reminder: WeekdayReminder, days: Set<DayOfWeek>)] = [:]
            
            for request in requests {
                guard let trigger = request.trigger as? UNCalendarNotificationTrigger, let time = Date.fromComponents(trigger.dateComponents) else {
                    continue
                }
                
                let repeating = trigger.repeats
                let idComponents = request.identifier.split(separator: "_")
                
                guard let baseId = idComponents.first.map(String.init) else {
                    continue
                }
                
                var day: DayOfWeek? = nil
                
                if idComponents.count > 1, let dayName = idComponents.last {
                    day = DayOfWeek.allCases.first(where: { $0.name == dayName })
                }
                
                var daysOfWeek: Set<DayOfWeek> = []
                
                if let day {
                    daysOfWeek.insert(day)
                }
                
                let reminder = WeekdayReminder(
                    id: baseId,
                    title: request.content.title,
                    message: request.content.body,
                    subTitle: request.content.subtitle,
                    withSound: request.content.sound != nil,
                    time: time,
                    repeating: repeating,
                    daysOfWeek: .init(daysOfWeek)
                )
                
                if var existing = groupedReminders[baseId] {
                    if let day = day {
                        existing.days.insert(day)
                    }
                    
                    groupedReminders[baseId] = existing
                } else {
                    groupedReminders[baseId] = (reminder, daysOfWeek)
                }
            }
            
            let reminders = groupedReminders.map { (_, tuple) in
                WeekdayReminder(
                    id: tuple.reminder.id,
                    title: tuple.reminder.title,
                    message: tuple.reminder.message,
                    subTitle: tuple.reminder.subTitle,
                    withSound: tuple.reminder.withSound,
                    time: tuple.reminder.time,
                    repeating: tuple.reminder.repeating,
                    daysOfWeek: Array(tuple.days)
                )
            }
            
            completion(reminders)
        }
    }
}


// MARK: - FutureDateReminder
public extension NnReminderManager {
    func scheduleFutureDateReminder(_ reminder: FutureDateReminder) async throws {
        try await scheduleMultiTriggerReminder(reminder)
    }
    
    func cancelFutureDateReminder(_ reminder: FutureDateReminder) {
        cancelMultiTriggerReminder(reminder)
    }
    
    func loadAllFutureDateReminders() async -> [FutureDateReminder] {
        return [] // TODO: -
    }
    
    func loadAllFutureDateReminders(completion: @escaping ([FutureDateReminder]) -> Void) {
        // TODO: - 
    }
}


// MARK: - Private Methods
private extension NnReminderManager {
    func cancelMultiTriggerReminder(_ reminder: any MultiTriggerReminder) {
        let identifiers = reminder.triggers.map({ $0.id })
        notifCenter.removePendingNotificationRequests(identifiers: identifiers)
    }
    
    func scheduleMultiTriggerReminder(_ reminder: any MultiTriggerReminder) async throws {
        for request in NotificationRequestFactory.makeMultiTriggerReminderRequests(for: reminder) {
            try await notifCenter.add(request)
        }
    }
}


// MARK: - Dependencies
/// A protocol defining interactions with the notification system.
///
/// This abstraction allows for dependency injection and testing by enabling the use of a mock notification center.
protocol NotifCenter: Sendable {
    func removeAllPendingNotificationRequests()
    func add(_ request: UNNotificationRequest) async throws
    func removePendingNotificationRequests(identifiers: [String])
    func setNotificationDelegate(_ delegate: UNUserNotificationCenterDelegate)
    func add(_ request: UNNotificationRequest, completion: ((Error?) -> Void)?)
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func getAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void)
    func getPendingNotificationRequests(completion: @escaping ([UNNotificationRequest]) -> Void)
}


// MARK: - Extension Dependencies
/// Extension for `WeekdayReminder` providing computed properties.
fileprivate extension WeekdayReminder {
    /// Generates a list of unique identifiers for the reminder.
    ///
    /// - If the reminder is not associated with specific days, it returns a single identifier.
    /// - If the reminder is recurring on multiple days, it returns an identifier for each day.
    var identifierList: [String] {
        if daysOfWeek.isEmpty {
            return [id]
        }
        
        return daysOfWeek.map({ "\(id)_\($0.name)" })
    }
}

/// Extension for `Date` providing utilities for creating `Date` objects from `DateComponents`.
fileprivate extension Date {
    /// Creates a `Date` object from the given `DateComponents`.
    ///
    /// - Uses the current year, month, and day to ensure a valid date.
    /// - Returns `nil` if the date cannot be created.
    ///
    /// - Parameter components: The `DateComponents` to convert into a `Date` object.
    /// - Returns: A `Date` object if conversion is successful, otherwise `nil`.
    static func fromComponents(_ components: DateComponents) -> Date? {
        var newComponents = components
        let now = Date()
        let calendar = Calendar.current

        // Use the current year, month, and day
        let currentComponents = calendar.dateComponents([.year, .month, .day], from: now)
        newComponents.year = currentComponents.year
        newComponents.month = currentComponents.month
        newComponents.day = currentComponents.day

        return calendar.date(from: newComponents)
    }
}
