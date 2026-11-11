# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Facts

- Swift package for local notification scheduling on iOS 17+ / macOS 14+; no external dependencies
- API reference and usage patterns: `Skills/NnReminderKit/` in this repo (see below)
- Testing conventions (makeSUT, behavior-driven Swift Testing): use the `NnTesting:swift-unit-tests` skill
- Location reminders are iOS-only — wrap in `#if os(iOS)`

## The skill lives here

`Skills/NnReminderKit/` is the published API reference for this package. It is served to Claude Code
through the `nn-swift-skills` marketplace as a `git-subdir` source pointing at that path, so the
copy in this repo *is* the copy consumers get. It used to live in a separate repo, where it drifted
out of date for months at a time; co-locating it is what ended that.

**A PR that changes the public API must update `Skills/` in the same PR.**

**`Skills/NnReminderKit/.claude-plugin/plugin.json` deliberately has no `version` field.
Do not reintroduce one.** Git-based plugin sources are cached by commit sha, so the field buys
nothing and becomes a hand-maintained number that nothing verifies — the same staleness problem
co-location exists to solve. The version that matters is the marketplace entry's `ref`.

## Releasing

The marketplace entry for this skill is pinned to a **release tag**, not a branch. Consequence worth
internalizing: **documentation changes reach users on release, not on merge.** Merging a correction
to `Skills/` changes nothing for anyone until the next tag is cut.

The marketplace ref bump is manual; this repo has no tag-push workflow to update it. An unbumped
`ref` serves the previous release's docs indefinitely, with no error and no failing check.

Release preparation is configured in `.nnex/nnex.json`, with a library target at `.` and
`Skills/NnReminderKit` as its reference skill. Its build and test commands are declared there.

## CI

- GitHub Actions (`ci.yml`) runs iOS and macOS tests in parallel on `macos-26` using Xcode 26.5
- Note: backtick raw-identifier test names require Swift 6.2+ (Xcode 26) — CI Xcode version must be kept compatible

## Imports
@~/.claude/guidelines/style/shared-formatting-claude.md
