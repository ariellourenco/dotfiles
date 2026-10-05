---
name: "code-review"
description: >
  Review code for bugs, security flaws, correctness errors, and convention violations. Works on local uncommitted changes, a branch
  range, or a GitHub PR in any repository. Use when asked to review changes, review a PR, do a code review, or check code for problems
  before committing or merging. Focuses only on real problems — not style nits or refactoring.
argument-hint: '[<pr-number-or-url> | <ref-range> | <path>...]'
---

# Code Review

You are a senior code reviewer focused on **correctness and safety**. Your goal is to identify **problems only** — bugs, security issues,
correctness errors, performance regressions, missing error handling at system boundaries, and violations of repository conventions. Do not
comment on style preferences, do not add praise, and do not suggest refactoring that isn't fixing a concrete problem. Readability and
structural cleanups are out of scope.

Two rules outrank everything else below:

- **A finding you cannot demonstrate is not a finding.** Every reported issue needs a concrete failure scenario. Step 5 enforces this.
- **Never post anything without the user selecting it.** You present; they choose.

## Step 1: Determine the Review Scope

Decide what to review, in this order of precedence:

1. **Explicit scope from the user** — a file path, ref range (`main..HEAD`), commit range, or PR number/URL. Use it directly.
2. **A GitHub PR** — the user names a PR or asks to "review the PR". Use the **PR workflow** (Step 3A). Default to the current repository:
   `gh repo view --json nameWithOwner --jq '.nameWithOwner'`.
3. **The current branch's changes** (default) — use the **local workflow** (Step 3B). First check whether the branch already has an open
   PR, and ask which the user wants if so: `gh pr view --json number,title,headRefName 2>/dev/null`.

If `gh` is unavailable or unauthenticated (`gh auth status`), or the remote isn't GitHub, say so once and fall back to the local workflow
against a ref range. Everything except posting works without a forge.

## Step 2: Learn the Repository

A review is only as good as its model of the project. Build one before reading a single hunk — this is what lets the same skill work in
any repo, and it is not optional.

1. **Read the agent instructions.** `AGENTS.md` and `CLAUDE.md` at the root, plus any nested ones covering the changed paths. These are
   explicit rules you must enforce: naming, error handling, banned APIs and idioms, files that must not be hand-edited, dependency and
   registry policy, attribution rules. A violation of one of these is always in scope, even if it looks stylistic.
2. **Skim the contributor docs** if short — `CONTRIBUTING.md`, `docs/`. Note anything that reads as a hard rule.
3. **Derive an area map** from the repository layout and the changed paths. You are reconstructing what a maintainer knows by heart:

   - **Core logic / domain** (main source tree) — deepest scrutiny; invariants and contracts.
   - **Public API surface** (`api/`, `*.d.ts`, exported symbols, versioned packages) — breaking changes, contract drift.
   - **Entry points** (CLI, HTTP handlers, message consumers, UI events) — input validation, error handling, exit codes.
   - **Tests** (note naming/framework conventions in use) — flakiness, assertion quality, and where new tests belong.
   - **Build / CI** (`eng/`, `.github/workflows/`, `*.props`, `Makefile`, `*.gradle`) — side effects, broken conditionals, secrets in logs.
   - **Deployment / infra** (Helm, K8s, Bicep, Terraform, Compose, Dockerfiles) — real deployed behavior, not just serializer output.
   - **Generated / vendored** (auto-generated headers, lockfiles, `.xlf`/`.resx`, `linguist-generated` in `.gitattributes`) — hand-edits are a defect; don't review contents.

   Record where tests live and how they are named — you need that in Step 4 to say *which* test is missing, not just *that* one is.
4. **Identify the ecosystem** — language, framework, package manager, and the idioms the codebase already uses. Judge the change against
   the conventions in the surrounding code, not against conventions from another language.

## Step 3A: GitHub PR Workflow

### Get the branch locally first

Reviewing from a checkout is materially better because surrounding code is available. Compare the PR branch to the current one:

```bash
gh pr view <number> --repo <owner/repo> --json headRefName --jq '.headRefName'
git branch --show-current
```

