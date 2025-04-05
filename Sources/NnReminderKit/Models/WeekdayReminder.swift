//
//  WeekdayReminder.swift
//
//  Created by Nikolai Nobadi on 3/5/25.
//

import Foundation
import UserNotifications

/// A reminder that is scheduled for a specific time on specific days of the week.
/// This is typically used for recurring reminders, such as daily or weekly notifications.
public struct WeekdayReminder: MultiTriggerReminder {
    public let id: UUID
    public let title: String
    public let message: String
    public let subTitle: String
    public let sound: ReminderSound?
    public let badge: Int?
    public let categoryIdentifier: String
    public let userInfo: [String: String]
    public let interruptionLevel: UNNotificationInterruptionLevel
    public let time: Date
    public let repeating: Bool
    public let daysOfWeek: [DayOfWeek]

    /// Initializes a `WeekdayReminder` with the given properties.
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
        time: Date,
        repeating: Bool = true,
        daysOfWeek: [DayOfWeek]
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
        self.time = time
        self.repeating = repeating
        self.daysOfWeek = daysOfWeek
    }
}

// MARK: - Internal Helpers
internal extension WeekdayReminder {
    var timeComponents: DateComponents {
        return Calendar.current.dateComponents([.hour, .minute], from: time)
    }

    var triggers: [TriggerInfo] {
        return TriggerInfoFactory.makeTriggers(for: self)
    }
}
