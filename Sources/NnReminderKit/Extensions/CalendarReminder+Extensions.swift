//
//  CalendarReminder+Extensions.swift
//
//
//  Created by Nikolai Nobadi on 3/7/25.
//

import Foundation

public extension CalendarReminder {
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
    static var sample: CalendarReminder {
        return makeSample(daysOfWeek: [.monday, .wednesday, .friday])
    }
    
    static func makeSample(id: String = "reminderId", title: String = "Preview Title", message: String = "Preview message", time: Date = .init(), repeating: Bool = true, daysOfWeek: [DayOfWeek] = []) -> CalendarReminder {
        return .init(id: id, title: title, message: message, subTitle: "", withSound: true, time: time, repeating: repeating, daysOfWeek: daysOfWeek)
    }
    
    static var sampleList: [CalendarReminder] {
        return [
            makeSample(id: "0", time: .createReminderTime(), daysOfWeek: [.monday, .wednesday]),
            makeSample(id: "1", time: .createReminderTime(hour: 12), daysOfWeek: [.friday]),
            makeSample(id: "2", time: .createReminderTime(hour: 17), daysOfWeek: [.saturday]),
        ]
    }
}
