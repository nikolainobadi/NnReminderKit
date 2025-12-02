//
//  LocationReminder.swift
//  NnReminderKit
//
//  Created by Nikolai Nobadi on 4/25/25.
//

import UserNotifications

#if os(iOS)
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

    /// Initializes a `LocationReminder`, which triggers when the device enters or exits a specified geographic region.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the reminder.
    ///   - title: The title displayed in the notification.
    ///   - message: The main body text of the notification.
    ///   - subTitle: An optional subtitle for the notification. Defaults to an empty string.
    ///   - sound: An optional custom sound to play when the notification is delivered. Defaults to `.default`.
    ///   - badge: An optional number to display on the app icon.
    ///   - categoryIdentifier: A string used to categorize the notification for custom actions. Defaults to an empty string.
    ///   - userInfo: A dictionary of custom key-value pairs to include with the notification payload. Defaults to an empty dictionary.
    ///   - interruptionLevel: The system-defined importance level of the notification. Defaults to `.active`.
    ///   - locationRegion: The geographic region that triggers the notification.
    ///   - repeats: A Boolean value indicating whether the notification should trigger again when the region event occurs again.
    public init(
        id: UUID,
        title: String,
        message: String,
        subTitle: String = "",
        sound: ReminderSound? = .default,
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


// MARK: - Dependencies
public struct LocationRegion: Sendable {
    public let latitude: Double
    public let longitude: Double
    public let radius: Double
    public let notifyOnEntry: Bool
    public let notifyOnExit: Bool

    /// Initializes a `LocationRegion`, which defines a circular geographic region for triggering location-based reminders.
    ///
    /// - Parameters:
    ///   - latitude: The latitude of the region center.
    ///   - longitude: The longitude of the region center.
    ///   - radius: The radius (in meters) of the region. Defaults to 100.
    ///   - notifyOnEntry: A Boolean indicating whether to trigger on region entry. Defaults to `true`.
    ///   - notifyOnExit: A Boolean indicating whether to trigger on region exit. Defaults to `false`.
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
#endif
