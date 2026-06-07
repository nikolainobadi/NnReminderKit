# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Facts

- Swift package for local notification scheduling on iOS 17+ / macOS 12+; no external dependencies
- API reference and usage patterns: use the `NnReminderKit` skill
- Testing conventions (makeSUT, behavior-driven Swift Testing): use the `NnTesting:swift-unit-tests` skill
- Location reminders are iOS-only — wrap in `#if os(iOS)`

## CI

- GitHub Actions (`ci.yml`) runs iOS and macOS tests in parallel using Xcode 16.2
- Note: backtick raw-identifier test names require Swift 6.2+ (Xcode 26) — CI Xcode version must be kept compatible

## Imports
@~/.claude/guidelines/style/shared-formatting-claude.md
