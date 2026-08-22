# NnReminderKit API Reference

Complete API reference for NnReminderKit — local notification scheduling and management for iOS 17+ / macOS 14+.

---

## Common Pitfalls

- **Empty `daysOfWeek` means daily, not "no days"** — `WeekdayReminder(daysOfWeek: [])` creates a daily trigger. Use `.daily()` and `.oneTime()` factories for clarity.
- **Non-empty `daysOfWeek` forces `repeating: true`** — When specific days are provided, the `repeating` parameter is ignored and hardcoded to `true` internally.
- **Multi-trigger scheduling is not atomic** — `WeekdayReminder` and `FutureDateReminder` add each trigger individually. A mid-schedule failure leaves partial triggers with no rollback.
- **`requestAuthPermission` silently swallows errors** — Returns `false` on both denial and thrown errors (the error reason is only visible via debug logging). To distinguish denial from error, call `checkForPermissionsWithoutRequest()` afterward.
- **`FutureDateReminder` silently drops on reload if primary has fired** — Groups without a `_primary` suffixed request are excluded from `loadAllFutureDateReminders()`.
- **`DayOfWeek.name` is locale-dependent** — Day names embedded in notification identifiers at schedule time must match the locale at load time, or weekday reminders reconstruct as daily.
- **`WeekdayReminder.time` loses its date on reload** — Only hour and minute survive the round-trip. The loaded `time` property uses today's date.

---

## Class: NnReminderManager

Main facade for scheduling, canceling, and loading local notifications. Conforms to `PermissionDelegate` (internal protocol) for SwiftUI permission integration.

```swift
public final class NnReminderManager
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `init(debugEnabled: Bool = false)` | Creates a manager backed by `UNUserNotificationCenter.current()`; pass `true` to print debug messages to the console |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `setNotificationDelegate(_ delegate: UNUserNotificationCenterDelegate)` | `Void` | Sets the delegate on `UNUserNotificationCenter` directly; no state stored on the manager |
| `requestAuthPermission(options: UNAuthorizationOptions) async` | `@discardableResult Bool` | Requests notification authorization; returns `false` on denial or error (error reason printed only when debug logging is enabled) |
| `checkForPermissionsWithoutRequest() async` | `UNAuthorizationStatus` | Returns current authorization status without triggering a permission dialog |
| `cancelAllReminders()` | `Void` | Synchronously removes all pending notification requests |
| `cancelReminders(identifiers: [UUID]) async` | `Void` | Cancels all pending requests whose identifier starts with any of the provided UUIDs; handles both single and multi-trigger reminders in one batch call |
| `scheduleCountdownReminder(_ reminder: CountdownReminder) async throws` | `Void` | Schedules a single time-interval notification request |
| `scheduleCountdownReminder(_ reminder: CountdownReminder, completion: (@Sendable (Error?) -> Void)?)` | `Void` | Completion-based variant for non-async contexts |
| `cancelCountdownReminder(_ reminder: CountdownReminder)` | `Void` | Synchronously removes the single request by ID |
| `loadAllCountdownReminders() async` | `[CountdownReminder]` | Loads pending requests with `UNTimeIntervalNotificationTrigger` and bare UUID identifiers |
| `scheduleWeekdayReminder(_ reminder: WeekdayReminder) async throws` | `Void` | Schedules one request per day in `daysOfWeek` (or one request for daily/one-time) |
| `scheduleWeekdayReminder(_ reminder: WeekdayReminder, completion: (@Sendable (Error?) -> Void)?)` | `Void` | Completion-based variant; fires the same completion for each individual request |
| `cancelWeekdayReminder(_ reminder: WeekdayReminder)` | `Void` | Regenerates trigger IDs from the model and removes all matching requests |
| `loadAllWeekdayReminders() async` | `[WeekdayReminder]` | Loads and groups calendar-triggered requests by base UUID into `WeekdayReminder` instances |
| `loadAllDailyReminders() async` | `[WeekdayReminder]` | Filters `loadAllWeekdayReminders()` for `daysOfWeek.isEmpty && repeating == true` |
| `loadAllOneTimeReminders() async` | `[WeekdayReminder]` | Filters `loadAllWeekdayReminders()` for `daysOfWeek.isEmpty && repeating == false` |
| `loadAllWeeklyReminders() async` | `[WeekdayReminder]` | Filters `loadAllWeekdayReminders()` for `!daysOfWeek.isEmpty` |
| `scheduleFutureDateReminder(_ reminder: FutureDateReminder) async throws` | `Void` | Schedules one request per date (primary + additional) |
| `cancelFutureDateReminder(_ reminder: FutureDateReminder)` | `Void` | Regenerates trigger IDs from the model and removes all matching requests |
| `loadAllFutureDateReminders() async` | `[FutureDateReminder]` | Loads calendar-triggered requests grouped by UUID; groups without a `_primary` suffix request are silently dropped |
| `scheduleLocationReminder(_ reminder: LocationReminder) async throws` | `Void` | Schedules a geofenced notification (iOS only) |
| `scheduleLocationReminder(_ reminder: LocationReminder, completion: (@Sendable (Error?) -> Void)?)` | `Void` | Completion-based variant (iOS only) |
| `cancelLocationReminder(_ reminder: LocationReminder)` | `Void` | Synchronously removes the single request by ID (iOS only) |
| `loadAllLocationReminders() async` | `[LocationReminder]` | Loads pending requests with `UNLocationNotificationTrigger` and `CLCircularRegion` (iOS only) |

### Usage Example

```swift
let manager = NnReminderManager()

