//
//  FutureDateReminder.swift
//  NnReminderKit
//
//  Created by Nikolai Nobadi on 4/2/25.
//

import Foundation
import UserNotifications

/// A reminder scheduled for one or more specific future dates.
public struct FutureDateReminder: MultiTriggerReminder {
    public let id: UUID
    public let title: String
    public let message: String
    public let subTitle: String
    public let sound: ReminderSound?
    public let badge: Int?
    public let categoryIdentifier: String
    public let userInfo: [String: String]
    public let interruptionLevel: UNNotificationInterruptionLevel
    public let primaryDate: Date
    public let additionalDates: [Date]

    /// Initializes a `FutureDateReminder` with the given properties.
    public init(
        id: UUID,
        title: String,
        message: String,
        subTitle: String = "",
        sound: ReminderSound? = nil,
        badge: Int? = nil,
        categoryIdentifier: String = "",
        userInfo: [String: String] = [:],
        interruptionLevel: UNNotificationInterruptionLevel = .active,
        primaryDate: Date,
        additionalDates: [Date]
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.subTitle = subTitle
        self.sound = sound
        self.badge = badge
        self.categoryIdentifier = categoryIdentifier
        self.userInfo = userInfo
        self.interruptionLevel = interruptionLevel
        self.primaryDate = primaryDate
        self.additionalDates = additionalDates
    }
}

// MARK: - Internal Helpers
internal extension FutureDateReminder {
    var triggers: [TriggerInfo] {
        return TriggerInfoFactory.makeTriggers(for: self)
    }
}
