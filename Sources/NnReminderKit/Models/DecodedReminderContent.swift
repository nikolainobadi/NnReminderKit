//
//  DecodedReminderContent.swift
//  NnReminderKit
//
//  Created by Nikolai Nobadi on 4/5/25.
//

import UserNotifications

struct DecodedReminderContent: Sendable {
    let title: String
    let message: String
    let subTitle: String
    let badge: Int?
    let categoryIdentifier: String
    let interruptionLevel: UNNotificationInterruptionLevel
    let userInfo: [String: String]
    let sound: ReminderSound?
}
