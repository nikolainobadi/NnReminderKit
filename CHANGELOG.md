# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.5.1] - 2026-08-22

### Added
- `Skills/NnReminderKit/` — the published API reference now lives in this repo and is served through the `nn-swift-skills` marketplace, so it changes in the same PR as the API it documents
- `skill-docs.yml` workflow: fails a PR that changes the public API without touching `Skills/`; waivable with the `skip-skill-check` label
- `skill-ref-bump.yml` workflow: points the marketplace entry at the new tag on release

### Fixed
- CLAUDE.md and the README platform badge stated a macOS 12+ minimum; `Package.swift` declares macOS 14+
- README documented `ShowNotificationSettingsButton`, a type deleted from `Sources/` in September 2025; replaced the example with the `settingsURL` the `deniedView` closure actually receives

## [1.5.0] - 2026-06-06

### Added
- Opt-in debug logging via a `debugEnabled` flag (default `false`) on `NnReminderManager` initializers and the permission view modifiers (`optionalNotificationPermissionsRequest`, `requiredNotificationPermissionsRequest`). Logs permission, scheduling, canceling, and loading details to the console with an `[NnReminderKit]` prefix. Silent by default.

### Changed
- Completion handlers on `scheduleCountdownReminder`, `scheduleWeekdayReminder`, and `scheduleLocationReminder` are now marked `@Sendable`, matching the `UNUserNotificationCenter` contract

## [1.4.0] - 2026-04-12

### Added
- `NnReminderUITestHelpers` library product for dismissing the iOS notification permission alert in UI tests, including the `XCUIApplication+NotificationPermissions` extension and the `NotificationPermissionResponse` enum (`.allow` / `.deny`)
- Documentation for the UI test helpers in README and CLAUDE.md

## [1.3.0] - 2025-12-02

### Changed
- All reminder types now play the default system sound by default when the `sound` parameter is not specified
- Updated default value for `sound` parameter from `nil` to `.default` across all reminder initializers (CountdownReminder, WeekdayReminder, FutureDateReminder, LocationReminder)

## [1.2.0] - 2025-12-01

### Added
- Daily repeating reminders using `WeekdayReminder` with empty `daysOfWeek` array
- One-time reminders that fire once at the next occurrence of a specific time
- Convenience factory method `WeekdayReminder.daily()` for creating daily repeating reminders
- Convenience factory method `WeekdayReminder.oneTime()` for creating one-time reminders
- `loadAllDailyReminders()` method to load only daily repeating reminders
- `loadAllOneTimeReminders()` method to load only one-time reminders
- `loadAllWeeklyReminders()` method to load only weekly reminders with specific days
- Comprehensive documentation for daily reminder patterns in README and CLAUDE.md

### Fixed
- `WeekdayReminder` now correctly respects the `repeating` flag when creating one-time reminders

## [1.1.0] - 2025-09-21

### Added
- OptionalReminderPermissionViewModifier for flexible permission handling that shows content regardless of permission decision
- RequiredReminderPermissionViewModifier for mandatory permission workflows that blocks content until permissions granted
- CLAUDE.md with comprehensive project architecture and build instructions
- CHANGELOG.md with complete version history and release notes

### Changed
- Refactored permission view modifiers with consolidated permission check tasks
- Made RequiredReminderPermissionViewModifier properties private for better encapsulation
- Updated SwiftUI modifier descriptions for improved clarity
- Enhanced README documentation with new permission modifier examples and usage patterns
- Updated Package.swift configuration

## [1.0.0] - 2025-05-11

### Added
- Location reminders (iOS only) using `LocationReminder` and `LocationRegion`
- Ability to retrieve and cancel location-based notifications
- Full macOS compatibility (macOS 12+)
- GitHub Actions CI now tests on both iOS and macOS

### Changed
- Location triggers are excluded from macOS builds using conditional compilation

### Removed
- Several deprecated test files and utilities

## [0.8.0] - 2025-04-26

### Added
- Permission handling with customizable SwiftUI view modifier for notification permissions
- Countdown reminders for one-time local notifications based on time intervals
- Calendar reminders for recurring notifications on specific weekdays
- Reminder time helpers for generating Date instances without manual DateComponents setup
- Pending reminder management with load, inspect, and cancel capabilities
- Concurrency-ready API built entirely using Swift async/await
- Test-friendly abstractions with decoupled notification management logic

## [0.5.1] - 2025-03-08

### Changed
- Updated `dayListText` in CalendarReminder extensions to ensure day names are always sorted in weekday order
- Enhanced consistency when displaying selected reminder days

## [0.5.0] - 2025-03-07

### Added
- Initial release of NnReminderKit
- Countdown reminders for one-time notifications after set time intervals
- Calendar reminders for recurring notifications on specific days of the week
- Notification permission handling with SwiftUI view modifier
- Async APIs for loading pending reminders
- Date extensions for easily generating reminder times
- Abstracted notification center for improved unit testing
- Comprehensive documentation and examples

[Unreleased]: https://github.com/nikolainobadi/NnReminderKit/compare/1.5.1...HEAD
[1.5.1]: https://github.com/nikolainobadi/NnReminderKit/compare/1.5.0...1.5.1
[1.5.0]: https://github.com/nikolainobadi/NnReminderKit/compare/1.4.0...1.5.0
[1.4.0]: https://github.com/nikolainobadi/NnReminderKit/compare/1.3.0...1.4.0
[1.3.0]: https://github.com/nikolainobadi/NnReminderKit/compare/1.2.0...1.3.0
[1.2.0]: https://github.com/nikolainobadi/NnReminderKit/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/nikolainobadi/NnReminderKit/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/nikolainobadi/NnReminderKit/compare/0.8.0...1.0.0
[0.8.0]: https://github.com/nikolainobadi/NnReminderKit/compare/0.5.1...0.8.0
[0.5.1]: https://github.com/nikolainobadi/NnReminderKit/compare/0.5.0...0.5.1
[0.5.0]: https://github.com/nikolainobadi/NnReminderKit/releases/tag/0.5.0
