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

    /// Initializes a `CountdownReminder` with the given properties.
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
