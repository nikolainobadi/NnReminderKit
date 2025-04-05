//
//  NotificationRequestFactory.swift
//
//  Created by Nikolai Nobadi on 3/6/25.
//

import Foundation
import UserNotifications

/// A factory responsible for creating `UNNotificationRequest` objects for different reminder types.
enum NotificationRequestFactory {
    /// Creates a notification request for a `CountdownReminder`.
    /// - Parameter reminder: The `CountdownReminder` containing title, message, and time interval.
    /// - Returns: A `UNNotificationRequest` configured for a countdown-based notification.
    static func makeCountdownReminderRequest(for reminder: CountdownReminder) -> UNNotificationRequest {
        let content = makeContent(for: reminder)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: reminder.timeInterval, repeats: reminder.repeating)
        
        return .init(identifier: reminder.id.uuidString, content: content, trigger: trigger)
    }

    /// Creates a list of notification requests for a `MultiTriggerReminders`.
    /// - Parameter reminder: The `MultiTriggerReminder` containing title, message, scheduled time, and repeat settings.
    /// - Returns: An array of `UNNotificationRequest` objects, one for each scheduled trigger.
    static func makeMultiTriggerReminderRequests(for reminder: any MultiTriggerReminder) -> [UNNotificationRequest] {
        let content = makeContent(for: reminder)

        return reminder.triggers.map {
            .init(identifier: $0.id, content: content, trigger: makeRecurringTrigger($0))
        }
    }
}


// MARK: - Private Methods
private extension NotificationRequestFactory {
    /// Creates a `UNCalendarNotificationTrigger` for a `WeekdayReminder`.
    /// - Parameter info: The `TriggerInfo` containing date components for the scheduled reminder.
    /// - Returns: A `UNCalendarNotificationTrigger` configured for the specified date components.
    static func makeRecurringTrigger(_ info: TriggerInfo) -> UNCalendarNotificationTrigger {
        return .init(dateMatching: info.components, repeats: true)
    }

    /// Creates a `UNMutableNotificationContent` from a `Reminder`.
    /// - Parameter reminder: A reminder object (`CountdownReminder` or `WeekdayReminder`).
    /// - Returns: A configured `UNMutableNotificationContent` with title, message, subtitle, and sound settings.
    static func makeContent(for reminder: any Reminder) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.message
        content.subtitle = reminder.subTitle
        content.userInfo = reminder.userInfo
        content.interruptionLevel = reminder.interruptionLevel
        content.categoryIdentifier = reminder.categoryIdentifier
        
        if let badge = reminder.badge {
            content.badge = .init(integerLiteral: badge)
        }

        if let sound = reminder.sound, let notificationSound = sound.asUNNotificationSound() {
            content.sound = notificationSound
        }

        return content
    }
}


// MARK: - Extension Dependencies
fileprivate extension ReminderSound {
    func asUNNotificationSound() -> UNNotificationSound? {
        switch self {
        case .none:
            return nil
        case .default:
            return .default
        case .critical:
            return .defaultCritical
        case .custom(let name):
            return UNNotificationSound(named: UNNotificationSoundName(name))
        }
    }
}
