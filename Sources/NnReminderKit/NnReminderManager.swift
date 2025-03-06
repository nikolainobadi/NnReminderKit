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


// MARK: - Recurring Reminders
public extension NnReminderManager {
    func scheduleRecurringReminder(_ reminder: RecurringReminder) {
        for request in NotificationRequestFactory.makeRecurringReminderRequests(for: reminder) {
            notifCenter.add(request)
        }
    }
}


// MARK: - Cancel
public extension NnReminderManager {
    func cancelAllNotifications() {
        notifCenter.removeAllPendingNotificationRequests()
    }
    
    func cancelRecurringReminder(_ reminder: RecurringReminder) {
        let identifiers = reminder.triggers.map({ $0.id })
        
        notifCenter.removePendingNotificationRequests(identifiers: identifiers)
    }
}


// MARK: - Load
public extension NnReminderManager {
    func loadAllPendingReminders() async -> [RecurringReminder] {
        return await withCheckedContinuation { continuation in
            loadAllPendingReminders { reminders in
                continuation.resume(returning: reminders)
            }
        }
    }
    
    func loadAllPendingReminders(completion: @escaping ([RecurringReminder]) -> Void) {
        notifCenter.getPendingNotificationRequests { requests in
            var groupedReminders: [String: (reminder: RecurringReminder, days: Set<DayOfWeek>)] = [:]
            
            for request in requests {
                guard
                    let trigger = request.trigger as? UNCalendarNotificationTrigger,
                    let hour = trigger.dateComponents.hour,
                    let minute = trigger.dateComponents.minute
                else {
                    continue
                }
                
                let idComponents = request.identifier.split(separator: "_")
                
                guard let baseId = idComponents.first.map(String.init) else {
                    continue
                }
                
                var day: DayOfWeek? = nil
                
                if idComponents.count > 1, let dayName = idComponents.last {
                    day = DayOfWeek.allCases.first(where: { $0.name == dayName })
                }
                
                let time = ReminderTime.hourAndMinute(HourAndMinute(hour: hour, minute: minute))
                let recurringType: RecurringType = day == nil ? .daily : .weekly([])
                
                let reminder = RecurringReminder(
                    id: baseId,
                    title: request.content.title,
                    message: request.content.body,
                    subTitle: request.content.subtitle,
                    withSound: request.content.sound != nil,
                    time: time,
                    recurringType: recurringType
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
            
            let reminders: [RecurringReminder] = groupedReminders.map { (baseId, tuple) in
                let reminder = tuple.reminder
                
                if !tuple.days.isEmpty {
                    return .init(
                        id: reminder.id,
                        title: reminder.title,
                        message: reminder.message,
                        subTitle: reminder.subTitle,
                        withSound: reminder.withSound,
                        time: reminder.time,
                        recurringType: .weekly(Array(tuple.days))
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
    func add(_ request: UNNotificationRequest)
    func removeAllPendingNotificationRequests()
    func removePendingNotificationRequests(identifiers: [String])
    func setNotificationDelegate(_ delegate: UNUserNotificationCenterDelegate)
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func getAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void)
    func getPendingNotificationRequests(completion: @escaping ([UNNotificationRequest]) -> Void)
}


// MARK: - Extension Dependencies
fileprivate extension RecurringReminder {
    var identifierList: [String] {
        switch recurringType {
        case .daily:
            return [id]
        case .weekly(let daysOfWeek):
            return daysOfWeek.map({ "\(id)_\($0.name)" })
        }
    }
}