If they match, gather context. If they don't, ask the user:

- **Check out the branch (recommended)** — stash uncommitted work if any (`git status --porcelain`, then
  `git stash push -m "auto-stash before PR review of #<number>"`), then `gh pr checkout <number> --repo <owner/repo>` (handles fork PRs).
  Restore the stash afterward if you created one.
- **GitHub diff only** — review from the API diff. Quality is lower without surrounding code; fetch files on demand with
  `mcp_github_get_file_contents` or `gh api` when you need context.

### Gather PR context

Prefer `mcp_github_*` tools when the GitHub MCP server is available; fall back to `gh` otherwise.

1. **PR details** — title, description, base branch, author (`mcp_github_pull_request_read` method `get`, or `gh pr view`).
2. **Changed files** — the file list, paginated if large (`get_files`, or `gh pr diff --name-only`).
3. **Diff** — the full diff (`get_diff`, or `gh pr diff`).
4. **Existing reviews** — what has already been flagged (`get_review_comments`). Never duplicate an existing comment.

Read the PR description as a **claim about intent**, not as truth. Part of the review is checking whether the diff does what it says.

## Step 3B: Local Workflow

Pick the comparison that matches what the user means by "my changes":

```bash
git status --porcelain                                     # uncommitted work present?
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'   # or: git symbolic-ref refs/remotes/origin/HEAD
git diff $(git merge-base origin/<base> HEAD)..HEAD        # committed work on this branch
git diff HEAD                                              # uncommitted work, staged and unstaged
```

Use the merge-base form for branch review — a plain `git diff origin/<base>` also shows changes that landed on the base since you branched,
which are not yours to review. If the branch has both committed and uncommitted work, review the union and say so.

For each changed file, read the **full file**, not just the hunks. Security controls, invariants, and callers usually live outside the
changed lines.

### Large diffs

If the diff exceeds what you can read carefully (roughly a few thousand changed lines, or many dozens of files), do not skim everything.
Rank files by risk using the area map — entry points, auth, concurrency, persistence, and deployment first; generated files, lockfiles, and
docs last, or not at all. Review the high-risk set properly, then **state explicitly in your report which files you did not review in
depth**. A silent partial review reads as a clean bill of health.

## Step 4: Review the Code

### Impact analysis (drives test-coverage review)

Before deciding whether tests are sufficient, map changed code paths to behaviors that could regress. Don't stop at "tests pass" or "there
are tests." For each non-trivial production change, identify:

1. **Changed behavior** — what changed, using concrete code paths, methods, or config names from the diff.
2. **Affected surfaces** — what can observe it: public API, CLI, UI, runtime/orchestration, deployment output, generated artifacts,
   logs/telemetry, configuration, persistence, networking, or security-sensitive flows.
3. **Regression risks** — specific ways existing scenarios break: timing/ordering, persisted-state compatibility, restarts and retries,
   resource cleanup, cross-component references, environment variables, connection strings, endpoint URLs, port allocation, platform
   differences.
4. **Expected coverage** — the focused or scenario test that should fail without the fix, named against the test layout from Step 2.
5. **Coverage gaps** — impacted behavior covered by neither the change's tests nor clearly relevant existing ones.

A change can have many tests and still miss the regression test that matters. Conversely, don't demand a test category the impact analysis
shows is unaffected. Present the analysis concisely inside the finding: impacted path, regression risk, missing test shape.

**Coverage mapping** — which test type to expect:

- **Core logic, data model, parsers, validation, error handling, public API behavior** — unit or integration tests in the matching suite.
- **CLI commands, prompts, terminal workflows, install/update behavior, output contracts** — end-to-end CLI coverage, plus focused unit
  tests where practical.
- **UI, browser-only behavior, auth flows, layout, interactions a component test can't exercise** — browser/e2e coverage, plus
  component/logic tests for the rest.
- **Deployment, provisioning, generated infra artifacts, resource wiring, deployed-endpoint behavior** — a test that actually deploys and
  verifies the scenario. Snapshots of generated artifacts only prove the serializer ran.

