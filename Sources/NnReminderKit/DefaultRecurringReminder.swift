//
//  DefaultRecurringReminder.swift
//
//
//  Created by Nikolai Nobadi on 3/5/25.
//

public struct DefaultRecurringReminder: RecurringReminder {
    public let id: String
    public let title: String
    public let message: String
    public let subTitle: String
    public let withSound: Bool
    public let time: ReminderTime
    public let recurringType: RecurringType
    
    public init(id: String, title: String, message: String, subTitle: String = "", withSound: Bool = true, time: ReminderTime, recurringType: RecurringType) {
        self.id = id
        self.title = title
        self.message = message
        self.subTitle = subTitle
        self.withSound = withSound
        self.time = time
        self.recurringType = recurringType
    }
}


// MARK: - RecurringReminderInitializable
extension DefaultRecurringReminder: RecurringReminderInitializable {
    public init(_ info: RecurringReminder) {
        self.init(
            id: info.id,
            title: info.title,
            message: info.message,
            subTitle: info.subTitle,
            withSound: info.withSound,
            time: info.time,
            recurringType: info.recurringType
        )
    }
}
