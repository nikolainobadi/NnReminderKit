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
    @Test
    func `Creates single trigger for FutureDateReminder with only primary date`() throws {
        let sut = makeSUT()
        let reminder = makeFutureDateReminder(additionalDates: [])
        let triggers = sut.makeTriggers(for: reminder)
        let trigger = try #require(triggers.first)

        #expect(triggers.count == 1)
        #expect(trigger.id == "\(reminder.id)_\(reminder.primaryDate.displayableDate)_primary")
    }

    @Test
    func `Creates multiple triggers for FutureDateReminder with additional dates`() {
        let sut = makeSUT()
        let additional = [
            Date.createReminderTime(hour: 14, minute: 0),
            Date.createReminderTime(hour: 18, minute: 45)
        ]
        let reminder = makeFutureDateReminder(additionalDates: additional)
        let triggers = sut.makeTriggers(for: reminder)
        
        #expect(triggers.count == 1 + additional.count)
        #expect(triggers.contains { $0.id == "\(reminder.id)_\(reminder.primaryDate.displayableDate)_primary" })
        #expect(triggers.contains { $0.id == "\(reminder.id)_\(additional[0].displayableDate)" })
        #expect(triggers.contains { $0.id == "\(reminder.id)_\(additional[1].displayableDate)" })
    }

    @Test
    func `Creates single trigger for WeekdayReminder with no days`() throws {
        let sut = makeSUT()
        let reminder = makeWeekdayReminder(daysOfWeek: [])
        let triggers = sut.makeTriggers(for: reminder)
        let trigger = try #require(triggers.first)

        #expect(triggers.count == 1)
        #expect(trigger.id == reminder.id.uuidString)
    }

    @Test
    func `Creates multiple triggers for WeekdayReminder with multiple days`() {
        let sut = makeSUT()
        let days: [DayOfWeek] = [.monday, .wednesday, .friday]
        let reminder = makeWeekdayReminder(daysOfWeek: days)
        let triggers = sut.makeTriggers(for: reminder)
        
        #expect(triggers.count == days.count)
        for day in days {
            #expect(triggers.contains { $0.id == "\(reminder.id)_\(day.name)" })
        }
    }
}


// MARK: - SUT
private extension TriggerInfoFactoryTests {
    func makeSUT() -> TriggerInfoFactory.Type {
        return TriggerInfoFactory.self
    }
}
