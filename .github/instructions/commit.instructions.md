---
description: 'Generate clear, consistent commit messages and commit safely when asked'
applyTo: '**/*'
---

# Commit

Commit changes with a message that follows project conventions.

- If the user asks only for a commit message, output the message as a code block and stop.
- If the user provides their own commit message and asks to commit with it, use their message verbatim without reformatting or adding emojis,
  subject only to the Attribution Rules below.
- If the user asks to commit changes, follow this checklist in order:
  1. Determine the files to stage. If the user specifies a subset of files, use only those paths.
  2. Check for modified or untracked files in the selected scope. If none exist, inform the user that the working tree is clean and stop.
  3. Show the proposed commit message and the file list, then ask for explicit confirmation. If the user asks to amend the last commit, show
     the current HEAD message pre-populated for editing alongside any newly staged files.
  4. If confirmed, stage files. When a subset is specified, run `git add <specified paths>` rather than `git add .` or `git add -A`.
  5. Run `git commit`, or `git commit --amend` when amending.
  6. If commit is declined, ask whether to revise the message, adjust the file list, or cancel.
  7. If `git commit` exits with a non-zero status, display the full error output, explain the likely cause when identifiable, and do not
     retry automatically.
- Never run `git push` unless the user explicitly requests it.

## Message Format

Always prioritize project-specific conventions for commit messages when they are known. If the project follows [Conventional
Commits](https://www.conventionalcommits.org/), apply the full specification: use the `type(scope):` subject prefix, include
`BREAKING CHANGE:` footers when applicable, and omit the emoji prefix (since the type token serves the same purpose). Otherwise, use the
general format guidelines below.

**Format:**

```text
Imperative subject line, ≤50 characters

Optional body — include only when the subject alone does not tell a reader why the change exists; omit entirely for small, obvious changes.
Wrap body text to 76 columns per line.
```

When you are generating or revising the commit message, prefix the subject line with a single emoji that best matches the change type. If the
change type does not match any of the listed categories and no single widely-recognized emoji unambiguously describes it, omit the emoji
entirely rather than choosing an approximate one.

Subject line must be 50 characters or fewer. When an emoji is present, count it as 2 characters and write the remaining plain text in 48
characters or fewer.

Emoji by change type samples:
  - ✨ for new features
  - 🐛 for bug fixes
  - 📝 for documentation changes
  - 🔧 for configuration changes
  - 🚀 for performance improvements
  - 🗑️ for removing code or files
  - 🤖 for automation-related artifacts

## Attribution Rules

- Never mention AI, Copilot, Claude, LLMs, or similar tooling in the commit message unless the user's provided message contains such attribution.
- Never add co-authorship lines unless the user explicitly asks for them.
