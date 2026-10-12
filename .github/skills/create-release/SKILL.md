---
name: create-release
description: >
  Generates release notes for a pull request or branch. Use this when asked to fill out, generate, or summarize release details, release
  notes, or a release checklist.
compatibility: "Requires the GitHub CLI (gh), installed and authenticated, PowerShell (pwsh), and the GitHub MCP server."
---

# Release Notes

Generate professional release details by collecting merged PRs and producing user-facing summaries.

When asked to generate release details, analyze the changes in the repository since the last release or between branches. Identify
merged PRs, extract their titles and descriptions and fill out the [release details template](./assets/release_notes.md) in a clear and
concise manner.

**Example invocations:**

- `/create-release`

## Workflow

### 1. Collect PRs

#### 1.1 Detect the current and previous release tags

Run the following to get the two most recent release tags:

```powershell
gh release list --repo 'OWNER/REPO' --limit 2 --json tagName --jq '.[].tagName'
```

The first line is the **current release** (`{{CurrentReleaseTag}}`), the second is the **previous release** (`{{PreviousReleaseTag}}`).

#### 1.2 Run the collection script

```powershell
# Collect PRs merged between the previous and current release,
# filtered to the authenticated GitHub user
pwsh ./scripts/collect-data.ps1 `
    -StartCommit '{{PreviousReleaseTag}}' `
    -EndCommit  '{{CurrentReleaseTag}}' `
    -Repo 'OWNER/REPO' `
    -OutputDir 'artifacts/releases/{{CurrentReleaseTag}}/'
```

**Parameters:**
- `-StartCommit` — Previous release tag (exclusive, required)
- `-EndCommit` — Current release tag (inclusive, required)
- `-Repo` — GitHub repository in `owner/name` format (required)
- `-Author` — GitHub login to filter PRs by; defaults to the authenticated `gh` user
- `-OutputDir` — Output directory for the generated CSV and JSON files

**Reliability check:** If the script reports `No commits found`, no PRs were merged between the two releases. Confirm this is expected and
stop — no release notes are needed.

The script detects both merge commits (`Merge pull request #12345`) and squash commits (`Feature (#12345)`).

#### Output Artifacts

The script writes two files to the `-OutputDir` directory:

```text
artifacts/releases/{{CurrentReleaseTag}}/
├── milestone_prs.json  # Raw PR objects (Id, Title, Author, Url, Body, CopilotSummary)
└── sorted_prs.csv      # Same data as CSV, sorted by PR number
```

### 2. Generate Release Notes

Read `artifacts/releases/{{CurrentReleaseTag}}/milestone_prs.json` and use each PR's `Title`, `Body`, and `CopilotSummary` to fill out the
[release details template](./assets/release_notes.md). Summarize the changes in a user-friendly way.

Then fill in the "Notes for the test team" section with a short paragraph or bullet list that helps the test team validate the changes.
Include:

- What was changed and what the expected behavior is
- Which scenarios to verify (happy path, edge cases, error cases, regression)
- Any setup or prerequisite needed before testing (e.g. specific data state, auth keys, feature flags, tool requirements)
- Any gotcha or non-obvious behavior the tester should be aware of.

Once the notes are complete:

- Write the release notes to `artifacts/releases/{{CurrentReleaseTag}}/release_notes.md`
- Display the proposed release notes to the user
- Ask: `Create this release notes? Reply yes to confirm, or describe any changes to make.`
- Wait for confirmation. If the user requests edits, apply them and show the updated preview before proceeding.
