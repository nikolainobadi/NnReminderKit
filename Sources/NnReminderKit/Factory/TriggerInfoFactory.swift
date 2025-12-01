//
//  TriggerInfoFactory.swift
//  NnReminderKit
//
//  Created by Nikolai Nobadi on 4/2/25.
//

import Foundation

enum TriggerInfoFactory {
    static func makeTriggers(for reminder: FutureDateReminder) -> [TriggerInfo] {
        var results: [TriggerInfo] = []

        let primary = TriggerInfo(
            id: "\(reminder.id)_\(reminder.primaryDate.displayableDate)_primary",
            components: reminder.primaryDate.dateComponents,
            repeating: false
        )
        results.append(primary)

        for date in reminder.additionalDates {
            let trigger = TriggerInfo(
                id: "\(reminder.id)_\(date.displayableDate)",
                components: date.dateComponents,
                repeating: false
            )
            results.append(trigger)
        }

        return results
    }

    static func makeTriggers(for reminder: WeekdayReminder) -> [TriggerInfo] {
        let baseId = reminder.id.uuidString
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: reminder.time)

        if reminder.daysOfWeek.isEmpty {
            return [
                TriggerInfo(id: baseId, components: timeComponents, repeating: reminder.repeating)
            ]
        }

        return reminder.daysOfWeek.map { day in
            var components = timeComponents
            components.weekday = day.rawValue

            return TriggerInfo(
                id: "\(baseId)_\(day.name)",
                components: components,
                repeating: true
            )
        }
    }
}


// MARK: - Extension Dependencies
extension Date {
    var dateComponents: DateComponents {
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self)
    }
    
    var displayableDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: self)
    }
}
