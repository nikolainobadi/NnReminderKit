//
//  WeekdayReminder+Extensions.swift
//
//  Created by Nikolai Nobadi on 3/7/25.
//

import Foundation
import UserNotifications

public extension WeekdayReminder {
    /// Returns the reminder's time in a human-readable format.
    ///
    /// - Format: `h:mm AM/PM`
    /// - Example: `"8:30 AM"`
    var displayableTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        return formatter.string(from: time)
    }
    
    /// A computed property that returns a human-readable string representing the selected days of the week.
    ///
    /// - If all seven days are selected, it returns `"Every Day"`.
    /// - If only Saturday and Sunday are selected, it returns `"Weekends"`.
    /// - If Monday through Friday are selected, it returns `"Weekdays"`.
    /// - Otherwise, it returns a comma-separated list of the selected days.
    var dayListText: String {
        if daysOfWeek.isEmpty || daysOfWeek.count == 7 {
            return "Every Day"
        }
        
        if daysOfWeek.count == 2, (daysOfWeek.contains(.saturday) && daysOfWeek.contains(.sunday)) {
            return "Weekends"
        }
        
        if daysOfWeek.count == 5, (!daysOfWeek.contains(.saturday) && !daysOfWeek.contains(.sunday)) {
            return "Weekdays"
        }
        
        return daysOfWeek.sorted(by: { $0.rawValue < $1.rawValue }).map({ $0.name }).joined(separator: ", ")
    }
}

// MARK: - Public Preview Sample Data
public extension WeekdayReminder {
    /// Returns a sample `CalendarReminder` for preview purposes.
    static var sample: WeekdayReminder {
        return makeSample(daysOfWeek: [.monday, .wednesday, .friday])
    }

    /// Creates a sample `WeekdayReminder` with customizable properties.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the reminder.
    ///   - title: The title of the reminder.
    ///   - message: The message/body of the reminder.
    ///   - time: The scheduled time for the reminder.
    ///   - repeating: Whether the reminder repeats.
    ///   - daysOfWeek: The days of the week the reminder should trigger.
    /// - Returns: A configured `WeekdayReminder` instance.
    static func makeSample(
        id: UUID = .init(),
        title: String = "Preview Title",
        message: String = "Preview message",
        time: Date = .init(),
        repeating: Bool = true,
        daysOfWeek: [DayOfWeek] = []
    ) -> WeekdayReminder {
        return .init(
            id: id,
            title: title,
            message: message,
            subTitle: "",
            sound: nil,
            time: time,
            repeating: repeating,
            daysOfWeek: daysOfWeek
        )
    }

    /// Returns a list of sample `WeekdayReminder` instances for preview purposes.
    static var sampleList: [WeekdayReminder] {
        return [
            makeSample(time: .createReminderTime(), daysOfWeek: [.monday, .wednesday]),
            makeSample(time: .createReminderTime(hour: 12), daysOfWeek: [.friday]),
            makeSample(time: .createReminderTime(hour: 17), daysOfWeek: [.saturday])
        ]
    }
}

// MARK: - Convenience Factory Methods
public extension WeekdayReminder {
    /// Creates a daily repeating reminder that fires every day at the specified time.
    ///
    /// This is a convenience initializer that passes an empty `daysOfWeek` array,
    /// creating a single notification that repeats daily.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the reminder.
    ///   - title: The title displayed in the notification.
    ///   - message: The main body text of the notification.
    ///   - subTitle: An optional subtitle for the notification. Defaults to an empty string.
    ///   - sound: An optional custom sound to play when the notification is delivered.
    ///   - badge: An optional number to display on the app icon.
    ///   - categoryIdentifier: A string used to categorize the notification. Defaults to an empty string.
    ///   - userInfo: A dictionary of custom key-value pairs. Defaults to an empty dictionary.
    ///   - interruptionLevel: The system-defined importance level. Defaults to `.active`.
    ///   - time: The time of day when the notification should fire.
    /// - Returns: A `WeekdayReminder` configured as a daily repeating reminder.
    static func daily(
        id: UUID = UUID(),
        title: String,
        message: String,
        subTitle: String = "",
        sound: ReminderSound? = nil,
        badge: Int? = nil,
        categoryIdentifier: String = "",
        userInfo: [String: String] = [:],
        interruptionLevel: UNNotificationInterruptionLevel = .active,
        time: Date
    ) -> WeekdayReminder {
        return WeekdayReminder(
            id: id,
            title: title,
            message: message,
            subTitle: subTitle,
            sound: sound,
            badge: badge,
            categoryIdentifier: categoryIdentifier,
            userInfo: userInfo,
            interruptionLevel: interruptionLevel,
            time: time,
            repeating: true,
            daysOfWeek: []
        )
    }

    /// Creates a one-time reminder that fires at the next occurrence of the specified time.
    ///
    /// This is a convenience initializer for non-repeating daily reminders.
    /// The notification fires once at the next occurrence of the specified time, then removes itself.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the reminder.
    ///   - title: The title displayed in the notification.
    ///   - message: The main body text of the notification.
    ///   - subTitle: An optional subtitle for the notification. Defaults to an empty string.
    ///   - sound: An optional custom sound to play when the notification is delivered.
    ///   - badge: An optional number to display on the app icon.
    ///   - categoryIdentifier: A string used to categorize the notification. Defaults to an empty string.
    ///   - userInfo: A dictionary of custom key-value pairs. Defaults to an empty dictionary.
    ///   - interruptionLevel: The system-defined importance level. Defaults to `.active`.
    ///   - time: The time of day when the notification should fire.
    /// - Returns: A `WeekdayReminder` configured as a one-time reminder.
    static func oneTime(
        id: UUID = UUID(),
        title: String,
        message: String,
        subTitle: String = "",
        sound: ReminderSound? = nil,
        badge: Int? = nil,
        categoryIdentifier: String = "",
        userInfo: [String: String] = [:],
        interruptionLevel: UNNotificationInterruptionLevel = .active,
        time: Date
    ) -> WeekdayReminder {
        return WeekdayReminder(
            id: id,
            title: title,
            message: message,
            subTitle: subTitle,
            sound: sound,
            badge: badge,
            categoryIdentifier: categoryIdentifier,
            userInfo: userInfo,
            interruptionLevel: interruptionLevel,
            time: time,
            repeating: false,
            daysOfWeek: []
        )
    }
}
