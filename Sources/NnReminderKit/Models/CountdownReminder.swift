//
//  CountdownReminder.swift
//
//  Created by Nikolai Nobadi on 3/7/25.
//

import Foundation
import UserNotifications

/// A reminder that triggers after a set countdown duration rather than at a fixed calendar time.
public struct CountdownReminder: Reminder {
    public let id: UUID
    public let title: String
    public let message: String
    public let subTitle: String
    public let sound: ReminderSound?
    public let badge: Int?
    public let categoryIdentifier: String
    public let userInfo: [String: String]
    public let interruptionLevel: UNNotificationInterruptionLevel
    public let repeating: Bool
    public let timeInterval: TimeInterval

    /// Initializes a `CountdownReminder`, which triggers after a specified time interval rather than at a specific calendar time.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the reminder.
    ///   - title: The title displayed in the notification.
    ///   - message: The main body text of the notification.
    ///   - subTitle: An optional subtitle for the notification. Defaults to an empty string.
    ///   - sound: An optional custom sound to play when the notification is delivered.
    ///   - badge: An optional number to display on the app icon.
    ///   - categoryIdentifier: A string used to categorize the notification for custom actions. Defaults to an empty string.
    ///   - userInfo: A dictionary of custom key-value pairs to include with the notification payload. Defaults to an empty dictionary.
    ///   - interruptionLevel: The system-defined importance level of the notification. Defaults to `.active`.
    ///   - repeating: A Boolean value indicating whether the notification should repeat.
    ///   - timeInterval: The countdown duration, in seconds, after which the reminder will fire.
    public init(
        id: UUID,
        title: String,
        message: String,
        subTitle: String = "",
        sound: ReminderSound? = nil,
        badge: Int? = nil,
        categoryIdentifier: String = "",
        userInfo: [String: String] = [:],
        interruptionLevel: UNNotificationInterruptionLevel = .active,
        repeating: Bool,
        timeInterval: TimeInterval
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.subTitle = subTitle
        self.sound = sound
        self.badge = badge
        self.categoryIdentifier = categoryIdentifier
        self.userInfo = userInfo
        self.interruptionLevel = interruptionLevel
        self.repeating = repeating
        self.timeInterval = timeInterval
    }
}
