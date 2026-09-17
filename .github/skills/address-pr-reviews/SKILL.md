---
name: "address-pr-reviews"
description: >
  Evaluate and resolve a pull request's unresolved inline review comments interactively.
  Use when asked to: address PR reviews, evaluate review comments, respond to reviewer feedback, triage PR comments, resolve review threads.
argument-hint: '[<pr-number-or-url>] [--force]'
---

# Address Pull Request Reviews

Reviewers leave inline comments to catch bugs, questions, and stylistic concerns before merge. This SKILL details how to evaluate each
unresolved review thread with an honest engineering judgment, decide the fix interactively with the author, apply it, and close the loop
by replying on the thread. The goal is a reviewed PR where every open thread has been either fixed with evidence or consciously dismissed
with a reason — never silently ignored.

## Arguments

- `<pr-number-or-url>` — target PR; if omitted, use the PR for the current branch.
- `--force` — skip the interactive confirmation and apply the recommended action for every thread that has a clear, low-risk fix. Threads
  that genuinely need a human decision are still surfaced as questions.

## Core Principles

- **Evaluate, don't obey.** A review comment is a hypothesis, not an instruction. Confirm whether it is actually correct against the code
  before acting. It is fine — and valuable — to disagree with a reviewer, as long as you explain why.
- **Verify with evidence.** When a comment claims a bug, reproduce the reasoning in the code (or a test) before calling it valid. When a
  claim depends on external behavior (an API, a CDN, another service), read that source of truth rather than guessing.
- **Decide interactively.** Group the threads, state your assessment of each, then ask the author for decisions only where the answer
  changes what you do. Do not ask about fixes that are obviously correct and low-risk — state that you will apply them.
- **Close the loop.** Every thread ends in one of: fixed (with the commit referenced), answered (with reasoning), or deferred (with a
  reason). Reply on the thread so the reviewer sees the outcome.

## Workflow

### 1. Identify the PR and fetch unresolved threads

Resolve the target PR (argument, or `gh pr view --json number,url` for the current branch). Fetch inline review threads **with their
resolution status** — the REST comments endpoint does not expose resolution, so use GraphQL:

```bash
GH_PAGER=cat gh api graphql -f query='
query {
  repository(owner: "<owner>", name: "<repo>") {
    pullRequest(number: <number>) {
      reviewThreads(first: 100) {
        nodes {
          isResolved
          isOutdated
          path
          line
          comments(first: 20) { nodes { databaseId author { login } body } }
        }
      }
    }
  }
}'
```

Consider only threads where `isResolved` is `false`. Note `isOutdated` (the code moved since the comment) — call it out, since the anchor
line may no longer be accurate. Capture each thread's first-comment `databaseId` — you need it to reply in step 4.

### 2. Evaluate each thread

For every unresolved thread, read the referenced file/lines and judge it. Produce a compact table the author can scan:

| # | File / line | Reviewer | Assessment |
|---|-------------|----------|------------|

For each, classify the assessment as one of:

- **Valid bug** — confirmed defect. Describe the failure and the fix. Prefer to prove it (trace the code path, or note a test that would fail).
- **Valid improvement** — correct suggestion (validation, docs, naming, dead code). Note the change.
- **Needs a decision** — legitimate but the author/team must choose (design trade-off, ambiguous intent, swapped values). Do not guess.
- **Needs external confirmation** — depends on behavior defined elsewhere. Read that source and cite it (a permalink pinned to a commit SHA — see step 4). Only then classify it.
- **Not valid / no change** — the comment is mistaken or does not apply. Say so plainly with the reason.

Merge duplicate threads that raise the same issue and evaluate them once.

### 3. Decide interactively

- Fold the clear, low-risk fixes ("valid bug", "valid improvement") into a short confirmation — state you will apply them.
- For "**Needs a decision**" threads, use the AskUserQuestion tool. Offer concrete options with previews (e.g. the exact resulting code or URL)
  so the trade-off is visible. Recommend one and mark it.
- For "**Needs external confirmation**", do the investigation first and present the finding as part of the question or recommendation.

If `--force`, skip the confirmation for clear fixes but still ask the "**Needs a decision**" questions — those cannot be safely auto-resolved.

### 4. Apply fixes, verify, and reply

- Make the code changes for every accepted item. **Build and run the relevant tests** before committing; a review fix that breaks the build
  is worse than the original comment.
- Commit with a message that explains *why* (reference the review).
- Reply to each thread using the first comment's id so the reply threads correctly:

  ```bash
  GH_PAGER=cat gh api repos/<owner>/<repo>/pulls/<number>/comments/<comment-id>/replies -f body='<reply>'
  ```

  In the reply: state the outcome (fixed / answered / deferred), reference the commit SHA for fixes, and include a source link when the
  decision rested on external behavior.

- **Permalinks must be commit-pinned**, never branch-relative, so they keep pointing at the same code:
  `https://github.com/<owner>/<repo>/blob/<full-sha>/<path>#L<start>-L<end>`. Get the SHA with
  `gh api "repos/<owner>/<repo>/commits?path=<path>&sha=<branch>&per_page=1" --jq '.[0].sha'`.

- Do not mark threads resolved unless the author asks — that is the reviewer's or author's call. Offer it as a follow-up.

### 5. Report

Summarize per-thread outcomes in a table (fixed → commit, answered → reasoning, deferred → reason, reply → link). List anything still
awaiting the author (threads you replied to but did not resolve, follow-up work).

## Notes

- Never edit or hide a reviewer's comment. You add replies; you do not alter their text.
- Keep replies concise and specific — the commit hash and a one-line reason beat a paragraph.
- If a fix is out of scope for this PR, say so in the reply and suggest a follow-up issue rather than silently skipping it.
