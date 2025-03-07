//
//  DayOfWeek.swift
//
//
//  Created by Nikolai Nobadi on 3/7/25.
//

import Foundation

public enum DayOfWeek: Int, CaseIterable, Identifiable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    
    public var id: Int { rawValue }
    
    public var name: String {
        return DateFormatter().weekdaySymbols[rawValue - 1]
    }
}
