//
//  TestModelFactory.swift
//  NnReminderKit
//
//  Created by Nikolai Nobadi on 4/2/25.
//

import Foundation
@testable import NnReminderKit

func makeFutureDateReminder(id: UUID = .init(), additionalDates: [Date]) -> FutureDateReminder {
    return .init(id: id, title: "Title", message: "Message", subTitle: "", withSound: true, primaryDate: Date.createReminderTime(hour: 9, minute: 0), additionalDates: additionalDates)
}

func makeCountdownReminder(id: UUID = .init(), title: String = "Reminder", message: String = "test message", repeating: Bool = false, timeInterval: TimeInterval = 3600) -> CountdownReminder {
    return .init(id: id, title: title, message: message, repeating: repeating, timeInterval: timeInterval)
}

func makeWeekdayReminder(id: UUID = .init(), title: String = "Reminder", message: String = "test message", hour: Int = 8, minute: Int = 30, repeating: Bool = true, daysOfWeek: [DayOfWeek] = []) -> WeekdayReminder {
    return .init(id: id, title: title, message: message, time: .createReminderTime(hour: hour, minute: minute), repeating: repeating, daysOfWeek: daysOfWeek)
}