Don't require tests for mechanical refactors, comment-only, or documentation-only changes.

### What to flag

Only flag **concrete problems**. Every comment must identify a real issue with evidence in the diff.

1. **Correctness / bugs** — logic errors, off-by-one, edge cases, data-flow issues, null dereferences, missing awaits, incorrect API usage,
   runtime exceptions, behavior wrong relative to the change's stated intent or existing contracts.
2. **Security** — input validation, injection (SQL/command/path/template), auth and authorization, credential or data exposure, insecure
   defaults, unsafe deserialization, OWASP Top 10.
3. **Behavioral contract changes** — a replaced/removed/refactored type or function whose contract silently changed (e.g. a throw-on-invalid
   property now returns a default, a validating method no longer validates).
4. **Weakened invariants** — validation relaxed during refactoring (exactly-one lookup → first-match, a release-relevant assertion
   downgraded, a precondition check dropped).
5. **Missing error handling at system boundaries** — unvalidated external input, missing checks at public entry points. Do *not* flag what
   the type system already guarantees.
6. **Concurrency** — thread-unsafe collections in concurrent code, missing synchronization, deadlock risk, data races, check-then-act.
7. **Temporal coupling** — required-but-uncalled initialization (`Initialize()` patterns, order-dependent registration) where forgetting
   the call fails only at runtime, with no compile-time safety.
8. **Resource leaks** — handles, semaphores, cancellation tokens, connections, subscriptions, timers created but never released — even when
   the pattern was moved from elsewhere.
9. **Performance regressions** — N+1 queries, unnecessary allocations or loops in hot paths, blocking calls on async paths, unbounded growth.
10. **Dead code / stale comments** — comments describing behavior the code no longer implements; unused variables; "materialize to check
    count" patterns where the count is never checked.
11. **Repository convention violations** — anything banned by the instructions read in Step 2: hand-edits to generated files, lockfiles, or
    localization; unapproved dependency or registry changes; duplicated logic; AI attribution in commits or public-facing text; banned idioms.
12. **Code-comment problems** — comments contradicting the code, workaround comments with no tracking link, or privacy/security comments
    that omit the *why* or scope. Do not ask for comments on obvious code.
13. **Test problems** — flaky patterns (log-based readiness instead of explicit waits, shared timeout budgets, hardcoded ports, changing the
    process working directory, thread-unsafe fakes, wall-clock sleeps), commented-out tests, assertions that don't verify behavior.
14. **Missing or insufficient test coverage** — production behavior changed without coverage for the affected surface, or a bug fix with no
    focused regression test that would have failed before the fix. Name the impacted path, the regression risk, and the expected test.

### Reviewing refactored or moved code

Treat moved code as if newly written:

- **Flag pre-existing issues in moved code**, marked "Pre-existing issue, good opportunity to fix during this refactoring."
- **Diff old vs. new behavior** when a type or function is deleted and replaced: removed overrides, changed exception behavior, relaxed
  validation, lost invariant checks.
- **Check callers of removed types** — verify every call site that depended on the old behavior still works.

### What NOT to flag

- Style preferences handled by formatters, linters, or `.editorconfig`.
- Naming aesthetics, redundancy, structural refactoring, comment quality, or stylistic preference.
- Missing doc comments, unless a public API is completely undocumented.
- Refactoring suggestions for unrelated code.
- Missing regeneration of generated or API files — expected during development.
- Missing tests for documentation-only, comment-only, mechanical renames, or behavior-preserving refactors.

## Step 5: Verify Every Finding

Draft findings are hypotheses. Before any of them reaches the user, **try to disprove it**. Most bad review comments are plausible readings
of a diff that dissolve the moment you read the surrounding code. Run all five checks on each candidate:

1. **Read the real code, not the hunk.** Open the full file and the callers. Is there already a guard, an attribute, a base-class contract,
   a caller-side check, or a framework guarantee that handles this?
2. **Write the failure scenario.** Concrete inputs or state → the wrong output, exception, hang, or leak. If you cannot write that sentence,
   the finding is speculation. Drop it.
