//
//  RecurringReminder.swift
//
//
//  Created by Nikolai Nobadi on 3/5/25.
//

import Foundation

public protocol RecurringReminder: Reminder {
    var time: ReminderTime { get }
    var recurringType: RecurringType { get }
}


// MARK: - Dependencies
public enum RecurringType {
    case daily, weekly([DayOfWeek])
}

public enum ReminderTime {
    case date(Date)
    case hourAndMinute(HourAndMinute)
}

public enum DayOfWeek: Int, CaseIterable, Identifiable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    
    public var id: Int { rawValue }
    
    public var name: String {
        return DateFormatter().weekdaySymbols[rawValue - 1]
    }
}

public struct HourAndMinute {
    public let hour: Int
    public let minute: Int
    
    public init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
}

