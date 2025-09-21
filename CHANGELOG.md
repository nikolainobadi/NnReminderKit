# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
