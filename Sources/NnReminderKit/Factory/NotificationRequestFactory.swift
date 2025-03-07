//
//  NotificationRequestFactory.swift
//
//
//  Created by Nikolai Nobadi on 3/6/25.
//

import Foundation
import UserNotifications

enum NotificationRequestFactory {
    static func makeCountdownReminderRequest(for reminder: CountdownReminder) -> UNNotificationRequest {
        let content = makeContent(for: reminder)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: reminder.timeInterval, repeats: reminder.repeating)
        
        return .init(identifier: reminder.id, content: content, trigger: trigger)
    }
    
    static func makeRecurringReminderRequests(for reminder: RecurringReminder) -> [UNNotificationRequest] {
        let content = makeContent(for: reminder)
        
        return reminder.triggers.map {
            .init(identifier: $0.id, content: content, trigger: makeRecurruringTrigger($0))
        }
    }
}

// MARK: - Private Methods
private extension NotificationRequestFactory {
    static func makeRecurruringTrigger(_ info: TriggerInfo) -> UNCalendarNotificationTrigger {
        return .init(dateMatching: info.components, repeats: true)
    }
    
    static func makeContent(for reminder: Reminder) -> UNMutableNotificationContent {
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
