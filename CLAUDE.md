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

**A PR that changes the public API must update `Skills/` in the same PR.** The `skill-docs.yml`
workflow enforces this: it fails when `Sources/**/*.swift` gains or loses an API declaration line
while nothing under `Skills/` is touched. If a PR genuinely changes no documented behavior —
reformatting, renaming a local, moving a file — add the `skip-skill-check` label to waive it.

The check counts two kinds of changed line: one carrying an explicit `public`/`open`/`package`
keyword, and any changed `func`/`init`/`subscript`/`case` declaration. The second pattern exists
because most of this package's public surface is declared inside `public extension` blocks, where
member lines carry no visibility keyword of their own — a keyword-only check silently passes the
exact drift it is meant to catch. It over-fires on internal declarations instead, which the waiver
label handles.

**`Skills/NnReminderKit/.claude-plugin/plugin.json` deliberately has no `version` field.
Do not reintroduce one.** Git-based plugin sources are cached by commit sha, so the field buys
nothing and becomes a hand-maintained number that nothing verifies — the same staleness problem
co-location exists to solve. The version that matters is the marketplace entry's `ref`.

## Releasing

The marketplace entry for this skill is pinned to a **release tag**, not a branch. Consequence worth
internalizing: **documentation changes reach users on release, not on merge.** Merging a correction
to `Skills/` changes nothing for anyone until the next tag is cut.

`skill-ref-bump.yml` fires on tag push and opens a PR against
`nikolainobadi/nn-swift-skills` moving this skill's `ref` to the new tag. It can also be run
manually: `gh workflow run skill-ref-bump.yml -f tag=<tag>`.

If that automation is ever removed, the bump becomes manual and nothing will warn you it was
skipped — an unbumped `ref` serves the previous release's docs indefinitely, with no error and no
failing check.

### The shared token

`skill-ref-bump.yml` needs a `MARKETPLACE_TOKEN` repo secret: a fine-grained PAT with
`contents:write` and `pull-requests:write` on the marketplace repo and nothing else. **The same
token is shared across every package repo publishing to `nn-swift-skills`** (NnFileKit, NnShellKit,
NnSwiftUIKit, and this one), and is kept in `~/Coding/Service-or-Auth-Keys/`.

Expiry is not readable from the secret — `gh secret list` shows when the secret was last *set*, not
when the token expires. Check it at github.com/settings/tokens. When it lapses, the bump breaks in
**every** repo holding it and each needs the secret set again, so a failed bump run across several
repos means "rotate the shared token", not "this repo's workflow is broken".

## CI

- GitHub Actions (`ci.yml`) runs iOS and macOS tests in parallel using Xcode 16.2
- Note: backtick raw-identifier test names require Swift 6.2+ (Xcode 26) — CI Xcode version must be kept compatible
- `skill-docs.yml` runs on every PR (see "The skill lives here")
- `skill-ref-bump.yml` runs on tag push (see "Releasing")

## Imports
@~/.claude/guidelines/style/shared-formatting-claude.md
