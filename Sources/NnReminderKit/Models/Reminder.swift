//
//  Reminder.swift
//
//  Created by Nikolai Nobadi on 3/5/25.
//

import Foundation
import UserNotifications

/// A protocol representing a general reminder with basic notification properties.
protocol Reminder: Identifiable, Sendable {
    var id: UUID { get }
    var title: String { get }
    var message: String { get }
    var subTitle: String { get }
    var sound: ReminderSound? { get }
    var badge: Int? { get }
    var categoryIdentifier: String { get }
    var userInfo: [String: String] { get }
    var interruptionLevel: UNNotificationInterruptionLevel { get }
}
