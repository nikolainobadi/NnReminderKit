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
        
        return .init(identifier: reminder.id, content: content, trigger: trigger)
    }

    /// Creates a list of notification requests for a `CalendarReminder`.
    /// - Parameter reminder: The `CalendarReminder` containing title, message, scheduled time, and repeat settings.
    /// - Returns: An array of `UNNotificationRequest` objects, one for each scheduled trigger.
    static func makeRecurringReminderRequests(for reminder: CalendarReminder) -> [UNNotificationRequest] {
        let content = makeContent(for: reminder)

        return reminder.triggers.map {
            .init(identifier: $0.id, content: content, trigger: makeRecurringTrigger($0))
        }
    }
}

// MARK: - Private Methods
private extension NotificationRequestFactory {
    /// Creates a `UNCalendarNotificationTrigger` for a `CalendarReminder`.
    /// - Parameter info: The `TriggerInfo` containing date components for the scheduled reminder.
    /// - Returns: A `UNCalendarNotificationTrigger` configured for the specified date components.
    static func makeRecurringTrigger(_ info: TriggerInfo) -> UNCalendarNotificationTrigger {
        return .init(dateMatching: info.components, repeats: true)
    }

    /// Creates a `UNMutableNotificationContent` from a `Reminder`.
    /// - Parameter reminder: A reminder object (`CountdownReminder` or `CalendarReminder`).
    /// - Returns: A configured `UNMutableNotificationContent` with title, message, subtitle, and sound settings.
    static func makeContent(for reminder: any Reminder) -> UNMutableNotificationContent {
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
