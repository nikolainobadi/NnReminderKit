//
//  NotificationRequestFactory.swift
//
//  Created by Nikolai Nobadi on 3/6/25.
//

import Foundation
import UserNotifications

/// A factory responsible for creating `UNNotificationRequest` objects for different reminder types.
enum NotificationRequestFactory {
    /// Creates a notification request for a `CountdownReminder`.
    /// - Parameter reminder: The `CountdownReminder` containing title, message, and time interval.
    /// - Returns: A `UNNotificationRequest` configured for a countdown-based notification.
    static func makeCountdownReminderRequest(for reminder: CountdownReminder) -> UNNotificationRequest {
        let content = makeContent(for: reminder)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: reminder.timeInterval, repeats: reminder.repeating)
        
        return .init(identifier: reminder.id.uuidString, content: content, trigger: trigger)
    }

    /// Creates a list of notification requests for a `MultiTriggerReminders`.
    /// - Parameter reminder: The `MultiTriggerReminder` containing title, message, scheduled time, and repeat settings.
    /// - Returns: An array of `UNNotificationRequest` objects, one for each scheduled trigger.
    static func makeMultiTriggerReminderRequests(for reminder: any MultiTriggerReminder) -> [UNNotificationRequest] {
        let content = makeContent(for: reminder)

        return reminder.triggers.map {
            .init(identifier: $0.id, content: content, trigger: makeRecurringTrigger($0))
        }
    }
    
    /// Creates a notification request for a `LocationReminder`.
    /// - Parameter reminder: The `LocationReminder` containing title, message, and location data.
    /// - Returns: A `UNNotificationRequest` configured for a location-based notification.
    static func makeLocationReminderRequest(for reminder: LocationReminder) -> UNNotificationRequest {
        let content = makeContent(for: reminder)
        let trigger = makeLocationTrigger(for: reminder)
        
        return .init(identifier: reminder.id.uuidString, content: content, trigger: trigger)
    }
}


// MARK: - Private Methods
private extension NotificationRequestFactory {
    static func makeRecurringTrigger(_ info: TriggerInfo) -> UNCalendarNotificationTrigger {
        return .init(dateMatching: info.components, repeats: true)
    }
    
    static func makeLocationTrigger(for reminder: LocationReminder) -> UNLocationNotificationTrigger {
        let region = reminder.locationRegion.toCLRegion(identifier: reminder.id.uuidString)
        return UNLocationNotificationTrigger(region: region, repeats: reminder.repeats)
    }

    static func makeContent(for reminder: any Reminder) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.message
        content.subtitle = reminder.subTitle
        content.interruptionLevel = reminder.interruptionLevel
        content.categoryIdentifier = reminder.categoryIdentifier
        
        var userInfo = reminder.userInfo
        
        if let badge = reminder.badge {
            content.badge = .init(integerLiteral: badge)
        }

        if let sound = reminder.sound {
            content.sound = sound.asUNNotificationSound()
            
            switch sound {
            case .custom(let soundName):
                userInfo[.customSoundNameKey] = soundName
            default:
                break
            }
        }
        
        content.userInfo = userInfo

        return content
    }
}


// MARK: - Extension Dependencies
fileprivate extension ReminderSound {
    func asUNNotificationSound() -> UNNotificationSound {
        switch self {
        case .default:
            return .default
        case .critical:
            return .defaultCritical
        case .custom(let name):
            return UNNotificationSound(named: UNNotificationSoundName(name))
        }
    }
}

extension String {
    static var customSoundNameKey: String {
        return "nnreminder_soundName"
    }
}

import CoreLocation

extension LocationRegion {
    func toCLRegion(identifier: String) -> CLCircularRegion {
        let region = CLCircularRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            radius: radius,
            identifier: identifier
        )
        region.notifyOnEntry = notifyOnEntry
        region.notifyOnExit = notifyOnExit
        return region
    }
}
