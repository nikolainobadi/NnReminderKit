# NnReminderKit

![Build Status](https://github.com/nikolainobadi/NnReminderKit/actions/workflows/ci.yml/badge.svg)
![Swift Version](https://badgen.net/badge/swift/6.0%2B/purple)
![Platforms](https://img.shields.io/badge/platforms-iOS%2017%20%2B%20%7C%20macOS%2012%20%2B-blue)
![License](https://img.shields.io/badge/license-MIT-lightgray)

NnReminderKit is a Swift package designed to simplify the scheduling and management of local notifications, including countdown-based and calendar-based reminders. It provides a clean API for handling reminders with support for authorization checks, scheduling, canceling, and retrieving pending reminders.

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
  - [Canceling Reminders](#canceling-reminders)  
  - [Loading Pending Reminders](#loading-pending-reminders)  
- [Future Plans](#future-plans)  
- [License](#license)  

## Features
- Request notification permissions.
- Schedule and cancel countdown (one-time) reminders.
- Schedule and cancel calendar-based (recurring) reminders.
- Load pending reminders asynchronously.
- Abstracted notification handling for easy testing.

## Installation

### Swift Package Manager (SPM)
Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/nikolainobadi/NnReminderKit", from: "0.8.0")
]
```
Or, add it via Xcode:  
1. Open your project.  
2. Go to **File > Add Packages**.  
3. Enter the repository URL:  
   https://github.com/nikolainobadi/NnReminderKit  
4. Select **Branch** and enter `main`.  
<!--4. Select **Up to Next Major Version** and enter `1.0.0`.  -->
5. Click **Add Package**.  

## Usage

## Handling Notification Permissions with Ease  

NnReminderKit simplifies handling local notification permissions by providing a convenient view modifier. This allows you to seamlessly request authorization, present a detailed explanation before requesting permission, and handle denied cases gracefully.  

To use this, apply the `requestReminderPermissions` modifier to the first view where users configure notifications. You must provide two views:  
- A **detail view** explaining why notifications are needed before requesting permission.  
- A **denied view** that guides users to enable notifications in settings if they decline permission.  

```swift
struct NotificationSetupView: View {
    var body: some View {
        NotificationContent()
            .requestReminderPermissions(
                options: [.alert, .badge, .sound], // includes all options by default
                detailView: { requestPermission in
                    VStack {
                        // details about why you need permission/what you will use it for
                        Button("Enable Notifications", action: requestPermission)
                    }
                },
                deniedView: { settingsURL in 
                    VStack {
                        Text("Notifications are disabled. Please enable them in settings.")
                        // the URL to open settings on iOS
                        // will be nil on macOS
                        if let url = settingsURL {
                            Button("Open Settings") {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                }
            )
    }
}

``` 

### Manual Requesting Notification Permissions
Alternatively, you can manually request permissions with `NnReminderManager` directly.

```swift
let reminderManager = NnReminderManager()
Task {
    let granted = await reminderManager.requestAuthPermission(options: [.alert, .badge, .sound])
    print("Permissions granted: \(granted)")
}

```

### Scheduling a Countdown Reminder
Schedule a one-time reminder that triggers after a specified time interval:  

```swift
let countdownReminder = CountdownReminder(
    id: "water_reminder",
    title: "Drink Water",
    message: "Stay hydrated!",
    repeating: false,
    timeInterval: 3600 // 1 hour
)

Task {
    try await reminderManager.scheduleCountdownReminder(countdownReminder)
}

```

### Creating Reminder Times

This package includes a convenient Date extension for generating reminder times without manually constructing DateComponents. Instead of calculating the exact date and time, you can use this extension to quickly create a time for a reminder.

```swift
// Create a Date object for 8:30 AM today
let reminderTime = Date.createReminderTime(hour: 8, minute: 30)

// Create a Date object for 5:00 PM today
let eveningReminder = Date.createReminderTime(hour: 17, minute: 0)

```

### Scheduling a WeekdayReminder
When scheduling a `WeekdayReminder` with multiple days, the system creates a separate notification request for each day internally. However, if all selected days share the same time, only **one** `WeekdayReminder` is required. If different times are needed on different days, multiple `WeekdayReminder` instances must be created.

#### Scheduling a Calendar Reminder at same time for Multiple Days 
If a reminder should repeat on multiple days at the same time, a single `WeekdayReminder` can be used. The system will handle creating individual notification requests for each day.  

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

#### Scheduling WeekdayReminders with Different Times per Day  
If a reminder should occur at different times depending on the day, separate `WeekdayReminder` instances must be used for each time variation.  

```swift
let weekdaysReminder = WeekdayReminder(
    id: "monday_reminder",
    title: "Workout",
    message: "Time for your Monday workout!",
    time: Date.createReminderTime(hour: 7, minute: 0),
    repeating: true,
    daysOfWeek: [.monday, .tuesday, .wednesday, .thursday, .friday]
)

let weekendReminder = WeekdayReminder(
    id: "wednesday_reminder",
    title: "Workout",
    message: "Time for your Wednesday workout!",
    time: Date.createReminderTime(hour: 8, minute: 0),
    repeating: true,
    daysOfWeek: [.saturday, .sunday]
)

try await reminderManager.scheduleWeekdayReminder(weekdaysReminder)
try await reminderManager.scheduleWeekdayReminder(weekendReminder)
```

### Canceling Reminders
You can cancel individual reminders or all pending notifications:  

```swift
// await is necessary as NnReminderManager is an actor
await reminderManager.cancelCountdownReminder(countdownReminder)
await reminderManager.cancelWeekdayReminder(calendarReminder)
await reminderManager.cancelAllReminders() // Cancels all pending reminders
```

### Loading Pending Reminders
Retrieve scheduled reminders from the system:  

```swift
Task {
    let countdownReminders = await reminderManager.loadAllCountdownReminders()
    let weekdayReminders = await reminderManager.loadAllWeekdayReminders()
    
    print("Pending Countdown Reminders: \(countdownReminders)")
    print("Pending Weekday Reminders: \(weekdayReminders)")
}
```

## Future Plans
- Support for location-based notifications.

## License
NnReminderKit is available under the MIT license.
