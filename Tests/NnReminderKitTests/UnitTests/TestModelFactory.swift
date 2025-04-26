//
//  TestModelFactory.swift
//  NnReminderKit
//
//  Created by Nikolai Nobadi on 4/2/25.
//

import Foundation
@testable import NnReminderKit

func makeFutureDateReminder(id: UUID = .init(), primaryDate: Date = Date.createReminderTime(hour: 9, minute: 0), additionalDates: [Date] = []) -> FutureDateReminder {
    return .init(id: id, title: "Title", message: "Message", subTitle: "", sound: nil, badge: nil, categoryIdentifier: "", userInfo: [:], interruptionLevel: .active, primaryDate: primaryDate, additionalDates: additionalDates)
}

func makeCountdownReminder(id: UUID = .init(), title: String = "Reminder", message: String = "test message", repeating: Bool = false, timeInterval: TimeInterval = 3600) -> CountdownReminder {
    return .init(id: id, title: title, message: message, repeating: repeating, timeInterval: timeInterval)
}

func makeWeekdayReminder(id: UUID = .init(), title: String = "Reminder", message: String = "test message", hour: Int = 8, minute: Int = 30, repeating: Bool = true, daysOfWeek: [DayOfWeek] = []) -> WeekdayReminder {
    return .init(id: id, title: title, message: message, time: .createReminderTime(hour: hour, minute: minute), repeating: repeating, daysOfWeek: daysOfWeek)
}

func makeLocationReminder(id: UUID = UUID()) -> LocationReminder {
    LocationReminder(id: id, title: "Store Visit", message: "Don't forget to buy milk!", subTitle: "", sound: .default, badge: nil, categoryIdentifier: "", userInfo: [:], interruptionLevel: .active, locationRegion: .init(latitude: 37.7749, longitude: -122.4194, radius: 100), repeats: false
    )
}
