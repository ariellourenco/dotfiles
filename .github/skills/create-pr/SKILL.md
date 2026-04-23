---
name: "create-pr"
description: >
  Create a pull request using the repository PR template. Use when asked to:
  create PR, open PR, push and create PR, submit PR, open pull request, send changes for review.
argument-hint: '[--draft] [--force] [<title>]'
---

# Create Pull Request

Pull requests are like the life blood of a repository. They keep everything healthy and moving. This SKILL details how to create a PR that
is complete and easy to review.

## Arguments

- `--draft` — create the PR as a draft
- `--force` — skip preview and confirmation; create or update immediately
- `<title>` — optional title hint; if omitted, derive from commits

Example invocations:

- `/create-pr`
- `/create-pr --draft`
- `/create-pr --force`
- `/create-pr Add support for webhook retries`
- `/create-pr --draft Fix race condition in job queue`
- `/create-pr --force --draft Fix race condition in job queue`

## Workflow

### 1. Parse Arguments

Extract from user input:

- `draft` = **true** if `--draft` is present
- `force` = **true** if `--force` is present
- `title` = remaining text after stripping `--draft` and `--force`, or empty string

### 2. Prepare Your Branch

- Confirm the current branch name with `git branch --show-current`.
- Ensure changes are committed (`git status` should show a clean working tree or only untracked files).
- Push the branch with `git push -u origin <branch-name>`. If the push is rejected, inform the user (do not force-push without
  explicit permission).

#### Gathering Information

- **Head branch**: current branch unless the user specifies otherwise.
- **Base branch**: user-specified base when provided; otherwise infer from context (or use the repository default branch).

With the base branch identified, fetch the latest changes:

```bash
git log origin/<base-branch>..HEAD --oneline                            # commits on this branch
git diff origin/<base-branch>...HEAD                                    # full diff vs base
gh pr view --json number,title,body,isDraft,url 2>/dev/null             # existing PR, if any
```

If a PR already exists, note its number and URL — you will update it rather than create a new one, see [Step 7](#7-update-existing-pr).

### 3. Find PR Template

Check these locations in order and stop at the first match:

1. `.github/pull_request_template.md`
2. `.github/PULL_REQUEST_TEMPLATE.md`
3. `docs/pull_request_template.md`
4. `pull_request_template.md`

### 4. Compose PR Body

If a template was found, fill each section using the commits and diff:

- Use the template structure as the PR body.
- Fill known details in `## Description` (summary, motivation/context, dependencies, validation).
  Describe final state — What change your PR adds.
- Remove unfilled optional sections rather than leaving placeholder text.
- Leave checkboxes intact; check the ones clearly satisfied by the diff.
- **Never hard-wrap prose** — write each paragraph as a single line and let GitHub's renderer handle wrapping; only insert newlines between
  paragraphs, list items, or headings.

If no template was found, the summary should include things like:

- What change your PR adds.
- Problem it solves, motivation, or context.

Write the body to a temporary file named `pr-body.md` in the repo root.

### 5. Show Preview and Confirm

If `force` is true, skip to [Step 6](#6-create-pr) immediately — do not show a preview or ask for confirmation.

Otherwise, display the proposed PR to the user:

```text
Title: <title>
Draft: yes/no

<body>
```

Ask: "Create this PR? Reply yes to confirm, or describe any changes to make."

Wait for confirmation. If the user requests edits, apply them and show the updated preview before proceeding.

### 6. Create PR

Set `GH_PAGER` to `cat` to prevent interactive paging, then create the PR. The syntax differs by shell:

#### bash/Linux/macOS:

```bash
GH_PAGER=cat gh pr create \
  --base <base-branch> \
  --head <head-branch> \
  --title "<pr-title>" \
  --body-file pr-body.md
```

#### PowerShell/Windows:

```powershell
$env:GH_PAGER = "cat"
gh pr create `
  --base <base-branch> `
  --head <head-branch> `
  --title "<pr-title>" `
  --body-file pr-body.md
```

> [!NOTE]
> - **Why `GH_PAGER=cat`?**
>   The `gh` CLI pipes long output through a pager (like `less`) by default, which blocks in non-interactive terminals. Setting it to `cat`
>   disables paging so output prints directly.
> - **Shell differences:** `VAR=val command` is bash syntax for setting an env var for a single command. PowerShell requires a separate
>   `$env:VAR = "val"` statement (persists for the session, which is harmless here).

### 7. Update Existing PR

If a PR already exists for the branch:

- Do not create another.
- If requested (or if the body is still mostly unfilled), update it:

  **bash:** `GH_PAGER=cat gh pr edit <pr-number-or-url> --body-file pr-body.md`
  **PowerShell:** `$env:GH_PAGER = "cat"; gh pr edit <pr-number-or-url> --body-file pr-body.md`

- Return the existing PR URL.

### 8. Clean up

After you are completely finished creating or updating the PR — after [step 6](#6-create-pr) and, if needed, [step 7](#7-update-existing-pr)
— delete the temporary body file:

- **bash:** `rm pr-body.md`
- **PowerShell:** `Remove-Item pr-body.md`
