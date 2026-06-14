---
name: commit
description: Prompt and workflow for generating clear, consistent commit messages.
argument-hint: '[--force]'
---

# Commit

Commits are a historical record of exactly **how** and **why** each line of code came to be. The history of a good repository commit can
help developers track bugs and understand why code looks the way it does. Ultimately, it can even be used for
[automatically generated release notes](https://docs.github.com/en/repositories/releasing-projects-on-github/automatically-generated-release-notes).
Therefore, it is good practice to have some conventions for how our `git commit` should be formatted, which leads to more readable and
easier-to-follow messages when looking at project history.

The conventions for messages are inspired by [http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
and follow the general guidelines below:

- Avoid undescriptive one-liner commit messages
- The first line should be short (50 characters or less) and express intention _(what does this accomplish?)_
- Write the commit message in present imperative tense: "Fix bug" and not "Fixed bug"
- The second line is blank
- Next line optionally defines a summary of changes done, the commit body, and should focus on _Why_, not the _What_.
  - Context
  - Justification
- Wrap the body at 76 characters columns per line

## Usage Scenarios

- `/commit`
- `/commit --force`

`force` = **true** if `--force` is present in the arguments.

## Workflow

Pre-flight check: If `force` is **true**, execute Steps 1, 2, and 4 in sequence without pausing. Skip Step 3 entirely. This allows users to
bypass the review process when they are confident in their changes and want to commit quickly.

### 1. Review Changes

**Follow these steps:**

1. Run `git status` to review changed files.
2. Run `git diff` or `git diff --cached` to inspect changes.
3. Run `git log --oneline -10` to review recent commit history for context.
4. Stage your changes with `git add <file>`.
5. Construct your commit message using the format defined below.

- If any git command in Step 1 exits with a non-zero code, show the error output to the user and stop. Do not proceed to generate a commit message.
- If `git status` shows a clean working tree with nothing staged, tell the user there is nothing to commit and stop.
- If files are already staged (`git diff --cached` shows output), commit only those staged files unless the user explicitly asks to include
additional unstaged files. Do not stage additional files without user confirmation.
- When `force` is **true** and Step 3 is skipped, treat all files that were unstaged (but not untracked) at the time of `git status` as
implicitly confirmed for staging. Never stage untracked files without explicit user confirmation.

### 2. Write Commit Message

**Format:**

```text
Imperative subject line, ≤50 characters

Optional body — include only when the subject alone does not tell a reader why the change exists; omit entirely for small, obvious changes.
Wrap body text to 76 columns per line.

Prefix the subject line with a single emoji that matches the change type from the list below. If no emoji in the list fits the change,
omit the emoji entirely. Count each emoji as 2 characters toward the 50-character subject limit, based on visible terminal width
(grapheme cluster width). When in doubt, keep the subject including the emoji to 48 characters of plain text to leave margin.

Examples:
  - ✨ for new features
  - 🐛 for bug fixes
  - 📝 for documentation changes
  - 🔧 for configuration changes
  - 🚀 for performance improvements
  - 🗑️ for removing code or files
  - 🤖 for automation-related artifacts
```

**Subject line rules:**

- Start with an imperative verb: "Add", "Fix", "Remove", "Update", "Refactor", etc.
- No period at the end
- Describe the final state — what the code does now, not what it replaced
- If the user explicitly provides an exact subject line in their request, use it verbatim (trim whitespace; do not rephrase)
- The explicit user-provided subject line rule takes precedence over automatic emoji prefixing

**Attribution rules (non-negotiable):**

- Never mention AI, Claude, Copilot, or LLMs anywhere in the message
- Never add co-authorship lines

### 3. Show Preview and Confirm

Display the proposed commit exactly as shown below, then stop and wait for the user to reply:

```text
Files to commit:
  staged:    <list, or "(none)">
  unstaged:  <list, or "(none)">
  untracked: <list, or "(none)">

Commit message:
  <subject line>

  <body, if any>
```

Never stage untracked files automatically. If untracked files are present, note them in the preview but do not offer to add them unless
the user explicitly asks. Under `force`, always skip untracked files.

Ask: "Commit with this message? Reply yes to confirm, or describe any changes."

Do not proceed until the user replies. If the user requests changes, update the message and show the full preview again before asking once
more.

If the user replies with "no", "cancel", "abort", or any equivalent, tell the user the commit has been cancelled and stop. Do not commit.

### 4. Commit

Stage specific files by name. Do not use `git add -A` or `git add .`.

In Step 4, only `git add` files that were unstaged at the time of preview and that the user confirmed should be included. Do not re-add
files already listed under staged.

Use absolute paths in all bash commands.

Write the full commit message (subject, blank line, and wrapped body) to a temporary file named `commit-msg.txt` in the repo root,
then pass it to `git commit` with `--file`. This ensures the 76-column body wrapping is preserved exactly as composed, since `-m` does not
honour embedded newlines reliably across shells.

Before writing `commit-msg.txt`, check whether it already exists. If it does, warn the user and stop. Do not overwrite an existing
`commit-msg.txt`.

If writing `commit-msg.txt` fails, show the error to the user, skip the `git commit` call, and stop. Do not attempt to fall back to `-m`.

#### bash/Linux/macOS:

```bash
git add <absolute path to each file>
git commit --file commit-msg.txt
rm commit-msg.txt
```

#### PowerShell/Windows:

```powershell
git add <absolute path to each file>
git commit --file commit-msg.txt
Remove-Item commit-msg.txt
```

If the commit succeeds, delete `commit-msg.txt`. If the commit fails, keep `commit-msg.txt` for troubleshooting and stop.

If deletion of `commit-msg.txt` fails after a successful commit, show a warning with the file path and ask the user to delete it manually.
Do not treat this as a commit failure.

### 5. Report Result

On success, show the short commit hash and subject line.

On failure, show the full error output, tell the user whether `commit-msg.txt` was kept, and stop.
