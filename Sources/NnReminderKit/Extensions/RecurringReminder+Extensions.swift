//
//  RecurringReminder+Extensions.swift
//
//
//  Created by Nikolai Nobadi on 3/7/25.
//

import Foundation

public extension RecurringReminder {
    var displayableTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        return formatter.string(from: time)
    }
}


// MARK: - Public Preview Sample Data
public extension RecurringReminder {
    static var sample: RecurringReminder {
        return makeSample(recurringType: .weekly([.monday, .wednesday, .friday]))
    }
    
    static func makeSample(id: String = "reminderId", title: String = "Preview Title", message: String = "Preview message", time: Date = .init(), recurringType: RecurringType = .daily) -> RecurringReminder {
        return .init(id: id, title: title, message: message, subTitle: "", withSound: true, time: time, recurringType: recurringType)
    }
    
    static var sampleList: [RecurringReminder] {
        return [
            makeSample(id: "0", time: .createReminderTime(), recurringType: .weekly([.monday, .wednesday])),
            makeSample(id: "1", time: .createReminderTime(hour: 12), recurringType: .weekly([.friday])),
            makeSample(id: "2", time: .createReminderTime(hour: 17), recurringType: .weekly([.saturday])),
        ]
    }
}
