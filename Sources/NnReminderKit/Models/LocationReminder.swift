//
//  LocationReminder.swift
//  NnReminderKit
//
//  Created by Nikolai Nobadi on 4/25/25.
//

import UserNotifications

public struct LocationReminder: Reminder {
    public let id: UUID
    public let title: String
    public let message: String
    public let subTitle: String
    public let sound: ReminderSound?
    public let badge: Int?
    public let categoryIdentifier: String
    public let userInfo: [String: String]
    public let interruptionLevel: UNNotificationInterruptionLevel
    public let locationRegion: LocationRegion
    public let repeats: Bool

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
        locationRegion: LocationRegion,
        repeats: Bool
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
        self.locationRegion = locationRegion
        self.repeats = repeats
    }
}


public struct LocationRegion: Sendable {
    public let latitude: Double
    public let longitude: Double
    public let radius: Double
    public let notifyOnEntry: Bool
    public let notifyOnExit: Bool

    public init(
        latitude: Double,
        longitude: Double,
        radius: Double = 100,
        notifyOnEntry: Bool = true,
        notifyOnExit: Bool = false
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.notifyOnEntry = notifyOnEntry
        self.notifyOnExit = notifyOnExit
    }
}
