//
//  Reminder.swift
//
//  Created by Nikolai Nobadi on 3/5/25.
//

import Foundation

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
    
    /// Indicates whether the reminder includes a notification sound.
    var withSound: Bool { get }
}

// MARK: - Default Values
extension Reminder {
    /// Default value for `subTitle` (empty string).
    var subTitle: String { return "" }
    
    /// Default value for `withSound` (enabled).
    var withSound: Bool { return true }
}
