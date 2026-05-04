---
description: 'Generate clear, consistent commit messages and commit safely when asked'
applyTo: '**/*'
---

# Commit Message Instructions

When the user asks for a commit message or asks to commit changes, follow this workflow.

## Goal

Produce commit messages that are clear, intentional, and easy to scan in project history.

## Message Format

Use this structure:

```text
<imperative subject line, 50 characters or less>

<optional body wrapped at 76 columns>
```

## Subject Line Rules

- Use present imperative tense: `Add`, `Fix`, `Update`, `Refactor`, `Remove`, etc.
- Describe the final state, not the diff or past action.
- Do not end the subject with a period.
- Keep the first line at 50 characters or less.
- If the user provides an exact message to use, preserve it verbatim after trimming whitespace.

## Body Rules

- Omit the body for small, obvious changes.
- If included, explain why the change exists more than what changed.
- Good body content includes context, justification, or implementation notes.
- Wrap body lines at 76 characters.

## Emoji Guidance

Use emojis when they improve scanning. Examples:

- `✨` for new features
- `🐛` for bug fixes
- `📝` for documentation changes
- `🔧` for configuration changes
- `🚀` for performance improvements
- `🗑️` for removing code or files
- `🤖` for AI-related artifacts

## Attribution Rules

- Never mention AI, Copilot, Claude, LLMs, or similar tooling in the commit message.
- Never add co-authorship lines unless the user explicitly asks for them.
