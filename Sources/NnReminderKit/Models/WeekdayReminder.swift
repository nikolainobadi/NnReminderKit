//
//  WeekdayReminder.swift
//
//  Created by Nikolai Nobadi on 3/5/25.
//

import Foundation

/// A reminder that is scheduled for a specific time on specific days of the week.
/// This is typically used for recurring reminders, such as daily or weekly notifications.
public struct WeekdayReminder: MultiTriggerReminder {
    /// Unique identifier for the reminder.
    public let id: UUID
    
    /// The title of the reminder notification.
    public let title: String
    
    /// The message/body of the reminder notification.
    public let message: String
    
    /// The subtitle of the reminder notification.
    public let subTitle: String
    
    /// Indicates whether the reminder includes a notification sound.
    public let withSound: Bool
    
    /// The specific date and time when the reminder is scheduled.
    public let time: Date
    
    /// Whether the reminder repeats (daily or weekly).
    public let repeating: Bool
    
    /// The days of the week on which the reminder should trigger.
    public let daysOfWeek: [DayOfWeek]

    /// Initializes a `WeekdayReminder` with the given properties.
    /// - Parameters:
    ///   - id: Unique identifier.
    ///   - title: Title of the reminder.
    ///   - message: Message body.
    ///   - subTitle: Subtitle (default: empty).
    ///   - withSound: Whether to include a notification sound (default: true).
    ///   - time: The scheduled time for the reminder.
    ///   - repeating: Whether the reminder repeats.
    ///   - daysOfWeek: The days of the week on which the reminder should trigger.
    public init(
        id: UUID,
        title: String,
        message: String,
        subTitle: String = "",
        withSound: Bool = true,
        time: Date,
        repeating: Bool,
        daysOfWeek: [DayOfWeek]
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.subTitle = subTitle
        self.withSound = withSound
        self.time = time
        self.repeating = repeating
        self.daysOfWeek = daysOfWeek
    }
}

// MARK: - Internal Helpers
internal extension WeekdayReminder {
    /// Extracts the hour and minute from the `time` property.
    var timeComponents: DateComponents {
        return Calendar.current.dateComponents([.hour, .minute], from: time)
    }

    /// Generates a list of `TriggerInfo` objects based on the configured days of the week.
    /// - If `daysOfWeek` is empty, a single trigger is created for the `time`.
    /// - Otherwise, multiple triggers are created for each specified day.
    var triggers: [TriggerInfo] {
        return TriggerInfoFactory.makeTriggers(for: self)
    }
}