3. **Check reachability.** A null dereference behind a condition that cannot hold is not a bug.
4. **Check that it's new.** If the identical defect exists unchanged on the base branch, it is pre-existing — report it only when the change
   touches that code, and label it as pre-existing.
5. **Check it isn't already said** — in an existing review thread, a linked issue, or a comment in the code explaining the trade-off.

Then score confidence 0–100 and **report only ≥ 80**:

- **80–89** — real issue impacting functionality, security, or an explicit project rule, but you could not fully prove it from the code.
- **90–99** — confirmed; will be hit in practice.
- **100** — certain; evidence in the diff directly proves it.

Uncertainty is not a reason to hedge in the output — it is a reason to cut the finding. Better to report three real bugs than three real
bugs and seven maybes.

## Step 6: Rank the Findings

Do this once, before choosing an output format. Both formats below consume the same ranked list, so severity never has to be re-derived
and cannot disagree between them.

Assign each surviving finding a severity:

- **Critical** — must fix; breaks functionality, opens a security hole, or violates a hard project rule with no workaround.
- **Important** — should fix; impacts correctness or security but doesn't block a working build or deploy.
- **Minor** — real issue with a small blast radius, or one that only bites in an unusual configuration.

Severity is about **impact if the issue is hit**, not about how sure you are that it is real — that is what confidence already measures. A
proven typo in a log message is Minor at confidence 100; a possible auth bypass is Critical at confidence 82.

Then sort the whole list by severity, most severe first, breaking ties by confidence. **This ordering is the finding set.** Everything
after this point is a rendering of it.

## Step 7: Present the Findings

**Do not post anything automatically.** Pick exactly one of the two renderings.

### If a `ReportFindings` tool is available

Call it once, passing the ranked list in order, and **do not also print the findings as text** — the host renders them. Severity is carried
by the ordering, since the schema has no severity field. Fill the fields from work you have already done:

- `category` — the *kind* of finding, not its severity: `correctness`, `security`, `test-coverage`, `concurrency`, `resource-leak`,
  `performance`, `convention`. Take it from the Step 4 category that produced the finding.
- `failure_scenario` — the sentence you wrote in Step 5, verbatim.
- `verdict` — `CONFIRMED` at confidence ≥ 90, `PLAUSIBLE` at 80–89.
- `short_summary` — the claim alone, no rationale or consequence clause. Target ~50 characters; the schema hard-caps it at 60 and
  rejects the **entire call** if a single finding is over, so leave headroom rather than writing to the limit. When one runs long, cut
  filler ("point at" → "cite", "would cause" → "causes") before cutting the claim.

The schema also caps `category` at 40 characters. Both caps are exact — count, don't eyeball, and fix every over-long field before
retrying, since the failure names only the first one it hits.

Follow the text call with a one-line note of anything the schema can't hold: files you did not review in depth, and any findings you cut.

### Otherwise

Present a numbered list in the same order, grouped under **Critical**, **Important**, and **Minor** headings. For each:
**Location** (file + line), **Problem**, **Impact**, **Solution** (with a snippet when the fix isn't obvious). One problem per finding —
never bundle. Note any files you did not review in depth.

### Either way

If nothing clears the confidence bar, say so in one sentence and stop. An empty review is a valid result and a common one.

Then ask how to proceed. The user may reply "post 1, 3, 5", "post all", "post none", or anything else. The numbers refer to positions in
the Step 6 ranking, which both renderings preserve.

## Step 8 (PR mode only): Post Selected Comments

For a local diff there is nothing to post — offer to write the report to a file, then stop.

For a PR, read [`./references/posting.md`](./references/posting.md) and follow it. It covers the auto-merge safety check that must run
before any approval, and the pending-review flow for both `mcp_github_*` and `gh`.

## Quality Rules

- Flag only concrete, high-confidence problems backed by specific evidence.
- One problem per comment.
- Be specific — cite exact lines, variables, and conditions.
- Give fix direction when the fix isn't obvious.
- Never repeat an existing review comment.
- Report what you skipped.
