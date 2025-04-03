//
//  CountdownReminder.swift
//
//  Created by Nikolai Nobadi on 3/7/25.
//

import Foundation

/// A reminder that triggers after a set countdown duration rather than at a fixed calendar time.
public struct CountdownReminder: Reminder {
    /// Unique identifier for the reminder.
    public let id: UUID
    
    /// The title of the reminder notification.
    public let title: String
    
    /// The message/body of the reminder notification.
    public let message: String
    
    /// Whether the reminder should repeat after triggering.
    public let repeating: Bool
    
    /// The countdown duration (in seconds) until the reminder triggers.
    public let timeInterval: TimeInterval

    /// Initializes a `CountdownReminder` with the given properties.
    /// - Parameters:
    ///   - id: Unique identifier.
    ///   - title: Title of the reminder.
    ///   - message: Message body.
    ///   - repeating: Whether the reminder repeats.
    ///   - timeInterval: The countdown duration in seconds.
    public init(
        id: UUID,
        title: String,
        message: String,
        repeating: Bool,
        timeInterval: TimeInterval
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.repeating = repeating
        self.timeInterval = timeInterval
    }
}
