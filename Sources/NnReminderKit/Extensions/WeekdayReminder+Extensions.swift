//
//  WeekdayReminder+Extensions.swift
//
//  Created by Nikolai Nobadi on 3/7/25.
//

import Foundation

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
