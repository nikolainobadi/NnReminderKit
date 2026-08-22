# NnReminderKit

![Build Status](https://github.com/nikolainobadi/NnReminderKit/actions/workflows/ci.yml/badge.svg)
![Swift Version](https://badgen.net/badge/swift/6.0%2B/purple)
![Platforms](https://img.shields.io/badge/platforms-iOS%2017%20%2B%20%7C%20macOS%2014%20%2B-blue)
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
    - [Daily Reminders](#daily-reminders)
  - [Scheduling a Location Reminder](#scheduling-a-location-reminder)
  - [Canceling Reminders](#canceling-reminders)
  - [Loading Pending Reminders](#loading-pending-reminders)
  - [Debug Logging](#debug-logging)
- [UI Test Helpers](#ui-test-helpers-1)
- [Architecture Notes](#architecture-notes)
- [About This Project](#about-this-project)
- [Contributing](#contributing)
- [License](#license)

## Features

- Request and handle notification permissions with SwiftUI view modifiers.
- Schedule and cancel countdown (one-time) reminders.
- Schedule and cancel calendar-based (recurring) weekday reminders.
- Schedule daily repeating reminders or one-time reminders at specific times.
- Schedule and manage location-based reminders.
- Load all pending reminders with detailed metadata.
- Opt-in debug logging for permission, scheduling, canceling, and loading operations.
- Clean abstraction for unit testing and previewing reminder behavior.
- UI test helper for dismissing notification permission alerts.


## Installation

### Swift Package Manager (SPM)

Add the following dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/nikolainobadi/NnReminderKit", from: "1.5.1")
```

#### Main Library

Add `NnReminderKit` to your app target:

```swift
.product(name: "NnReminderKit", package: "NnReminderKit")
```

#### UI Test Helpers

Add `NnReminderUITestHelpers` to your UI test target:

```swift
.product(name: "NnReminderUITestHelpers", package: "NnReminderKit")
```

## Usage

### Handling Notification Permissions with Ease

#### Optional Notifications (Shows Content After Permission Decision)
Use `.optionalNotificationPermissionsRequest` when notifications enhance but aren't essential for your app. This modifier requests permissions first, then shows content regardless of the user's decision:

```swift
struct ContentView: View {
    @State private var notificationsGranted = false

    var body: some View {
        YourMainContent()
            .optionalNotificationPermissionsRequest(
                permissionGranted: $notificationsGranted,
                options: [.alert, .badge, .sound],
                detailView: { requestPermission in
                    VStack {
                        Text("Enable notifications to get reminders")
                        Button("Enable Notifications", action: requestPermission)
                        Button("Skip") {
                            // User can skip - will show content with notificationsGranted = false
                            requestPermission() // This will set permission to denied
                        }
                    }
                }
            )
            .onChange(of: notificationsGranted) { _, granted in
                print("Notifications \(granted ? "enabled" : "disabled")")
            }
    }
}
```

#### Required Notifications (Content Blocked Until Granted)
Use `.requiredNotificationPermissionsRequest` when notifications are essential for core functionality:

```swift
ReminderAppContent()
    .requiredNotificationPermissionsRequest(
        options: [.alert, .badge, .sound],
        detailView: { requestPermission in
            VStack {
                Text("Notifications are required for this app to function")
                Button("Enable Notifications", action: requestPermission)
            }
        },
        deniedView: { settingsURL in
            VStack {
                Text("Notifications are disabled. Please enable them in settings.")
                if let settingsURL {
                    Link("Open Settings", destination: settingsURL)
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
    id: UUID(),
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
    id: UUID(),
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
    id: UUID(),
    title: "Workout",
    message: "Time for your Monday workout!",
    time: Date.createReminderTime(hour: 7, minute: 0),
    repeating: true,
    daysOfWeek: [.monday]
)

let weekendReminder = WeekdayReminder(
    id: UUID(),
    title: "Stretch",
    message: "Weekend stretch reminder!",
    time: Date.createReminderTime(hour: 8, minute: 0),
    repeating: true,
    daysOfWeek: [.saturday, .sunday]
)

try await reminderManager.scheduleWeekdayReminder(mondayReminder)
try await reminderManager.scheduleWeekdayReminder(weekendReminder)
```

#### Daily Reminders

To create a reminder that fires every day at the same time, use `WeekdayReminder` with an empty `daysOfWeek` array. This creates a single notification that repeats daily.

**Using the convenience factory method:**

```swift
let dailyReminder = WeekdayReminder.daily(
    title: "Daily Standup",
    message: "Time for the daily meeting",
    time: Date.createReminderTime(hour: 9, minute: 0)
)

try await reminderManager.scheduleWeekdayReminder(dailyReminder)
```

**One-time reminder (fires once at the next occurrence):**

```swift
let oneTimeReminder = WeekdayReminder.oneTime(
    title: "Important Meeting",
    message: "Don't forget!",
    time: Date.createReminderTime(hour: 14, minute: 30)
)

try await reminderManager.scheduleWeekdayReminder(oneTimeReminder)
```

**Using the standard initializer:**

```swift
let dailyReminder = WeekdayReminder(
    id: UUID(),
    title: "Exercise",
    message: "Time to workout",
    time: Date.createReminderTime(hour: 7, minute: 0),
    repeating: true,
    daysOfWeek: []  // Empty array = daily reminder
)

try await reminderManager.scheduleWeekdayReminder(dailyReminder)
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
reminderManager.cancelCountdownReminder(countdownReminder)
reminderManager.cancelWeekdayReminder(calendarReminder)
reminderManager.cancelLocationReminder(locationReminder)
reminderManager.cancelAllReminders()

// Cancel by base identifiers (async — matches against pending requests)
await reminderManager.cancelReminders(identifiers: [reminder.id])
```

### Loading Pending Reminders

```swift
Task {
    // Load by reminder type
    let countdownReminders = await reminderManager.loadAllCountdownReminders()
    let weekdayReminders = await reminderManager.loadAllWeekdayReminders()
    let locationReminders = await reminderManager.loadAllLocationReminders()

    // Load specific weekday reminder categories
    let dailyReminders = await reminderManager.loadAllDailyReminders()        // Empty days, repeating
    let oneTimeReminders = await reminderManager.loadAllOneTimeReminders()    // Empty days, not repeating
    let weeklyReminders = await reminderManager.loadAllWeeklyReminders()      // Specific days
}
```

### Debug Logging

All operations are silent by default. To see what NnReminderKit is doing under the hood, pass `debugEnabled: true` when creating the manager:

```swift
let reminderManager = NnReminderManager(debugEnabled: true)
```

The permission view modifiers accept the same flag:

```swift
Text("Notifications enabled!")
    .requiredNotificationPermissionsRequest(
        debugEnabled: true,
        detailView: { requestPermission in
            PermissionExplanationView(action: requestPermission)
        },
        deniedView: { settingsURL in
            PermissionDeniedView(settingsURL: settingsURL)
        }
    )
```

When enabled, permission, scheduling, canceling, and loading details are printed to the console with an `[NnReminderKit]` prefix:

```
[NnReminderKit] Requesting notification authorization
[NnReminderKit] Authorization request completed (granted: true)
[NnReminderKit] Scheduling reminder 'Daily Standup' with 3 notification request(s)
[NnReminderKit] Adding notification request: B3E5A0F2-1D4C-4F8A-9C6B-2E7D8A1F0C3D_Monday
[NnReminderKit] Adding notification request: B3E5A0F2-1D4C-4F8A-9C6B-2E7D8A1F0C3D_Wednesday
[NnReminderKit] Adding notification request: B3E5A0F2-1D4C-4F8A-9C6B-2E7D8A1F0C3D_Friday
[NnReminderKit] Loading weekday reminders from 3 pending request(s)
[NnReminderKit] Loaded 1 weekday reminder(s)
[NnReminderKit] Canceling reminder 'Daily Standup' (3 notification request(s))
```

Failure paths are logged as well (failed authorization requests include the error reason). Scheduling errors are still thrown or delivered to completion handlers regardless of the debug flag.

## UI Test Helpers

The `NnReminderUITestHelpers` library provides a convenient extension for handling the iOS notification permission alert in UI tests.

```swift
import NnReminderUITestHelpers

let app = XCUIApplication()
app.launch()

// Allow notifications (default)
app.handleNotificationPermissionAlert()

// Explicitly allow
app.handleNotificationPermissionAlert(.allow)

// Deny notifications
app.handleNotificationPermissionAlert(.deny)
```

## Architecture Notes

NnReminderKit is organized around a central `NnReminderManager` class that abstracts `UNUserNotificationCenter` interactions. It supports three primary reminder types:
- `CountdownReminder` for time-interval-based alerts
- `WeekdayReminder` for calendar-based repetition, including:
  - Weekly reminders on specific weekdays
  - Daily repeating reminders (empty `daysOfWeek` array)
  - One-time reminders at specific times
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
