//
//  CalendarReminder.swift
//
//
//  Created by Nikolai Nobadi on 3/5/25.
//

import Foundation

public struct CalendarReminder: Reminder {
    public let id: String
    public let title: String
    public let message: String
    public let subTitle: String
    public let withSound: Bool
    public let time: Date
    public let repeating: Bool
    public let daysOfWeek: [DayOfWeek]
    
    public init(id: String, title: String, message: String, subTitle: String = "", withSound: Bool = true, time: Date, repeating: Bool, daysOfWeek: [DayOfWeek]) {
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
internal extension CalendarReminder {
    var timeComponents: DateComponents {
        return Calendar.current.dateComponents([.hour, .minute], from: time)
    }
    
    var triggers: [TriggerInfo] {
        if daysOfWeek.isEmpty {
            return [.init(id: id, components: timeComponents)]
        }
        
        return daysOfWeek.map { day in
            var components = timeComponents
            components.weekday = day.rawValue
            
            return .init(id: "\(id)_\(day.name)", components: components)
        }
    }
}
