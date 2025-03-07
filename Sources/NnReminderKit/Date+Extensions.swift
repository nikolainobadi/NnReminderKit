//
//  Date+Extensions.swift
//
//
//  Created by Nikolai Nobadi on 3/7/25.
//

import Foundation

public extension Date {
    static func createReminderTime(hour: Int = 8, minute: Int = 0, date: Date = .init()) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? date
    }
}
