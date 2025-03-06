//
//  RecurringReminder.swift
//
//
//  Created by Nikolai Nobadi on 3/5/25.
//

import Foundation

public struct RecurringReminder: Reminder {
    public let id: String
    public let title: String
    public let message: String
    public let subTitle: String
    public let withSound: Bool
    public let time: Date
    public let recurringType: RecurringType
    
    public init(id: String, title: String, message: String, subTitle: String = "", withSound: Bool = true, time: Date, recurringType: RecurringType) {
        self.id = id
        self.title = title
        self.message = message
        self.subTitle = subTitle
        self.withSound = withSound
        self.time = time
        self.recurringType = recurringType
    }
}


// MARK: - Dependencies
public enum RecurringType {
    case daily, weekly([DayOfWeek])
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


// MARK: - Helpers
extension RecurringReminder {
    var timeComponents: DateComponents {
        return Calendar.current.dateComponents([.hour, .minute], from: time)
    }
    
    var triggers: [TriggerInfo] {
        switch recurringType {
        case .daily:
            return [.init(id: id, components: timeComponents)]
        case .weekly(let daysOfWeek):
            return daysOfWeek.map { day in
                var components = timeComponents
                components.weekday = day.rawValue
                
                return .init(id: "\(id)_\(day.name)", components: components)
            }
        }
    }
}
