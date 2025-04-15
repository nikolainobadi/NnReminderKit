//
//  ReminderSound.swift
//  NnReminderKit
//
//  Created by Nikolai Nobadi on 4/5/25.
//

public enum ReminderSound: Sendable {
    case `default`
    case critical
    case custom(name: String)
}
