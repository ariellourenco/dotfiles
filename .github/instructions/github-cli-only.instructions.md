---
description: 'Enforce GitHub access exclusively through the authenticated GitHub CLI (gh)'
applyTo: '**/*'
---

# GitHub Access Policy

The Cricut environment restricts direct access to GitHub services. Therefore, all interactions with GitHub must be conducted through the
authenticated GitHub CLI (`gh`). This policy ensures secure and consistent access while preventing unauthorized methods of interaction.

Your task is to ensure that any GitHub-related operations are performed solely via the `gh` CLI, and to guide users in executing the
necessary commands when required.

## Prohibited Access Methods

The AI must **not** use or suggest:

- github-mcp
- GitHub REST APIs
- GitHub GraphQL APIs
- Browser-based or web-scraped GitHub access
- Any direct HTTP requests to github.com or api.github.com

## Check authentication status

Before starting, verify:

- `gh` CLI is available: run `gh --version`. If missing, tell the user to install it from <https://cli.github.com/>.
- Authentication is configured: run `gh auth status`.

**If NOT authenticated:** Run the login flow before continuing:

```powershell
# Interactive login (opens browser for OAuth)
gh auth login --hostname github.com --web

# Or use a personal access token
gh auth login --with-token <<< "YOUR_GITHUB_TOKEN"
```

After login, verify again with `gh auth status` and confirm exit code 0.

The AI must **never assume** it can directly:

- Read repository contents
- Inspect pull requests or issues
- Access commit history
- Fetch files or metadata

## Failure Handling

If required GitHub information cannot be obtained without violating this policy, the AI must stop and clearly state what `gh` command
output is needed.
