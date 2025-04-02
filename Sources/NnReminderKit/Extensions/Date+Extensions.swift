//
//  Date+Extensions.swift
//
//  Created by Nikolai Nobadi on 3/7/25.
//

import Foundation

public extension Date {
    /// Creates a `Date` object for a specific time on the current day.
    ///
    /// - Parameters:
    ///   - hour: The hour component (default: `8`).
    ///   - minute: The minute component (default: `0`).
    ///   - date: The reference date (default: `Date()`).
    /// - Returns: A `Date` object with the specified time.
    static func createReminderTime(hour: Int = 8, minute: Int = 0, date: Date = .init()) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? date
    }
    
    func addingDays(_ days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
}
