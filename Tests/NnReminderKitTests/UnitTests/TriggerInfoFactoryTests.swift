//
//  TriggerInfoFactoryTests.swift
//  NnReminderKit
//
//  Created by Nikolai Nobadi on 4/2/25.
//

import Testing
import Foundation
@testable import NnReminderKit

struct TriggerInfoFactoryTests {
    @Test("Creates single trigger for FutureDateReminder with only primary date")
    func singleTriggerFutureDateReminder() {
        let reminder = makeFutureDateReminder(additionalDates: [])
        let triggers = TriggerInfoFactory.makeTriggers(for: reminder)
        
        #expect(triggers.count == 1)
        #expect(triggers.first?.id == "\(reminder.id)_\(reminder.primaryDate.displayableDate)_primary")
    }

    @Test("Creates multiple triggers for FutureDateReminder with additional dates")
    func multipleTriggersFutureDateReminder() {
        let additional = [
            Date.createReminderTime(hour: 14, minute: 0),
            Date.createReminderTime(hour: 18, minute: 45)
        ]
        let reminder = makeFutureDateReminder(additionalDates: additional)
        let triggers = TriggerInfoFactory.makeTriggers(for: reminder)
        
        #expect(triggers.count == 1 + additional.count)
        #expect(triggers.contains { $0.id == "\(reminder.id)_\(reminder.primaryDate.displayableDate)_primary" })
        #expect(triggers.contains { $0.id == "\(reminder.id)_\(additional[0].displayableDate)" })
        #expect(triggers.contains { $0.id == "\(reminder.id)_\(additional[1].displayableDate)" })
    }

    @Test("Creates single trigger for WeekdayReminder with no days")
    func singleTriggerWeekdayReminderEmptyDays() {
        let reminder = makeWeekdayReminder(daysOfWeek: [])
        let triggers = TriggerInfoFactory.makeTriggers(for: reminder)
        
        #expect(triggers.count == 1)
        #expect(triggers.first?.id == reminder.id)
    }

    @Test("Creates multiple triggers for WeekdayReminder with multiple days")
    func multipleTriggersWeekdayReminder() {
        let days: [DayOfWeek] = [.monday, .wednesday, .friday]
        let reminder = makeWeekdayReminder(daysOfWeek: days)
        let triggers = TriggerInfoFactory.makeTriggers(for: reminder)
        
        #expect(triggers.count == days.count)
        for day in days {
            #expect(triggers.contains { $0.id == "\(reminder.id)_\(day.name)" })
        }
    }
}
