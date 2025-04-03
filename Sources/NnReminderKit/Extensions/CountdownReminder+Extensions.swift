//
//  CountdownReminder+Extensions.swift
//
//  Created by Nikolai Nobadi on 3/7/25.
//

import Foundation

public extension CountdownReminder {
    /// Returns a sample `CountdownReminder` for preview purposes.
    static var sample: CountdownReminder {
        return makeSample()
    }

    /// Creates a sample `CountdownReminder` with customizable properties.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the reminder.
    ///   - title: The title of the reminder.
    ///   - message: The message/body of the reminder.
    ///   - repeating: Whether the reminder repeats.
    ///   - timeInterval: The countdown duration in seconds.
    /// - Returns: A configured `CountdownReminder` instance.
    static func makeSample(
        id: UUID = .init(),
        title: String = "One-Time Reminder",
        message: String = "This is a sample one-time reminder",
        repeating: Bool = false,
        timeInterval: TimeInterval = 3600
    ) -> CountdownReminder {
        return .init(
            id: id,
            title: title,
            message: message,
            repeating: repeating,
            timeInterval: timeInterval
        )
    }

    /// Returns a list of sample `CountdownReminder` instances for preview purposes.
    static var sampleList: [CountdownReminder] {
        return [
            makeSample(title: "Take Medicine", timeInterval: 3600),
            makeSample(title: "Meeting in an Hour", timeInterval: 1800),
            makeSample(title: "Workout Reminder", repeating: true, timeInterval: 7200)
        ]
    }
}
