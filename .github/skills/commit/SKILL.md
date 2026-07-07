---
name: commit
description: Prompt and workflow for generating clear, consistent commit messages.
model: haiku
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

## Workflow

Never run `git push`; only do so if the user explicitly asks for it in this request.

If the user asks only for a commit message and not to commit, perform Steps 1–2, then output the message as a fenced code block and stop.
Do not proceed to Step 3 or Step 4.

### 1. Review Changes

**Follow these steps:**

1. Run `git status` to review changed files.
2. Run `git diff` or `git diff --cached` to inspect changes.
3. Run `git log --oneline -10` to review recent commit history for context.
4. Stage your changes with `git add <file>`.
5. Construct your commit message using the format defined below:

- If `git log --oneline -10` fails because the repository has no commits yet, treat the history as empty and continue.
- If any other git command in Step 1 exits with a non-zero code, show the error output to the user and stop. Do not proceed to generate a
  commit message.
- If `git status` shows no staged, unstaged, or untracked changes, tell the user there is nothing to commit and stop.
- If a merge is in progress (`.git/MERGE_HEAD` exists), tell the user this workflow doesn't support merge commits and stop.
- If files are already staged (`git diff --cached` shows output), commit only those staged files unless the user explicitly asks to include
  additional unstaged files. Do not stage additional files without user confirmation. Never stage untracked files without explicit user
  confirmation.
- Inspect the last 10 subject lines from `git log --oneline -10`. If most of them follow the [Conventional Commits](https://www.conventionalcommits.org/)
  pattern (`type(scope): description` or `type: description`), use the Conventional Commits format in Step 2 instead of the emoji format.

### 2. Write Commit Message

If Step 1 detected that the project follows Conventional Commits, use the **Conventional Commits format**. Otherwise, use the **emoji
format**. Both share the subject-line length limit, body wrapping, and attribution rules below.

**Conventional Commits format:**

```text
type(scope): imperative subject line, ≤50 characters total

Optional body — include only when the subject alone does not tell a reader why the change exists; omit entirely for small, obvious changes.
Wrap body text to 76 columns per line.

BREAKING CHANGE: <description of the break>
```

Use a `type` consistent with the ones seen in `git log --oneline -10` (e.g. `feat`, `fix`, `docs`, `refactor`, `chore`, `perf`, `test`).
Include `scope` only when the recent history uses scopes. Omit the emoji prefix — the type token already conveys the change type. Include
the `BREAKING CHANGE:` footer only when this commit introduces a breaking change.

**Emoji format:**

```text
Imperative subject line, ≤50 characters

Optional body — include only when the subject alone does not tell a reader why the change exists; omit entirely for small, obvious changes.
Wrap body text to 76 columns per line.
```

Prefix the subject line with a single emoji matching the change type from the list below. If no emoji in the list fits the change, omit the
emoji entirely. Count the emoji as 2 characters toward the 50-character subject limit — keep the plain-text portion to 48 characters or
fewer when an emoji is present.

Emoji by change type:
  - ✨ for new features
  - 🐛 for bug fixes
  - 📝 for documentation changes
  - 🔧 for configuration changes
  - 🚀 for performance improvements
  - 🗑️ for removing code or files
  - 🤖 for automation-related artifacts

**Subject line rules:**

- After the emoji or `type(scope):` prefix (if any), the first word must be an imperative verb, E.g.: "Add", "Fix", "Remove", "Update", etc.
- No period at the end
- Describe the final state — what the code does now, not what it replaced
- If the user explicitly provides an exact subject line, or a full message (subject and body), in their request, use it verbatim (trim
  whitespace; do not rephrase, reformat, or add an emoji or type prefix), subject only to the Attribution Rules below.
- The explicit user-provided message rule takes precedence over both formats above.

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
the user explicitly asks.

Ask: "Commit with this message? Reply yes to confirm, or describe any changes to the message or file list."

Do not proceed until the user replies. If the user requests changes to the message or the file list, update accordingly and show the full
preview again before asking once more.

If the user replies with "no", "cancel", "abort", or any equivalent, tell the user the commit has been cancelled and stop. Do not commit.

### 4. Commit

Stage specific files by name. Do not use `git add -A` or `git add .`.

In Step 4, only `git add` files that were unstaged at the time of preview and that the user confirmed should be included. Do not re-add
files already listed under staged.

If `git add` exits with a non-zero code, show the error output, do not proceed to `git commit`, and keep `commit-msg.txt` for retry.

Use absolute paths in all bash/powershell commands.

Write the full commit message (subject, blank line, and wrapped body) to a temporary file named `commit-msg.txt` in the repo root,
then pass it to `git commit` with `--file`. This ensures the 76-column body wrapping is preserved exactly as composed, since `-m` does not
honour embedded newlines reliably across shells. Before writing `commit-msg.txt`, check whether it already exists. If it does, tell the user
it may be left over from a previous failed commit and ask whether to overwrite it or cancel. Do not overwrite it without that confirmation.

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

- On success, show the short commit hash and subject line.
- On failure, show the full error output, explain the likely cause when identifiable (e.g. a pre-commit hook rejection, a GPG signing
  failure, or nothing left staged), tell the user whether `commit-msg.txt` was kept, and stop.
