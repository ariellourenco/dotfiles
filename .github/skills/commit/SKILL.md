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
  - Implementation
- Wrap the body at 76 characters columns per line

## Usage Scenarios

- `/commit`
- `/commit --force`

`force` = **true** if `--force` is present in the arguments. If `force` is true, skip the preview and confirmation step and commit immediately
with the provided message. This allows users to bypass the review process when they are confident in their changes and want to commit quickly.

## Workflow

### 1. Review Changes

**Follow these steps:**

1. Run `git status` to review changed files.
2. Run `git diff` or `git diff --cached` to inspect changes.
3. Run `git log --oneline -10` to review recent commit history for context.
4. Stage your changes with `git add <file>`.
5. Construct your commit message using the format defined below.

If `git status` shows a clean working tree with nothing staged, tell the user there is nothing to commit and stop.

### 2. Write Commit Message

**Format:**

```text
Imperative subject line, ≤50 characters

Optional body — include only when the subject alone does not tell a reader why the change exists; omit entirely for small, obvious changes.
Wrap body text to 76 columns per line.

Use emojis when possible to convey the type of change made. For example:
  - ✨ for new features
  - 🐛 for bug fixes
  - 📝 for documentation changes
  - 🔧 for configuration changes
  - 🚀 for performance improvements
  - 🗑️ for removing code or files
  - 🤖 for AI related artifacts
```

**Subject line rules:**

- Start with an imperative verb: "Add", "Fix", "Remove", "Update", "Refactor", etc.
- No period at the end
- Describe the final state — what the code does now, not what it replaced
- If `message_hint` is non-empty, use it verbatim as the subject line (trim whitespace; do not rephrase)

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

Ask: "Commit with this message? Reply yes to confirm, or describe any changes."

Do not proceed until the user replies. If the user requests changes, update the message and show the full preview again before asking once
more.

If `force` is **true**, skip to Step 4 immediately — do not show a preview or ask for confirmation.

### 4. Commit

Stage specific files by name. Do not use `git add -A` or `git add .`.

Use absolute paths in all bash commands.

Write the full commit message (subject, blank line, and wrapped body) to a temporary file named `commit-msg.txt` in the repo root,
then pass it to `git commit` with `--file`. This ensures the 76-column body wrapping is preserved exactly as composed, since `-m` does not
honour embedded newlines reliably across shells.

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

Always delete `commit-msg.txt` after the commit, whether it succeeded or failed, to avoid leaving stale files in the working tree.

### 5. Report Result

On success, show the short commit hash and subject line. On failure, show the full error output and stop.
