# Posting a Review to GitHub

Read this only after the user has selected which findings to post (SKILL.md Step 7). If they chose "post none", do not create or submit
anything — confirm that nothing was posted and stop.

## Auto-merge safety check

Run this before submitting any review as `APPROVE`:

```bash
gh pr view <number> --repo <owner/repo> --json autoMergeRequest --jq '.autoMergeRequest'
```

If the result is **non-null** and the review includes comments, warn the user that approving may trigger an immediate merge before anyone
can address the comments, and offer:

1. **Approve anyway** — submit as `APPROVE`; auto-merge may proceed immediately.
2. **Downgrade to comment** — submit as `COMMENT` so the author can respond first.

Wait for their choice. Do not guess.

## Posting with the GitHub MCP server

Preferred when `mcp_github_*` tools are available.

1. **Create a pending review** — `mcp_github_pull_request_review_write`, method `create`, with no `event` parameter.
2. **Add one inline comment per selected finding** — `mcp_github_add_comment_to_pending_review`:
   - `subjectType`: `LINE` for line-specific, `FILE` for file-level
   - `side`: `RIGHT` for new code, `LEFT` for removed lines
   - `path`: repo-relative file path
   - `line`: the line number in the diff (use `start_line` + `line` for a range)
   - `body`: the problem and the fix, concisely
3. **Submit** — `mcp_github_pull_request_review_write`, method `submit_pending`:
   - `APPROVE` only if the user explicitly asked to approve **and** auto-merge is off, or they confirmed after the warning.
   - Otherwise `COMMENT`.
   - Never `REQUEST_CHANGES` unless the user explicitly asks for it.
   - Include a summary body with issue counts by category.

## Posting with the `gh` CLI

Fallback when MCP tools are unavailable. Set `GH_PAGER=cat` first (`$env:GH_PAGER = "cat"` in PowerShell) so `gh` does not block on a pager.

A single call posts the whole review with its inline comments:

```bash
GH_PAGER=cat gh api repos/<owner>/<repo>/pulls/<number>/reviews \
  --method POST \
  --input review.json
```

Where `review.json` is:

```json
{
  "event": "COMMENT",
  "body": "One finding blocks merge; two more are worth fixing before this ships.",
  "comments": [
    { "path": "src/app.ts", "line": 42, "side": "RIGHT", "body": "Problem and fix." },
    { "path": "src/db.ts", "start_line": 10, "line": 14, "side": "RIGHT", "body": "Problem and fix." }
  ]
}
```

Notes:

- Write `body` as a plain sentence describing what's here, not a labeled tally (`Summary: N critical, M important`).
- `line` must be a line present in the diff, or the API rejects the whole review with a 422. If a comment can't be anchored, move it into
  the summary `body` rather than dropping it.
- For a review with no inline comments, `gh pr review <number> --comment --body "..."` is enough.
- `--approve` and `--request-changes` follow the same rules as the MCP `event` values above.

## After posting

Report the review URL and a one-line count of what was posted. If any finding could not be anchored to a diff line, say which ones ended up
in the summary instead.
