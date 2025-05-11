# NnReminderKit

![Build Status](https://github.com/nikolainobadi/NnReminderKit/actions/workflows/ci.yml/badge.svg)
![Swift Version](https://badgen.net/badge/swift/6.0%2B/purple)
![Platforms](https://img.shields.io/badge/platforms-iOS%2017%20%2B%20%7C%20macOS%2012%20%2B-blue)
![License](https://img.shields.io/badge/license-MIT-lightgray)

**NnReminderKit** is a Swift package designed to simplify the scheduling and management of local notifications, including countdown, calendar-based, and location-based reminders. It provides a clean, SwiftUI-friendly API for handling permissions, scheduling, canceling, and loading pending reminders.

## Table of Contents
- [Features](#features)  
- [Installation](#installation)  
- [Usage](#usage)  
  - [Handling Notification Permissions](#handling-notification-permissions-with-ease)  
  - [Manually Requesting Notification Permissions](#manual-requesting-notification-permissions)  
  - [Scheduling a Countdown Reminder](#scheduling-a-countdown-reminder)  
  - [Creating Reminder Times](#creating-reminder-times)  
  - [Scheduling a Calendar Reminder](#scheduling-a-calendar-reminder)  
    - [Same Time for Multiple Days](#scheduling-a-calendar-reminder-at-same-time-for-multiple-days)  
    - [Different Times per Day](#scheduling-calendar-reminders-with-different-times-per-day)  
  - [Scheduling a Location Reminder](#scheduling-a-location-reminder)  
  - [Canceling Reminders](#canceling-reminders)  
  - [Loading Pending Reminders](#loading-pending-reminders)  
- [Architecture Notes](#architecture-notes)  
- [Documentation](#documentation)   
- [About This Project](#about-this-project)  
- [Contributing](#contributing)  
- [License](#license)  

## Features

- Request and handle notification permissions with SwiftUI view modifiers.
- Schedule and cancel countdown (one-time) reminders.
- Schedule and cancel calendar-based (recurring) weekday reminders.
- Schedule and manage location-based reminders.
- Load all pending reminders with detailed metadata.
- Clean abstraction for unit testing and previewing reminder behavior.


## Installation

### Swift Package Manager (SPM)

Add the following dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/nikolainobadi/NnReminderKit", from: "1.0.0")
```

## Usage

### Handling Notification Permissions with Ease  

Apply the `.requestReminderPermissions` SwiftUI view modifier to prompt users for notification permissions with built-in explanation and fallback UI:

```swift
NotificationContent()
    .requestReminderPermissions(
        options: [.alert, .badge, .sound],
        detailView: { requestPermission in
            VStack {
                Button("Enable Notifications", action: requestPermission)
            }
        },
        deniedView: { settingsURL in 
            VStack {
                Text("Notifications are disabled. Please enable them in settings.")
                if let url = settingsURL {
                    Button("Open Settings") {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
    )
```

### Manual Requesting Notification Permissions

```swift
let reminderManager = NnReminderManager()
Task {
    let granted = await reminderManager.requestAuthPermission(options: [.alert, .badge, .sound])
    print("Permissions granted: \(granted)")
}
```

### Scheduling a Countdown Reminder

```swift
let countdownReminder = CountdownReminder(
    id: "water_reminder",
    title: "Drink Water",
    message: "Stay hydrated!",
    repeating: false,
    timeInterval: 3600
)

Task {
    try await reminderManager.scheduleCountdownReminder(countdownReminder)
}
```

### Creating Reminder Times

```swift
let reminderTime = Date.createReminderTime(hour: 8, minute: 30)
let eveningReminder = Date.createReminderTime(hour: 17, minute: 0)
```

### Scheduling a Calendar Reminder

#### Same Time for Multiple Days

```swift
let reminder = WeekdayReminder(
    id: "morning_reminder",
    title: "Morning Reminder",
    message: "Start your day!",
    time: Date.createReminderTime(hour: 8, minute: 30),
    repeating: true,
    daysOfWeek: [.monday, .wednesday, .friday]
)

try await reminderManager.scheduleWeekdayReminder(reminder)
```

#### Different Times per Day

```swift
let mondayReminder = WeekdayReminder(
    id: "monday_reminder",
    title: "Workout",
    message: "Time for your Monday workout!",
    time: Date.createReminderTime(hour: 7, minute: 0),
    repeating: true,
    daysOfWeek: [.monday]
)

let weekendReminder = WeekdayReminder(
    id: "weekend_reminder",
    title: "Stretch",
    message: "Weekend stretch reminder!",
    time: Date.createReminderTime(hour: 8, minute: 0),
    repeating: true,
    daysOfWeek: [.saturday, .sunday]
)

try await reminderManager.scheduleWeekdayReminder(mondayReminder)
try await reminderManager.scheduleWeekdayReminder(weekendReminder)
```

### Scheduling a Location Reminder

```swift
let locationRegion = LocationRegion(
    latitude: 37.7749,
    longitude: -122.4194,
    radius: 200,
    notifyOnEntry: true,
    notifyOnExit: false
)

let locationReminder = LocationReminder(
    id: UUID(),
    title: "Arrived at the Park",
    message: "Don't forget to stretch!",
    locationRegion: locationRegion,
    repeats: false
)

try await reminderManager.scheduleLocationReminder(locationReminder)
```

### Canceling Reminders

```swift
await reminderManager.cancelCountdownReminder(countdownReminder)
await reminderManager.cancelWeekdayReminder(calendarReminder)
await reminderManager.cancelLocationReminder(locationReminder)
await reminderManager.cancelReminders(identifiers: [idList])
await reminderManager.cancelAllReminders()
```

### Loading Pending Reminders

```swift
Task {
    let countdownReminders = await reminderManager.loadAllCountdownReminders()
    let weekdayReminders = await reminderManager.loadAllWeekdayReminders()
    let locationReminders = await reminderManager.loAdAllLocationReminders()
}
```

## Architecture Notes

NnReminderKit is organized around a central `NnReminderManager` class that abstracts `UNUserNotificationCenter` interactions. It supports three primary reminder types:
- `CountdownReminder` for time-interval-based alerts
- `WeekdayReminder` for calendar-based repetition
- `LocationReminder` for geofenced alerts

The permission handling is implemented using a SwiftUI-first approach with composable modifiers.

## About This Project

NnReminderKit was built to reduce the boilerplate involved in managing local notifications on Apple platforms. The native APIs can be verbose and error-prone, especially when dealing with multiple types of reminders. This library was designed to offer a clean, testable, and SwiftUI-friendly abstraction for modern apps.

## Contributing

Contributions, feedback, and feature requests are welcome!  
To contribute:
- Fork the repository
- [Open an issue](https://github.com/nikolainobadi/NnReminderKit/issues) or [discussion](https://github.com/nikolainobadi/NnReminderKit/discussions) to propose changes
- Submit a pull request with your updates

---

## License

NnReminderKit is available under the [MIT license](./LICENSE).
