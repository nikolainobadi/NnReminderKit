//
//  OneTimeReminder.swift
//
//
//  Created by Nikolai Nobadi on 3/7/25.
//

import Foundation

public struct OneTimeReminder: Reminder {
    public let id: String
    public let title: String
    public let message: String
    public let repeating: Bool
    public let timeInterval: TimeInterval
    
    public init(id: String, title: String, message: String, repeating: Bool, timeInterval: TimeInterval) {
        self.id = id
        self.title = title
        self.message = message
        self.repeating = repeating
        self.timeInterval = timeInterval
    }
}
