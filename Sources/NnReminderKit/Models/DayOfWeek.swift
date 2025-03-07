//
//  DayOfWeek.swift
//
//  Created by Nikolai Nobadi on 3/7/25.
//

import Foundation

/// Represents the days of the week as an enumeration.
///
/// The raw values correspond to `Calendar.current` weekday values:
/// - Sunday = 1
/// - Monday = 2
/// - Tuesday = 3
/// - Wednesday = 4
/// - Thursday = 5
/// - Friday = 6
/// - Saturday = 7
public enum DayOfWeek: Int, CaseIterable, Identifiable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday

    /// Unique identifier for `Identifiable` conformance.
    public var id: Int { rawValue }

    /// Returns the localized name of the day.
    public var name: String {
        return DateFormatter().weekdaySymbols[rawValue - 1]
    }
}
