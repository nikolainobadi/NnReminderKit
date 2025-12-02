//
//  WeekdayReminder.swift
//
//  Created by Nikolai Nobadi on 3/5/25.
//

import Foundation
import UserNotifications

/// A reminder that is scheduled for a specific time on specific days of the week.
///
/// For recurring reminders on specific weekdays, provide an array of `DayOfWeek` values.
/// For **daily reminders** (every day at the same time), pass an empty array to `daysOfWeek`.
///
/// ## Examples
///
/// ### Weekday Reminder (Monday, Wednesday, Friday at 9:00 AM)
/// ```swift
/// WeekdayReminder(
///     id: UUID(),
///     title: "Workout",
///     message: "Time for exercise",
///     time: nineAM,
///     repeating: true,
///     daysOfWeek: [.monday, .wednesday, .friday]
/// )
/// ```
///
/// ### Daily Reminder (Every day at 9:00 AM)
/// ```swift
/// WeekdayReminder(
///     id: UUID(),
///     title: "Daily Standup",
///     message: "Team meeting time",
///     time: nineAM,
///     repeating: true,
///     daysOfWeek: []  // Empty array = daily reminder
/// )
/// ```
///
/// ### One-Time Reminder (Next occurrence of 9:00 AM)
/// ```swift
/// WeekdayReminder(
///     id: UUID(),
///     title: "One-time alert",
///     message: "This fires once",
///     time: nineAM,
///     repeating: false,
///     daysOfWeek: []  // Fires at next 9:00 AM, then removes itself
/// )
/// ```
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

    /// The days of the week when this reminder should trigger.
    ///
    /// - For specific weekdays: Provide an array like `[.monday, .wednesday, .friday]`
    /// - For daily reminders: Pass an empty array `[]`
    /// - Each specified day creates a separate recurring notification
    /// - An empty array creates a single daily recurring notification
    public let daysOfWeek: [DayOfWeek]

    /// Initializes a `WeekdayReminder` with the given properties.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the reminder.
    ///   - title: The title displayed in the notification.
    ///   - message: The main body text of the notification.
    ///   - subTitle: An optional subtitle for the notification. Defaults to an empty string.
    ///   - sound: An optional custom sound to play when the notification is delivered. Defaults to `.default`.
    ///   - badge: An optional number to display on the app icon.
    ///   - categoryIdentifier: A string used to categorize the notification for custom actions. Defaults to an empty string.
    ///   - userInfo: A dictionary of custom key-value pairs to include with the notification payload. Defaults to an empty dictionary.
    ///   - interruptionLevel: The system-defined importance level of the notification. Defaults to `.active`.
    ///   - time: The time of day when the notification should fire.
    ///   - repeating: Whether the reminder repeats after firing. Defaults to `true`.
    ///   - daysOfWeek: The specific days on which the reminder should repeat.
    public init(
        id: UUID,
        title: String,
        message: String,
        subTitle: String = "",
        sound: ReminderSound? = .default,
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
