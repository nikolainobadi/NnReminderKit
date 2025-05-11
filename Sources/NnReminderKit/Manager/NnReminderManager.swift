//
//  NnReminderManager.swift
//
//
//  Created by Nikolai Nobadi on 3/5/25.
//

import CoreLocation
import UserNotifications

/// Manages scheduling, canceling, and retrieving reminders using `UserNotifications`.
public final class NnReminderManager {
    /// Notification center dependency for handling notifications.
    private let notifCenter: NotifCenter
    
    /// Initializes `NnReminderManager` with a custom notification center.
    ///
    /// - Parameter notifCenter: An object conforming to `NotifCenter` to handle notification operations.
    init(notifCenter: NotifCenter) {
        self.notifCenter = notifCenter
    }
}


// MARK: - Setup
public extension NnReminderManager {
    /// Default initializer using `NotifCenterAdapter` for interacting with `UserNotifications`.
    convenience init() {
        self.init(notifCenter: NotifCenterAdapter())
    }
    
    /// Sets the delegate for handling notification interactions.
    ///
    /// - Parameter delegate: The object conforming to `UNUserNotificationCenterDelegate` that will handle notification-related events.
    func setNotificationDelegate(_ delegate: UNUserNotificationCenterDelegate) {
        notifCenter.setNotificationDelegate(delegate)
    }
}


// MARK: - PermissionDelegate
extension NnReminderManager: PermissionDelegate {
    /// Requests notification authorization from the user.
    ///
    /// - Parameter options: The notification options, such as `.alert`, `.badge`, and `.sound`.
    /// - Returns: `true` if authorization is granted, otherwise `false`.
    @discardableResult
    public func requestAuthPermission(options: UNAuthorizationOptions) async -> Bool {
        return (try? await notifCenter.requestAuthorization(options: options)) ?? false
    }
    
    /// Checks the current notification authorization status asynchronously.
    ///
    /// - Returns: The current `UNAuthorizationStatus`.
    public func checkForPermissionsWithoutRequest() async -> UNAuthorizationStatus {
        return await notifCenter.getAuthorizationStatus()
    }
}

// MARK: - Cancel
public extension NnReminderManager {
    /// Cancels all scheduled reminders.
    func cancelAllReminders() {
        notifCenter.removeAllPendingNotificationRequests()
    }
    
    /// Cancels all scheduled reminders that share any of the provided base identifiers.
    ///
    /// - Parameter identifiers: An array of UUIDs used to identify reminders for cancellation.
    func cancelReminders(identifiers: [UUID]) async {
        let requests = await notifCenter.getPendingNotificationRequests()
        let matchingIds = requests
            .map(\.identifier)
            .filter { id in
                identifiers.contains { uuid in id.hasPrefix(uuid.uuidString) }
            }

        notifCenter.removePendingNotificationRequests(identifiers: matchingIds)
    }
}


// MARK: - CountdownReminder
public extension NnReminderManager {
    /// Schedules a countdown reminder asynchronously.
    ///
    /// - Parameter reminder: The `CountdownReminder` to schedule.
    /// - Throws: An error if scheduling fails.
    func scheduleCountdownReminder(_ reminder: CountdownReminder) async throws {
        let request = NotificationRequestFactory.makeCountdownReminderRequest(for: reminder)
        try await notifCenter.add(request)
    }
    
    /// Schedules a countdown reminder with a completion handler.
    ///
    /// - Parameters:
    ///   - reminder: The `CountdownReminder` to schedule.
    ///   - completion: A closure receiving an optional error if scheduling fails.
    func scheduleCountdownReminder(_ reminder: CountdownReminder, completion: ((Error?) -> Void)? = nil) {
        let request = NotificationRequestFactory.makeCountdownReminderRequest(for: reminder)
        notifCenter.add(request, completion: completion)
    }
    
    /// Cancels a specific countdown reminder.
    ///
    /// - Parameter reminder: The `CountdownReminder` to cancel.
    func cancelCountdownReminder(_ reminder: CountdownReminder) {
        notifCenter.removePendingNotificationRequests(identifiers: [reminder.id.uuidString])
    }
    
