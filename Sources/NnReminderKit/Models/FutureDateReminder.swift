//
//  FutureDateReminder.swift
//  NnReminderKit
//
//  Created by Nikolai Nobadi on 4/2/25.
//

import Foundation

public struct FutureDateReminder: MultiTriggerReminder {
    public let id: String
    public let title: String
    public let message: String
    public let subTitle: String
    public let withSound: Bool
    public let primaryDate: Date
    public let additionalDates: [Date]
    
    public init(id: String, title: String, message: String, subTitle: String = "", withSound: Bool = true, primaryDate: Date, additionalDates: [Date]) {
        self.id = id
        self.title = title
        self.message = message
        self.subTitle = subTitle
        self.withSound = withSound
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