// Request permissions
let granted = await manager.requestAuthPermission(options: [.alert, .badge, .sound])

// Schedule a daily reminder
let daily = WeekdayReminder.daily(title: "Standup", message: "Time for standup", time: nineAM)
try await manager.scheduleWeekdayReminder(daily)

// Load and cancel
let reminders = await manager.loadAllDailyReminders()
manager.cancelWeekdayReminder(daily)
```

### Scheduling Behavior

Multi-trigger scheduling (`WeekdayReminder`, `FutureDateReminder`) is **not atomic**: each trigger is added individually. If the second request fails, the first has already been added with no rollback.

The async `throws` variant and the completion-based variant use slightly different internal paths — the async variant delegates through a private `scheduleMultiTriggerReminder` method, while the completion variant calls the factory directly.

### Cancel Behavior

| Reminder Type | Cancel Method | Mechanism |
|:---|:---|:---|
| `CountdownReminder` | `cancelCountdownReminder(_:)` | Direct ID removal (synchronous) |
| `WeekdayReminder` | `cancelWeekdayReminder(_:)` | Regenerates trigger IDs from model (synchronous) |
| `FutureDateReminder` | `cancelFutureDateReminder(_:)` | Regenerates trigger IDs from model (synchronous) |
| `LocationReminder` | `cancelLocationReminder(_:)` | Direct ID removal (synchronous, iOS only) |
| Any/mixed | `cancelReminders(identifiers:)` | Async fetch + prefix matching (batch) |

### Load Discrimination

All load methods fetch the full pending request list and discriminate by trigger type:

| Method | Trigger Filter | ID Pattern |
|:---|:---|:---|
| `loadAllCountdownReminders` | `UNTimeIntervalNotificationTrigger` | Bare UUID |
| `loadAllWeekdayReminders` | `UNCalendarNotificationTrigger` | UUID or UUID_DayName |
| `loadAllFutureDateReminders` | `UNCalendarNotificationTrigger` | UUID_date_primary / UUID_date |
| `loadAllLocationReminders` | `UNLocationNotificationTrigger` | Bare UUID |

### Debug Logging

All operations are silent by default. Pass `debugEnabled: true` at initialization to print permission, scheduling, canceling, and loading details to the console with an `[NnReminderKit]` prefix:

```swift
let manager = NnReminderManager(debugEnabled: true)
```

```
[NnReminderKit] Requesting notification authorization
[NnReminderKit] Authorization request completed (granted: true)
[NnReminderKit] Scheduling reminder 'Daily Standup' with 3 notification request(s)
[NnReminderKit] Adding notification request: B3E5A0F2-..._Monday
[NnReminderKit] Loading weekday reminders from 3 pending request(s)
[NnReminderKit] Loaded 1 weekday reminder(s)
```

Failure paths are logged as well (failed authorization requests include the error reason). Scheduling errors are still thrown or delivered to completion handlers regardless of the flag. The permission view modifiers accept the same `debugEnabled` parameter and forward it to their internal manager.

---

## Struct: CountdownReminder

Time-interval based notification. Creates a single `UNTimeIntervalNotificationTrigger`.

```swift
public struct CountdownReminder: Identifiable, Sendable
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `init(id: UUID, title: String, message: String, subTitle: String = "", sound: ReminderSound? = .default, badge: Int? = nil, categoryIdentifier: String = "", userInfo: [String: String] = [:], interruptionLevel: UNNotificationInterruptionLevel = .active, repeating: Bool, timeInterval: TimeInterval)` | Creates a countdown reminder with all configurable fields |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | `UUID` | Unique identifier (used as notification request ID) |
| `title` | `String` | Notification title |
| `message` | `String` | Notification body text |
| `subTitle` | `String` | Notification subtitle |
| `sound` | `ReminderSound?` | Notification sound; defaults to `.default` |
| `badge` | `Int?` | Badge number |
| `categoryIdentifier` | `String` | Notification category for actions |
| `userInfo` | `[String: String]` | Custom user info dictionary |
| `interruptionLevel` | `UNNotificationInterruptionLevel` | Interruption level |
| `repeating` | `Bool` | Whether the notification repeats |
| `timeInterval` | `TimeInterval` | Seconds until the notification fires |