    /// Loads all pending countdown reminders asynchronously.
    ///
    /// - Returns: An array of `CountdownReminder` objects.
    func loadAllCountdownReminders() async -> [CountdownReminder] {
        let requests = await notifCenter.getPendingNotificationRequests()

        return requests.compactMap { request in
            guard
                let id = UUID(uuidString: request.identifier),
                let trigger = request.trigger as? UNTimeIntervalNotificationTrigger
            else {
                return nil
            }

            // Extract properties
            let title = request.content.title
            let message = request.content.body
            let subTitle = request.content.subtitle
            let badge = request.content.badge?.intValue
            let categoryIdentifier = request.content.categoryIdentifier
            let interruptionLevel = request.content.interruptionLevel
            let userInfo = request.content.userInfo as? [String: String] ?? [:]
            let sound = request.content.decodeReminderSound()

            return CountdownReminder(
                id: id,
                title: title,
                message: message,
                subTitle: subTitle,
                sound: sound,
                badge: badge,
                categoryIdentifier: categoryIdentifier,
                userInfo: userInfo,
                interruptionLevel: interruptionLevel,
                repeating: trigger.repeats,
                timeInterval: trigger.timeInterval
            )
        }
    }
}


// MARK: - WeekdayReminder
public extension NnReminderManager {
    /// Schedules a recurring calendar reminder asynchronously.
    ///
    /// - Parameter reminder: The `WeekdayReminder` to schedule.
    /// - Throws: An error if scheduling fails.
    func scheduleWeekdayReminder(_ reminder: WeekdayReminder) async throws {
        try await scheduleMultiTriggerReminder(reminder)
    }
    
    /// Schedules a recurring calendar reminder with a completion handler.
    ///
    /// - Parameters:
    ///   - reminder: The `WeekdayReminder` to schedule.
    ///   - completion: A closure receiving an optional error if scheduling fails.
    func scheduleWeekdayReminder(_ reminder: WeekdayReminder, completion: ((Error?) -> Void)? = nil) {
        for request in NotificationRequestFactory.makeMultiTriggerReminderRequests(for: reminder) {
            notifCenter.add(request, completion: completion)
        }
    }
    
    /// Cancels a specific calendar reminder.
    ///
    /// - Parameter reminder: The `WeekdayReminder` to cancel.
    func cancelWeekdayReminder(_ reminder: WeekdayReminder) {
        cancelMultiTriggerReminder(reminder)
    }
    
    /// Loads all pending calendar reminders asynchronously.
    ///
    /// - Returns: An array of `WeekdayReminder` objects.
    func loadAllWeekdayReminders() async -> [WeekdayReminder] {
        let requests = await notifCenter.getPendingNotificationRequests()
        var groupedReminders: [UUID: (reminder: WeekdayReminder, days: Set<DayOfWeek>)] = [:]

        for request in requests {
            guard
                let trigger = request.trigger as? UNCalendarNotificationTrigger,
                let time = Date.fromComponents(trigger.dateComponents)
            else { continue }

            let repeating = trigger.repeats
            let idComponents = request.identifier.split(separator: "_")
            guard
                let baseIdString = idComponents.first,
                let baseId = UUID(uuidString: String(baseIdString))
            else { continue }

            var day: DayOfWeek?
            if idComponents.count > 1, let dayName = idComponents.last {
                day = DayOfWeek.allCases.first(where: { $0.name == dayName })
            }

            let title = request.content.title
            let message = request.content.body
            let subTitle = request.content.subtitle
            let badge = request.content.badge?.intValue
            let categoryIdentifier = request.content.categoryIdentifier
            let interruptionLevel = request.content.interruptionLevel
            let userInfo = request.content.userInfo as? [String: String] ?? [:]
            let sound = request.content.decodeReminderSound()

            let reminder = WeekdayReminder(
                id: baseId,
                title: title,
                message: message,
                subTitle: subTitle,
                sound: sound,
                badge: badge,
                categoryIdentifier: categoryIdentifier,
                userInfo: userInfo,
                interruptionLevel: interruptionLevel,
                time: time,
                repeating: repeating,
                daysOfWeek: day.map { [$0] } ?? []
            )

            if var existing = groupedReminders[baseId] {
                if let day { existing.days.insert(day) }
                groupedReminders[baseId] = existing
            } else {
                groupedReminders[baseId] = (reminder, day.map { Set([$0]) } ?? [])
            }
        }

        return groupedReminders.map { (uuid, tuple) in
            WeekdayReminder(
                id: uuid,
                title: tuple.reminder.title,
                message: tuple.reminder.message,
                subTitle: tuple.reminder.subTitle,
                sound: tuple.reminder.sound,
                badge: tuple.reminder.badge,
                categoryIdentifier: tuple.reminder.categoryIdentifier,
                userInfo: tuple.reminder.userInfo,
                interruptionLevel: tuple.reminder.interruptionLevel,
                time: tuple.reminder.time,
                repeating: tuple.reminder.repeating,
                daysOfWeek: Array(tuple.days)
            )
        }
    }
}


// MARK: - FutureDateReminder
public extension NnReminderManager {
    /// Schedules a future date reminder consisting of one or more dates.
    ///
    /// - Parameter reminder: The `FutureDateReminder` instance to schedule.
    /// - Throws: An error if scheduling fails.
    func scheduleFutureDateReminder(_ reminder: FutureDateReminder) async throws {
        try await scheduleMultiTriggerReminder(reminder)
    }

