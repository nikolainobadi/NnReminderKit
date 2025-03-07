//
//  NnReminderManager.swift
//
//
//  Created by Nikolai Nobadi on 3/5/25.
//

import UserNotifications

public final class NnReminderManager {
    private let notifCenter: NotifCenter
    
    init(notifCenter: NotifCenter) {
        self.notifCenter = notifCenter
    }
}


// MARK: - Setup
public extension NnReminderManager {
    convenience init() {
        self.init(notifCenter: NotifCenterAdapter())
    }
    
    func setNotificationDelegate(_ delegate: UNUserNotificationCenterDelegate) {
        notifCenter.setNotificationDelegate(delegate)
    }
}


// MARK: - Auth
public extension NnReminderManager {
    @discardableResult
    func requestAuthPermission(options: UNAuthorizationOptions) async -> Bool {
        return (try? await notifCenter.requestAuthorization(options: options)) ?? false
    }
    
    func checkForPermissionsWithoutRequest() async -> UNAuthorizationStatus {
        return await withCheckedContinuation { continuation in
            checkForPermissionsWithoutRequest { status in
                continuation.resume(returning: status)
            }
        }
    }
    
    func checkForPermissionsWithoutRequest(completion: @escaping (UNAuthorizationStatus) -> Void) {
        notifCenter.getAuthorizationStatus { status in
            DispatchQueue.main.async {
                completion(status)
            }
        }
    }
}


// MARK: - Countdown Reminders
public extension NnReminderManager {
    func scheduleCountdownReminder(_ reminder: CountdownReminder) async throws {
        let request = NotificationRequestFactory.makeCountdownReminderRequest(for: reminder)
        
        try await notifCenter.add(request)
    }
    
    func scheduleCountdownReminder(_ reminder: CountdownReminder, completion: ((Error?) -> Void)? = nil) {
        let request = NotificationRequestFactory.makeCountdownReminderRequest(for: reminder)
        
        notifCenter.add(request, completion: completion)
    }
}


// MARK: - Recurring Reminders
public extension NnReminderManager {
    func scheduleRecurringReminder(_ reminder: CalendarReminder) async throws {
        for request in NotificationRequestFactory.makeRecurringReminderRequests(for: reminder) {
            try await notifCenter.add(request)
        }
    }
    
    // TODO: - this may cause trouble if there are multiple errors
    func scheduleRecurringReminder(_ reminder: CalendarReminder, completion: ((Error?) -> Void)? = nil) {
        for request in NotificationRequestFactory.makeRecurringReminderRequests(for: reminder) {
            notifCenter.add(request, completion: completion)
        }
    }
}


// MARK: - Cancel
public extension NnReminderManager {
    func cancelAllNotifications() {
        notifCenter.removeAllPendingNotificationRequests()
    }
    
    func cancelRecurringReminder(_ reminder: CalendarReminder) {
        let identifiers = reminder.triggers.map({ $0.id })
        
        notifCenter.removePendingNotificationRequests(identifiers: identifiers)
    }
}


// MARK: - Load
public extension NnReminderManager {
    func loadAllPendingReminders() async -> [CalendarReminder] {
        return await withCheckedContinuation { continuation in
            loadAllPendingReminders { reminders in
                continuation.resume(returning: reminders)
            }
        }
    }
    
    func loadAllPendingReminders(completion: @escaping ([CalendarReminder]) -> Void) {
        notifCenter.getPendingNotificationRequests { requests in
            var groupedReminders: [String: (reminder: CalendarReminder, days: Set<DayOfWeek>)] = [:]
            
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
                
                let reminder = CalendarReminder(
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
                    var daysSet = Set<DayOfWeek>()
                    
                    if let day = day { daysSet.insert(day) }
                    
                    groupedReminders[baseId] = (reminder: reminder, days: daysSet)
                }
            }
            
            let reminders: [CalendarReminder] = groupedReminders.map { (baseId, tuple) in
                let reminder = tuple.reminder
                
                if !tuple.days.isEmpty {
                    return .init(
                        id: reminder.id,
                        title: reminder.title,
                        message: reminder.message,
                        subTitle: reminder.subTitle,
                        withSound: reminder.withSound,
                        time: reminder.time,
                        repeating: tuple.reminder.repeating,
                        daysOfWeek: Array(tuple.days)
                    )
                } else {
                    return reminder
                }
            }
            
            DispatchQueue.main.async {
                completion(reminders)
            }
        }
    }
}


// MARK: - Dependencies
protocol NotifCenter {
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
fileprivate extension CalendarReminder {
    var identifierList: [String] {
        if daysOfWeek.isEmpty {
            return [id]
        }
        
        return daysOfWeek.map({ "\(id)_\($0.name)" })
    }
}

extension Date {
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