### Static Members

| Member | Type | Description |
|--------|------|-------------|
| `.sample` | `CountdownReminder` | Sample instance for previews |
| `.makeSample(id:title:message:repeating:timeInterval:)` | `CountdownReminder` | Configurable sample factory |
| `.sampleList` | `[CountdownReminder]` | List of sample instances |

### Usage Example

```swift
let reminder = CountdownReminder(
    id: UUID(),
    title: "Timer Done",
    message: "Your timer has finished",
    repeating: false,
    timeInterval: 300 // 5 minutes
)
try await manager.scheduleCountdownReminder(reminder)
```

---

## Struct: WeekdayReminder

Calendar-based notification for recurring weekday, daily, or one-time scheduling. Conforms to `MultiTriggerReminder` — creates multiple notification requests (one per weekday) or a single request for daily/one-time patterns.

```swift
public struct WeekdayReminder: Identifiable, Sendable
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `init(id: UUID, title: String, message: String, subTitle: String = "", sound: ReminderSound? = .default, badge: Int? = nil, categoryIdentifier: String = "", userInfo: [String: String] = [:], interruptionLevel: UNNotificationInterruptionLevel = .active, time: Date, repeating: Bool = true, daysOfWeek: [DayOfWeek])` | Creates a weekday reminder; pass empty `daysOfWeek` for daily/one-time |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | `UUID` | Unique identifier (prefix for multi-trigger request IDs) |
| `title` | `String` | Notification title |
| `message` | `String` | Notification body text |
| `subTitle` | `String` | Notification subtitle |
| `sound` | `ReminderSound?` | Notification sound; defaults to `.default` |
| `badge` | `Int?` | Badge number |
| `categoryIdentifier` | `String` | Notification category |
| `userInfo` | `[String: String]` | Custom user info dictionary |
| `interruptionLevel` | `UNNotificationInterruptionLevel` | Interruption level |
| `time` | `Date` | Time of day to fire (only hour/minute are used) |
| `repeating` | `Bool` | Whether the notification repeats (defaults to `true`) |
| `daysOfWeek` | `[DayOfWeek]` | Days to fire; empty = daily/one-time pattern |
| `displayableTime` | `String` | Formatted time string (e.g., "8:30 AM") |
| `dayListText` | `String` | Human-readable day description (e.g., "Every Day", "Weekends", "Mon, Wed, Fri") |

### Static Factory Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `.daily(id:title:message:subTitle:sound:badge:categoryIdentifier:userInfo:interruptionLevel:time:)` | `WeekdayReminder` | Convenience for daily repeating (empty days, repeating = true) |
| `.oneTime(id:title:message:subTitle:sound:badge:categoryIdentifier:userInfo:interruptionLevel:time:)` | `WeekdayReminder` | Convenience for one-time (empty days, repeating = false) |
| `.sample` | `WeekdayReminder` | Sample instance for previews |
| `.makeSample(id:title:message:time:repeating:daysOfWeek:)` | `WeekdayReminder` | Configurable sample factory |
| `.sampleList` | `[WeekdayReminder]` | List of sample instances |

### Usage Example

```swift
// Weekly on Mon/Wed/Fri
let weekly = WeekdayReminder(
    id: UUID(), title: "Exercise", message: "Time to work out",
    time: Date.createReminderTime(hour: 7, minute: 0),
    daysOfWeek: [.monday, .wednesday, .friday]
)

