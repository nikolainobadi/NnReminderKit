# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NnReminderKit is a Swift package that simplifies the scheduling and management of local notifications on Apple platforms (iOS 17+ and macOS 12+). It provides a SwiftUI-friendly API for handling permissions, scheduling, canceling, and loading pending reminders.

## Build and Test Commands

### Swift Package Manager
```bash
# Build the package
swift build

# Run all tests
swift test

# Build for specific platform
swift build --destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

### Xcode Commands
```bash
# Run iOS tests
xcodebuild test -scheme NnReminderKit -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.3.1'

# Run macOS tests
xcodebuild test -scheme NnReminderKit -destination 'platform=macOS,arch=arm64'

# Run tests with formatted output (requires xcpretty)
xcodebuild test -scheme NnReminderKit -destination 'platform=iOS Simulator,name=iPhone 16 Pro' | xcpretty
```

## Architecture

### Core Design Patterns
- **Facade Pattern**: `NnReminderManager` provides the main API interface
- **Adapter Pattern**: `NotifCenterAdapter` wraps `UNUserNotificationCenter` for testability
- **Factory Pattern**: `NotificationRequestFactory` creates notification requests
- **Protocol-Oriented**: All reminder types conform to `Reminder` protocol
- **Dependency Injection**: Uses protocol abstractions for testing with `MockCenter`

### Key Components

**Manager Layer** (`Sources/NnReminderKit/Manager/`)
- `NnReminderManager`: Main facade providing scheduling, canceling, and loading operations
- `NotifCenterAdapter`: Concrete implementation of `NotifCenter` protocol

**Model Layer** (`Sources/NnReminderKit/Models/`)
- `Reminder`: Base protocol for all reminder types
- `CountdownReminder`: Time-interval based notifications
- `WeekdayReminder`: Recurring calendar-based notifications (multi-trigger)
- `LocationReminder`: Geofenced notifications (iOS only)
- `FutureDateReminder`: Future date notifications (multi-trigger)
- `MultiTriggerReminder`: Protocol for reminders that create multiple notifications

**SwiftUI Integration** (`Sources/NnReminderKit/SwiftUI/`)
- `OptionalReminderPermissionViewModifier`: View modifier that requests permissions first, then shows content regardless of decision
- `RequiredReminderPermissionViewModifier`: View modifier that blocks content until permissions are granted, shows denied view if refused
- `ShowNotificationSettingsButton`: Reusable component for opening system notification settings
- `ReminderPermissionRequestViewModifier`: DEPRECATED - use optional or required modifiers instead
- `ReminderPermissionENV`: Environment key for permission state management

### Testing Architecture
- Uses Swift's new Testing framework (not XCTest)
- All tests are in `Tests/NnReminderKitTests/UnitTests/`
- `TestModelFactory` provides test data creation utilities
- `MockCenter` implements `NotifCenter` protocol for testing

## Development Notes

### Platform Requirements
- iOS 17.0+ / macOS 12.0+
- Swift 6.0+
- No external dependencies

### Multi-Trigger Reminder Implementation
Reminders conforming to `MultiTriggerReminder` (WeekdayReminder, FutureDateReminder) create multiple notification requests. Each request's identifier is prefixed with the reminder's UUID for grouped cancellation.

### Location Reminders
Location-based reminders are iOS-only. Use `#if os(iOS)` compilation directives when working with location features.

### CI/CD Configuration
GitHub Actions workflow (`ci.yml`) runs tests on both iOS and macOS platforms in parallel using Xcode 16.2.

### SwiftUI Permission Handling
Two view modifiers are available for handling notification permissions:
- `.optionalNotificationPermissionsRequest()`: Requests permissions first, then shows content regardless of decision. Includes binding to track permission status.
- `.requiredNotificationPermissionsRequest()`: Blocks content until permissions are granted, shows denied view when rejected
- `ShowNotificationSettingsButton`: Standalone component for navigating to system notification settings

Both modifiers automatically handle authorization states. The required modifier provides direct navigation to Settings when permissions are denied.

## Public API Expectations
- Clear, well-documented public interfaces
- Semantic versioning for breaking changes
- Comprehensive examples in documentation

## Package Testing
- Behavior-driven unit tests (Swift Testing preferred)
- Use `makeSUT` pattern for test organization
- Track memory leaks with `trackForMemoryLeaks`
- Type-safe assertions (`#expect`, `#require`)
- Use `waitUntil` for async/reactive testing

## Imports
@~/.claude/guidelines/style/shared-formatting-claude.md
@~/.claude/guidelines/testing/base_unit_testing_guidelines.md
