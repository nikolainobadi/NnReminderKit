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
        let content = makeContent(for: reminder)
        
        for triggerInfo in reminder.triggers {
            let trigger = makeRecurruringTrigger(triggerInfo)
            
            scheduleNotification(id: triggerInfo.id, content: content, trigger: trigger)
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
    func loadPendingReminders<R: RecurringReminderInitializable>() async -> [R] {
        return await withCheckedContinuation { continuation in
            loadPendingReminders { reminders in
                continuation.resume(returning: reminders)
            }
        }
    }
    
    func loadPendingReminders<R: RecurringReminderInitializable>(completion: @escaping ([R]) -> Void) {
        notifCenter.getPendingNotificationRequests { requests in
            var groupedReminders: [String: (reminder: DefaultRecurringReminder, days: Set<DayOfWeek>)] = [:]
            
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
                
                let reminder = DefaultRecurringReminder(
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
            
            let reminders: [DefaultRecurringReminder] = groupedReminders.map { (baseId, tuple) in
                let reminder = tuple.reminder
                
                if !tuple.days.isEmpty {
                    return DefaultRecurringReminder(
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
                completion(reminders.map { R.init($0) })
            }
        }
    }
}


// MARK: - Private Methods
private extension NnReminderManager {
    func makeRecurruringTrigger(_ info: TriggerInfo) -> UNCalendarNotificationTrigger {
        return .init(dateMatching: info.components, repeats: true)
    }
    
    func scheduleNotification(id: String, content: UNMutableNotificationContent, trigger: UNNotificationTrigger) {
        notifCenter.add(.init(identifier: id, content: content, trigger: trigger))
    }
    
    func makeContent(for reminder: Reminder) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.message
        content.subtitle = reminder.subTitle
        
        if reminder.withSound {
            content.sound = .default
        }
        
        return content
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
fileprivate extension ReminderTime {
    var timeComponents: DateComponents {
        switch self {
        case .date(let date):
            return Calendar.current.dateComponents([.hour, .minute], from: date)
        case .hourAndMinute(let hourAndMinute):
            return .init(hour: hourAndMinute.hour, minute: hourAndMinute.minute)
        }
    }
}

fileprivate extension RecurringReminder {
    var identifierList: [String] {
        switch recurringType {
        case .daily:
            return [id]
        case .weekly(let daysOfWeek):
            return daysOfWeek.map({ "\(id)_\($0.name)" })
        }
    }
    
    var triggers: [TriggerInfo] {
        switch recurringType {
        case .daily:
            return [.init(id: id, components: time.timeComponents)]
        case .weekly(let daysOfWeek):
            return daysOfWeek.map { day in
                var components = time.timeComponents
                components.weekday = day.rawValue
                
                return .init(id: "\(id)_\(day.name)", components: components)
            }
        }
    }
}