// Daily repeating
let daily = WeekdayReminder.daily(
    title: "Standup", message: "Daily meeting", time: nineAM
)

// One-time at next occurrence
let once = WeekdayReminder.oneTime(
    title: "Reminder", message: "One time only", time: nineAM
)
```

### Trigger Behavior

| Pattern | `daysOfWeek` | `repeating` | Requests Created | Trigger Components |
|:---|:---|:---|:---|:---|
| Daily | `[]` (empty) | `true` | 1 | hour, minute only (no weekday) |
| One-time | `[]` (empty) | `false` | 1 | hour, minute only; fires once at next occurrence |
| Weekly | `[.monday, .friday]` | ignored (forced `true`) | N (one per day) | hour, minute, weekday |

**Important:** When `daysOfWeek` is non-empty, `repeating` is hardcoded to `true` internally regardless of the value you pass.

### dayListText Behavior

| State | Output |
|:---|:---|
| Empty days (`[]`) | `"Every Day"` |
| All 7 days | `"Every Day"` |
| Saturday + Sunday only | `"Weekends"` |
| Mon-Fri (no Sat/Sun) | `"Weekdays"` |
| Other combinations | Comma-separated sorted day names |

---

## Struct: FutureDateReminder

Notification scheduled at specific future dates. Conforms to `MultiTriggerReminder` — creates one request per date (primary + additional). All triggers are non-repeating.

```swift
public struct FutureDateReminder: Identifiable, Sendable
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `init(id: UUID, title: String, message: String, subTitle: String = "", sound: ReminderSound? = .default, badge: Int? = nil, categoryIdentifier: String = "", userInfo: [String: String] = [:], interruptionLevel: UNNotificationInterruptionLevel = .active, primaryDate: Date, additionalDates: [Date])` | Creates a future date reminder with a primary and optional additional dates |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | `UUID` | Unique identifier (prefix for multi-trigger request IDs) |
| `title` | `String` | Notification title |
| `message` | `String` | Notification body text |
| `subTitle` | `String` | Notification subtitle |
| `sound` | `ReminderSound?` | Notification sound; defaults to `.default` |
| `badge` | `Int?` | Badge number |
| `categoryIdentifier` | `String` | Notification category |
| `userInfo` | `[String: String]` | Custom user info dictionary |
| `interruptionLevel` | `UNNotificationInterruptionLevel` | Interruption level |
| `primaryDate` | `Date` | Main date/time for the notification |
| `additionalDates` | `[Date]` | Extra dates to also fire the notification |

### Usage Example

```swift
let reminder = FutureDateReminder(
    id: UUID(),
    title: "Appointment",
    message: "Doctor visit tomorrow",
    primaryDate: Date.createReminderTime(hour: 9, minute: 0, date: appointmentDate),
    additionalDates: [
        Date.createReminderTime(hour: 18, minute: 0, date: dayBefore)
    ]
)
try await manager.scheduleFutureDateReminder(reminder)
```

### Edge Cases