    /// Cancels all pending notifications associated with the given `FutureDateReminder`.
    ///
    /// - Parameter reminder: The `FutureDateReminder` to cancel.
    func cancelFutureDateReminder(_ reminder: FutureDateReminder) {
        cancelMultiTriggerReminder(reminder)
    }

    /// Loads all pending future date reminders asynchronously.
    ///
    /// This method scans pending notification requests and groups them into `FutureDateReminder` objects based on shared UUIDs.
    /// It distinguishes between primary and additional dates using the request identifier suffix.
    ///
    /// - Returns: An array of `FutureDateReminder` instances reconstructed from the notification center.
    func loadAllFutureDateReminders() async -> [FutureDateReminder] {
        let requests = await notifCenter.getPendingNotificationRequests()
        var groupedReminders: [UUID: (reminder: FutureDateReminder, primary: Date?, additional: Set<Date>)] = [:]

        for request in requests {
            guard
                let trigger = request.trigger as? UNCalendarNotificationTrigger,
                let date = Date.fromComponents(trigger.dateComponents)
            else { continue }

            let idComponents = request.identifier.split(separator: "_")
            guard
                let baseIdString = idComponents.first,
                let baseId = UUID(uuidString: String(baseIdString))
            else { continue }

            let isPrimary = request.identifier.hasSuffix("_primary")

            // Extract custom values from request.content
            let title = request.content.title
            let message = request.content.body
            let subTitle = request.content.subtitle
            let badge = request.content.badge?.intValue
            let categoryIdentifier = request.content.categoryIdentifier
            let interruptionLevel = request.content.interruptionLevel
            let userInfo = request.content.userInfo as? [String: String] ?? [:]
            let sound = request.content.decodeReminderSound()

            let reminder = FutureDateReminder(
                id: baseId,
                title: title,
                message: message,
                subTitle: subTitle,
                sound: sound,
                badge: badge,
                categoryIdentifier: categoryIdentifier,
                userInfo: userInfo,
                interruptionLevel: interruptionLevel,
                primaryDate: date,
                additionalDates: []
            )

            if var existing = groupedReminders[baseId] {
                if isPrimary {
                    existing.primary = date
                } else {
                    existing.additional.insert(date)
                }
                groupedReminders[baseId] = existing
            } else {
                groupedReminders[baseId] = (
                    reminder,
                    primary: isPrimary ? date : nil,
                    additional: isPrimary ? [] : [date]
                )
            }
        }

        return groupedReminders.compactMap { (uuid, tuple) -> FutureDateReminder? in
            guard let primaryDate = tuple.primary else { return nil }

            return FutureDateReminder(
                id: uuid,
                title: tuple.reminder.title,
                message: tuple.reminder.message,
                subTitle: tuple.reminder.subTitle,
                sound: tuple.reminder.sound,
                badge: tuple.reminder.badge,
                categoryIdentifier: tuple.reminder.categoryIdentifier,
                userInfo: tuple.reminder.userInfo,
                interruptionLevel: tuple.reminder.interruptionLevel,
                primaryDate: primaryDate,
                additionalDates: Array(tuple.additional)
            )
        }
    }
}


// MARK: - LocationReminder
public extension NnReminderManager {
    /// Schedules a location-based reminder asynchronously.
    ///
    /// - Parameter reminder: The `LocationReminder` to schedule.
    /// - Throws: An error if scheduling fails.
    func scheduleLocationReminder(_ reminder: LocationReminder) async throws {
        let request = NotificationRequestFactory.makeLocationReminderRequest(for: reminder)
        try await notifCenter.add(request)
    }
    
    /// Schedules a location-based reminder with a completion handler.
    ///
    /// - Parameters:
    ///   - reminder: The `LocationReminder` to schedule.
    ///   - completion: A closure receiving an optional error if scheduling fails.
    func scheduleLocationReminder(_ reminder: LocationReminder, completion: ((Error?) -> Void)? = nil) {
        let request = NotificationRequestFactory.makeLocationReminderRequest(for: reminder)
        notifCenter.add(request, completion: completion)
    }
    
    /// Cancels a specific location-based reminder.
    ///
    /// - Parameter reminder: The `LocationReminder` to cancel.
    func cancelLocationReminder(_ reminder: LocationReminder) {
        notifCenter.removePendingNotificationRequests(identifiers: [reminder.id.uuidString])
    }
    
