//
//  MultiTriggerReminder.swift
//  NnReminderKit
//
//  Created by Nikolai Nobadi on 4/2/25.
//

protocol MultiTriggerReminder: Reminder {
    var triggers: [TriggerInfo] { get }
}