- **Missing primary on reload:** If the primary date's notification has already fired (and been removed by the system), `loadAllFutureDateReminders()` silently drops that reminder entirely — groups without a `_primary` request are excluded.
- **Same-day additional dates:** Two additional dates on the same calendar day (different times) produce the same trigger ID (`UUID_dd-MM-yyyy`), causing the second to overwrite the first.
- **Ordering:** `additionalDates` ordering is not preserved on reload (internally stored in a `Set<Date>`).

---

## Struct: LocationReminder (iOS only)

Geofenced notification that fires on region entry/exit. Creates a single `UNLocationNotificationTrigger` with a `CLCircularRegion`.

```swift
#if os(iOS)
public struct LocationReminder: Identifiable, Sendable
#endif
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `init(id: UUID, title: String, message: String, subTitle: String = "", sound: ReminderSound? = .default, badge: Int? = nil, categoryIdentifier: String = "", userInfo: [String: String] = [:], interruptionLevel: UNNotificationInterruptionLevel = .active, locationRegion: LocationRegion, repeats: Bool)` | Creates a location-based reminder |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | `UUID` | Unique identifier |
| `title` | `String` | Notification title |
| `message` | `String` | Notification body text |
| `subTitle` | `String` | Notification subtitle |
| `sound` | `ReminderSound?` | Notification sound; defaults to `.default` |
| `badge` | `Int?` | Badge number |
| `categoryIdentifier` | `String` | Notification category |
| `userInfo` | `[String: String]` | Custom user info dictionary |
| `interruptionLevel` | `UNNotificationInterruptionLevel` | Interruption level |
| `locationRegion` | `LocationRegion` | Geographic region configuration |
| `repeats` | `Bool` | Whether the notification repeats on each region event |

### Usage Example

```swift
#if os(iOS)
let reminder = LocationReminder(
    id: UUID(),
    title: "Store Visit",
    message: "Don't forget to buy milk!",
    locationRegion: LocationRegion(
        latitude: 37.7749, longitude: -122.4194,
        radius: 200, notifyOnEntry: true, notifyOnExit: false
    ),
    repeats: false
)
try await manager.scheduleLocationReminder(reminder)
#endif
```

---

## Struct: LocationRegion (iOS only)

Configuration for a circular geographic region used by `LocationReminder`.

```swift
#if os(iOS)
public struct LocationRegion: Sendable
#endif
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `init(latitude: Double, longitude: Double, radius: Double = 100, notifyOnEntry: Bool = true, notifyOnExit: Bool = false)` | Creates a circular region; radius in meters |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `latitude` | `Double` | Center latitude |
| `longitude` | `Double` | Center longitude |
| `radius` | `Double` | Radius in meters (default: 100) |
| `notifyOnEntry` | `Bool` | Fire on region entry (default: true) |
| `notifyOnExit` | `Bool` | Fire on region exit (default: false) |

---

## Enum: ReminderSound

Notification sound configuration. Encoded into `UNMutableNotificationContent` at scheduling time and decoded back on load.

```swift
public enum ReminderSound: Sendable
```

### Cases

| Case | Associated Values | Description |
|------|-------------------|-------------|
| `.default` | None | System default notification sound |
| `.critical` | None | Critical alert sound (bypasses silent mode) |
| `.custom(name:)` | `name: String` | Custom sound file name |

### Sound Round-Trip

Custom sound names are stored in `userInfo["nnreminder_soundName"]` to survive the scheduling/loading round-trip. `.default` and `.critical` are inferred from the `UNNotificationSound` value. If `"nnreminder_soundName"` already exists in your `userInfo`, it will be overwritten.

### Usage Example

```swift
let reminder = CountdownReminder(
    id: UUID(), title: "Alert", message: "Custom sound",
    sound: .custom(name: "alarm.wav"),
    repeating: false, timeInterval: 60
)
```

---

## Enum: DayOfWeek

Represents days of the week aligned with `Calendar` weekday numbering (Sunday = 1).

```swift
public enum DayOfWeek: Int, CaseIterable, Identifiable, Sendable
```

### Cases

