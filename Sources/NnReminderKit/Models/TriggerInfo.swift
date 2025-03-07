//
//  TriggerInfo.swift
//
//  Created by Nikolai Nobadi on 3/5/25.
//

import Foundation

/// Represents a trigger for a scheduled notification.
///
/// This struct is used to store a unique identifier and the date components
/// required to schedule a notification with `UNCalendarNotificationTrigger`.
struct TriggerInfo {
    /// The unique identifier for the notification trigger.
    let id: String
    
    /// The date components that determine when the notification will be triggered.
    let components: DateComponents
}
