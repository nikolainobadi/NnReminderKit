# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2025-09-21

### Added
- `LocationReminder` for geofenced notifications (iOS only)
- `FutureDateReminder` type for scheduling notifications on specific future dates
- `MultiTriggerReminder` protocol for reminders that create multiple notifications
- `TriggerInfoFactory` for managing multi-trigger reminder logic
- `OptionalReminderPermissionViewModifier` for non-blocking permission requests with binding support
- `RequiredReminderPermissionViewModifier` for content-blocking permission requests
- `ShowNotificationSettingsButton` reusable component for opening system notification settings
- `PermissionModifierHelpers` utility for reducing code duplication in SwiftUI modifiers
- Enhanced CI/CD workflow with parallel iOS and macOS testing
- Comprehensive unit tests for new reminder types and permission handling
- `CLAUDE.md` documentation for project architecture and build instructions

### Changed
- Renamed `CalendarReminder` back to `WeekdayReminder` for clarity
- Enhanced SwiftUI permission handling with separate optional and required modifiers
- Updated minimum macOS version requirement to 14.0
- Improved CI workflow with matrix builds and xcpretty formatting
- Expanded `NnReminderManager` with methods for location and future date reminders
- Enhanced documentation with comprehensive usage examples

### Deprecated
- `requestReminderPermissions` view modifier (use `optionalNotificationPermissionsRequest` or `requiredNotificationPermissionsRequest` instead)

## [1.0.0] - 2025-04-02

### Changed
- Simplified API by removing multi-trigger reminder support
- Renamed `WeekdayReminder` back to `CalendarReminder`
- Streamlined `NnReminderManager` interface with fewer, more focused methods
- Reduced complexity in notification request factory
- Updated minimum iOS version requirement

### Removed
- `FutureDateReminder` type
- `MultiTriggerReminder` protocol
- `TriggerInfoFactory` utility
- `ReminderSound` customization
- `DecodedReminderContent` internal type
- Multiple trigger support for calendar-based reminders

## [0.8.0] - 2025-04-25

### Added
- Swift 6 language support and concurrency improvements
- Swift Testing framework for unit tests (replacing XCTest)
- `FutureDateReminder` type for scheduling notifications on specific future dates
- `MultiTriggerReminder` protocol for reminders that create multiple notifications
- `TriggerInfoFactory` for managing multi-trigger reminder logic
- UUID-based reminder identification for improved integrity
- `cancelReminders(identifier:)` method for canceling reminders by UUID
- `addingDays` helper method to `Date` extension
- CI/CD workflow with GitHub Actions
- Unit tests for `ReminderPermissionENV`

### Changed
- Renamed `CalendarReminder` to `WeekdayReminder` for clarity
- Updated to iOS 17 minimum deployment target
- Fixed threading issues in `NnReminderManager`
- Fixed `ReminderSound` encoding and decoding
- Expanded `Reminder` properties for more customization options

### Fixed
- Escaping argument issues in detail views
- Thread safety in reminder manager operations

## [0.5.1] - 2025-03-08

### Fixed
- Added sorting to `dayOfWeekText` for consistent display order

## [0.5.0] - 2025-03-07

### Added
- Initial release of NnReminderKit
- `CountdownReminder` for time-based notifications
- `CalendarReminder` for recurring weekly notifications
- `NnReminderManager` for scheduling and managing reminders
- `NotifCenterAdapter` for UserNotifications framework integration
- SwiftUI view modifier for requesting reminder permissions
- Async/await support for all reminder operations
- Load methods for fetching pending reminders
- Identifiable protocol conformance for reminders
- Date formatting extensions
- Preview helpers for SwiftUI development

[Unreleased]: https://github.com/nikolainobadi/NnReminderKit/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/nikolainobadi/NnReminderKit/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/nikolainobadi/NnReminderKit/compare/v0.8.0...v1.0.0
[0.8.0]: https://github.com/nikolainobadi/NnReminderKit/compare/v0.5.1...v0.8.0
[0.5.1]: https://github.com/nikolainobadi/NnReminderKit/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/nikolainobadi/NnReminderKit/releases/tag/v0.5.0