| Case | Raw Value | Description |
|------|-----------|-------------|
| `.sunday` | `1` | Sunday |
| `.monday` | `2` | Monday |
| `.tuesday` | `3` | Tuesday |
| `.wednesday` | `4` | Wednesday |
| `.thursday` | `5` | Thursday |
| `.friday` | `6` | Friday |
| `.saturday` | `7` | Saturday |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | `Int` | Same as `rawValue` |
| `name` | `String` | Localized weekday name from `DateFormatter().weekdaySymbols` |

### Locale Warning

`DayOfWeek.name` is locale-dependent. Day names are embedded in notification identifiers at schedule time and parsed back at load time. A device language change between scheduling and loading can cause weekday reminders to load as daily reminders (empty `daysOfWeek`).

---

## SwiftUI View Modifiers

### optionalNotificationPermissionsRequest

Requests notification permissions, then shows content regardless of the user's decision. Tracks permission status via a binding.

```swift
public func optionalNotificationPermissionsRequest<DetailView: View>(
    permissionGranted: Binding<Bool>,
    options: UNAuthorizationOptions = [.alert, .badge, .sound],
    debugEnabled: Bool = false,
    @ViewBuilder detailView: @escaping (@escaping () -> Void) -> DetailView
) -> some View
```

- Shows `detailView` (with a request callback) when status is `.notDetermined`
- Shows wrapped content for all other statuses (including `.denied`)
- Sets `permissionGranted = true` for `.authorized` or `.provisional`
- Creates a new `NnReminderManager` internally, forwarding `debugEnabled` to it

### requiredNotificationPermissionsRequest

Blocks content until permissions are granted. Shows a denied view when permissions are refused.

```swift
public func requiredNotificationPermissionsRequest<DetailView: View, DeniedView: View>(
    options: UNAuthorizationOptions = [.alert, .badge, .sound],
    debugEnabled: Bool = false,
    @ViewBuilder detailView: @escaping (@escaping () -> Void) -> DetailView,
    @ViewBuilder deniedView: @escaping (URL?) -> DeniedView
) -> some View
```

- Shows `detailView` when status is `.notDetermined`
- Shows wrapped content for `.authorized` or `.provisional`
- Shows `deniedView` for `.denied` — passes `UIApplication.openSettingsURLString` URL on iOS, `nil` on macOS
- No external `permissionGranted` binding

### Permission Modifier Comparison

| Behavior | `optional` | `required` |
|:---|:---|:---|
| Shows content after denial | Yes | No (shows `deniedView`) |
| External permission binding | Yes (`Binding<Bool>`) | No |
| macOS settings URL | N/A | `nil` (TODO in source) |
| `.provisional` treatment | Content + `permissionGranted = true` | Content shown |
| `debugEnabled` parameter | Yes (default `false`) | Yes (default `false`) |

### Usage Example — Optional Modifier

```swift
struct ReminderListScreen: View {
    @State private var permissionGranted = false

    var body: some View {
        ReminderListView()
            .optionalNotificationPermissionsRequest(
                permissionGranted: $permissionGranted
            ) { requestPermission in
                VStack {
                    Text("Enable notifications to get reminders")
                    Button("Allow", action: requestPermission)
                }
            }
    }
}
```

### Usage Example — Required Modifier

```swift
struct ReminderScreen: View {
    var body: some View {
        ReminderListView()
            .requiredNotificationPermissionsRequest { requestPermission in
                VStack {
                    Text("Notifications are required for reminders")
                    Button("Enable", action: requestPermission)
                }
            } deniedView: { settingsURL in
                VStack {
                    Text("Notifications are disabled")
                    if let url = settingsURL {
                        Link("Open Settings", destination: url)
                    }
                }
            }
    }
}
```

---

## NnReminderUITestHelpers

Separate library product for dismissing the iOS notification permission alert in UI tests. Add `NnReminderUITestHelpers` to your UI test target only.

### Enum: NotificationPermissionResponse

```swift
public enum NotificationPermissionResponse {
    case deny    // Tap "Don't Allow"
    case allow   // Tap "Allow"
}
```

### XCUIApplication Extension