    /// Loads all pending location-based reminders asynchronously.
    ///
    /// - Returns: An array of `LocationReminder` objects.
    func loadAllLocationReminders() async -> [LocationReminder] {
        let requests = await notifCenter.getPendingNotificationRequests()

        return requests.compactMap { request in
            guard
                let trigger = request.trigger as? UNLocationNotificationTrigger,
                let region = trigger.region as? CLCircularRegion,
                let id = UUID(uuidString: request.identifier)
            else { return nil }
            
            let title = request.content.title
            let message = request.content.body
            let subTitle = request.content.subtitle
            let badge = request.content.badge?.intValue
            let categoryIdentifier = request.content.categoryIdentifier
            let interruptionLevel = request.content.interruptionLevel
            let userInfo = request.content.userInfo as? [String: String] ?? [:]
            let sound = request.content.decodeReminderSound()
            
            let locationRegion = LocationRegion(
                latitude: region.center.latitude,
                longitude: region.center.longitude,
                radius: region.radius,
                notifyOnEntry: region.notifyOnEntry,
                notifyOnExit: region.notifyOnExit
            )

            return LocationReminder(
                id: id,
                title: title,
                message: message,
                subTitle: subTitle,
                sound: sound,
                badge: badge,
                categoryIdentifier: categoryIdentifier,
                userInfo: userInfo,
                interruptionLevel: interruptionLevel,
                locationRegion: locationRegion,
                repeats: trigger.repeats
            )
        }
    }
}


// MARK: - Private Methods
private extension NnReminderManager {
    /// Cancels all pending notifications associated with a multi-trigger reminder.
    ///
    /// - Parameter reminder: A reminder conforming to `MultiTriggerReminder` whose notifications should be removed.
    func cancelMultiTriggerReminder(_ reminder: any MultiTriggerReminder) {
        let identifiers = reminder.triggers.map({ $0.id })
        notifCenter.removePendingNotificationRequests(identifiers: identifiers)
    }

    /// Schedules all notifications for a multi-trigger reminder asynchronously.
    ///
    /// - Parameter reminder: A reminder conforming to `MultiTriggerReminder` to schedule.
    /// - Throws: An error if any notification request fails.
    func scheduleMultiTriggerReminder(_ reminder: any MultiTriggerReminder) async throws {
        for request in NotificationRequestFactory.makeMultiTriggerReminderRequests(for: reminder) {
            try await notifCenter.add(request)
        }
    }
}


// MARK: - Dependencies
/// A protocol defining interactions with the notification system.
///
/// This abstraction allows for dependency injection and testing by enabling the use of a mock notification center.
protocol NotifCenter: Sendable {
    func removeAllPendingNotificationRequests()
    func add(_ request: UNNotificationRequest) async throws
    func getAuthorizationStatus() async -> UNAuthorizationStatus
    func removePendingNotificationRequests(identifiers: [String])
    func getPendingNotificationRequests() async -> [UNNotificationRequest]
    func setNotificationDelegate(_ delegate: UNUserNotificationCenterDelegate)
    func add(_ request: UNNotificationRequest, completion: ((Error?) -> Void)?)
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
}


// MARK: - Extension Dependencies
/// Extension for `WeekdayReminder` providing computed properties.
private extension WeekdayReminder {
    /// Generates a list of unique identifiers for the reminder.
    ///
    /// - If the reminder is not associated with specific days, it returns a single identifier.
    /// - If the reminder is recurring on multiple days, it returns an identifier for each day.
    var identifierList: [String] {
        if daysOfWeek.isEmpty {
            return [id.uuidString]
        }
        return daysOfWeek.map { "\(id.uuidString)_\($0.name)" }
    }
}

/// Extension for `Date` providing utilities for creating `Date` objects from `DateComponents`.
private extension Date {
    /// Creates a `Date` object from the given `DateComponents`.
    ///
    /// - Uses the current year, month, and day to ensure a valid date.
    /// - Returns `nil` if the date cannot be created.
    ///
    /// - Parameter components: The `DateComponents` to convert into a `Date` object.
    /// - Returns: A `Date` object if conversion is successful, otherwise `nil`.
    static func fromComponents(_ components: DateComponents) -> Date? {
        var newComponents = components
        let now = Date()
        let calendar = Calendar.current

        // Use the current year, month, and day
        let currentComponents = calendar.dateComponents([.year, .month, .day], from: now)
        newComponents.year = currentComponents.year
        newComponents.month = currentComponents.month
        newComponents.day = currentComponents.day

        return calendar.date(from: newComponents)
    }
}

private extension UNNotificationContent {
    func decodeReminderSound() -> ReminderSound? {
        let userInfo = self.userInfo as? [String: String] ?? [:]

        if let soundName = userInfo[.customSoundNameKey] {
            return .custom(name: soundName)
        } else if sound == .defaultCritical {
            return .critical
        } else if sound == .default {
            return .default
        } else {
            return nil
        }
    }
}
