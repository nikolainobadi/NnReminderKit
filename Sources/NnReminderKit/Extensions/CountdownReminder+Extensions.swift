//
//  CountdownReminder+Extensions.swift
//
//
//  Created by Nikolai Nobadi on 3/7/25.
//

import Foundation

public extension CountdownReminder {
    static var sample: CountdownReminder {
        return makeSample()
    }
    
    static func makeSample(id: String = "reminderId", title: String = "One-Time Reminder", message: String = "This is a sample one-time reminder", repeating: Bool = false, timeInterval: TimeInterval = 3600) -> CountdownReminder {
        
        return .init(id: id, title: title, message: message, repeating: repeating, timeInterval: timeInterval)
    }
    
    static var sampleList: [CountdownReminder] {
        return [
            makeSample(id: "0", title: "Take Medicine", timeInterval: 3600),
            makeSample(id: "1", title: "Meeting in an Hour", timeInterval: 1800),
            makeSample(id: "2", title: "Workout Reminder", repeating: true, timeInterval: 7200)
        ]
    }
}

