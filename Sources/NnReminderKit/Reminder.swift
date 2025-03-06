//
//  Reminder.swift
//
//
//  Created by Nikolai Nobadi on 3/5/25.
//

protocol Reminder {
    var id: String { get }
    var title: String { get }
    var message: String { get }
    var subTitle: String { get }
    var withSound: Bool { get }
}


// MARK: - Default Values
extension Reminder {
    var subTitle: String {
        return ""
    }
    
    var withSound: Bool {
        return true
    }
}
