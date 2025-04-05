//
//  Reminder.swift
//
//  Created by Nikolai Nobadi on 3/5/25.
//

import Foundation
import UserNotifications

/// A protocol representing a general reminder with basic notification properties.
protocol Reminder: Identifiable, Sendable {
    /// A unique identifier for the reminder.
    var id: UUID { get }
    
    /// The title of the reminder notification.
    var title: String { get }
    
    /// The message/body of the reminder notification.
    var message: String { get }
    
    /// The subtitle of the reminder notification.
    var subTitle: String { get }
    
    var sound: ReminderSound? { get }

    /// The badge number to display on the app icon.
    var badge: Int? { get }

    /// The category identifier used for grouping or adding actions to the notification.
    var categoryIdentifier: String { get }

    /// Custom user info dictionary to embed metadata into the notification.
    var userInfo: [String: String] { get }

    /// Defines the priority level for the notification (e.g., passive, active, time-sensitive, critical).
    var interruptionLevel: UNNotificationInterruptionLevel { get }
}