```swift
extension XCUIApplication {
    public func handleNotificationPermissionAlert(
        _ response: NotificationPermissionResponse = .allow,
        timeout: TimeInterval = 3
    )
}
```

Taps the springboard notification permission alert button matching the given response. If the alert doesn't appear within the timeout, the method returns without action.

### Usage Example

```swift
import NnReminderUITestHelpers

let app = XCUIApplication()
app.launch()

// Allow notifications (default)
app.handleNotificationPermissionAlert()

// Deny notifications
app.handleNotificationPermissionAlert(.deny)
```

### Installation

Add to your UI test target's dependencies:

```swift
.testTarget(
    name: "YourAppUITests",
    dependencies: [
        .product(name: "NnReminderUITestHelpers", package: "NnReminderKit")
    ]
)
```

---

## Date Extensions

```swift
public extension Date {
    static func createReminderTime(hour: Int = 8, minute: Int = 0, date: Date = .init()) -> Date
    func addingDays(_ days: Int) -> Date
}
```

| Method | Returns | Description |
|--------|---------|-------------|
| `.createReminderTime(hour:minute:date:)` | `Date` | Creates a date with specific hour/minute on the given calendar date (defaults to today, 8:00 AM) |
| `.addingDays(_:)` | `Date` | Returns a new date offset by the specified number of days |

---

## Reminder Type Selection Guide

| Scenario | Type | Notes |
|:---|:---|:---|
| Fire after X seconds | `CountdownReminder` | Single request, time-interval trigger |
| Fire every day at a time | `WeekdayReminder.daily(...)` | Single calendar trigger, no weekday component |
| Fire once at next occurrence of a time | `WeekdayReminder.oneTime(...)` | Single calendar trigger, `repeats: false` |
| Fire on specific weekdays | `WeekdayReminder(daysOfWeek: [...])` | N requests (one per day), always repeating |
| Fire at specific future dates/times | `FutureDateReminder` | N requests, always non-repeating |
| Fire when entering/exiting a region | `LocationReminder` | iOS only, single request |

---

## Best Practices

- **Use `NnReminderManager` as the sole entry point** — All scheduling, canceling, and loading goes through this class. Initialize with `NnReminderManager()` for production.
- **Enable debug logging during development** — `NnReminderManager(debugEnabled: true)` prints `[NnReminderKit]`-prefixed details of every operation. Silent by default; leave the flag off in production.
- **Prefer async `throws` variants** — The completion-based overloads exist for non-async contexts but have subtle behavioral differences (e.g., completion fires per-request for multi-trigger reminders).
- **Empty `daysOfWeek` means daily** — Pass an empty array to `WeekdayReminder` for daily reminders. Use the `.daily()` and `.oneTime()` factory methods for clarity.
- **`requestAuthPermission` swallows errors** — Returns `false` on both denial and error. If you need to distinguish authorization errors from user denial, use `checkForPermissionsWithoutRequest()` after the request.
- **Multi-trigger scheduling is not atomic** — `WeekdayReminder` and `FutureDateReminder` add triggers individually. A failure mid-schedule leaves partial triggers with no automatic rollback.
- **Locale sensitivity in identifiers** — `DayOfWeek.name` uses locale-dependent weekday symbols. Changing the device language between scheduling and loading can corrupt weekday reminder reconstruction.
- **FutureDateReminder requires a primary date** — On reload, reminder groups without a `_primary` suffixed request are silently dropped. Ensure the primary date hasn't already fired if you need to reload.
- **Avoid duplicate `nnreminder_soundName` keys** — Custom `ReminderSound` stores its name in `userInfo` under this key. If your `userInfo` already contains this key, it will be overwritten.
- **Location reminders are iOS-only** — All `LocationReminder` and `LocationRegion` types are behind `#if os(iOS)`. Use conditional compilation when referencing them.
- **Use `cancelReminders(identifiers:)` for cross-type cancellation** — This is the only cancel method that does async prefix matching and can cancel any reminder type in a single call.
- **`WeekdayReminder.time` loses date on reload** — Only hour and minute are preserved. The `time` property on a loaded reminder uses today's date, not the original scheduling date.
