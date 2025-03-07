//
//  CalendarReminder+Extensions.swift
//
//  Created by Nikolai Nobadi on 3/7/25.
//

import Foundation

public extension CalendarReminder {
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
}

// MARK: - Public Preview Sample Data
public extension CalendarReminder {
    /// Returns a sample `CalendarReminder` for preview purposes.
    static var sample: CalendarReminder {
        return makeSample(daysOfWeek: [.monday, .wednesday, .friday])
    }

    /// Creates a sample `CalendarReminder` with customizable properties.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the reminder.
    ///   - title: The title of the reminder.
    ///   - message: The message/body of the reminder.
    ///   - time: The scheduled time for the reminder.
    ///   - repeating: Whether the reminder repeats.
    ///   - daysOfWeek: The days of the week the reminder should trigger.
    /// - Returns: A configured `CalendarReminder` instance.
    static func makeSample(
        id: String = "reminderId",
        title: String = "Preview Title",
        message: String = "Preview message",
        time: Date = .init(),
        repeating: Bool = true,
        daysOfWeek: [DayOfWeek] = []
    ) -> CalendarReminder {
        return .init(
            id: id,
            title: title,
            message: message,
            subTitle: "",
            withSound: true,
            time: time,
            repeating: repeating,
            daysOfWeek: daysOfWeek
        )
    }

    /// Returns a list of sample `CalendarReminder` instances for preview purposes.
    static var sampleList: [CalendarReminder] {
        return [
            makeSample(id: "0", time: .createReminderTime(), daysOfWeek: [.monday, .wednesday]),
            makeSample(id: "1", time: .createReminderTime(hour: 12), daysOfWeek: [.friday]),
            makeSample(id: "2", time: .createReminderTime(hour: 17), daysOfWeek: [.saturday])
        ]
    }
}
