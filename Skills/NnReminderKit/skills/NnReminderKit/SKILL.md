---
name: NnReminderKit
description: NnReminderKit Swift API reference for local notification scheduling and management on Apple platforms. USE WHEN scheduling reminders, creating notifications, managing countdown/weekday/location/future-date reminders, requesting notification permissions in SwiftUI, using NnReminderKit, NnReminderManager, handling notification permission alerts in UI tests, NnReminderUITestHelpers.
user-invocable: true
---

# NnReminderKit

Swift package for scheduling and managing local notifications on Apple platforms with a SwiftUI-friendly API.

**Dependency:** `https://github.com/nikolainobadi/NnReminderKit.git` (1.5.1)
**Platforms:** iOS 17+ / macOS 14+ | **Swift:** 6.0
**Products:** `NnReminderKit` (main library) · `NnReminderUITestHelpers` (UI test helpers)

## Context Files

| File | Purpose | Load When |
|------|---------|-----------|
| `ApiReference.md` | Full API reference for all public types, behavioral docs, and best practices | Working with NnReminderKit types, scheduling reminders, or integrating notification permissions |

## Quick Reference

- **`NnReminderManager`** — Main facade: schedule, cancel, load reminders; request notification permissions
- **`CountdownReminder`** — Fire after a time interval (one-shot or repeating)
- **`WeekdayReminder`** — Fire on specific weekdays, daily, or one-time at a given time; use `.daily()` / `.oneTime()` factory methods
- **`FutureDateReminder`** — Fire at specific future dates (primary + additional)
- **`LocationReminder`** (iOS only) — Fire on geofence entry/exit
- **SwiftUI modifiers** — `.optionalNotificationPermissionsRequest()` and `.requiredNotificationPermissionsRequest()` for permission flows
- **`DayOfWeek`** / **`ReminderSound`** — Supporting enums for weekday selection and notification sounds
- **Debug logging** — Opt-in `debugEnabled: Bool` flag on `NnReminderManager` init and permission modifiers; prints `[NnReminderKit]`-prefixed messages, silent by default
- **`NnReminderUITestHelpers`** — Separate library with `XCUIApplication.handleNotificationPermissionAlert(_:timeout:)` for dismissing notification permission alerts in UI tests

## Examples

- "Schedule a daily reminder at 9 AM" -> Loads `ApiReference.md`
- "Add notification permission request to my SwiftUI view" -> Loads `ApiReference.md`
- "Cancel all weekday reminders for a specific ID" -> Loads `ApiReference.md`
- "Handle notification permission alert in UI tests" -> Loads `ApiReference.md`
- "Enable debug logging for reminder scheduling" -> Loads `ApiReference.md`
