# Skills

[![AI Validation](https://github.com/ariellourenco/dotfiles/actions/workflows/ai-validation.yml/badge.svg)](https://github.com/ariellourenco/dotfiles/actions/workflows/ai-validation.yml)

Reusable instructions for AI coding assistants, written to the [agentskills.io](https://agentskills.io) specification. Each skill is a
directory containing a `SKILL.md`, plus any scripts or references it needs. The skills in this repository are designed to be used with
[Claude Code](https://claude.ai/code) and [GitHub Copilot CLI](https://github.com/features/copilot/cli) as long as the defined `model` is
available on the platform. Skills that don't set a `model` use whichever model is selected.

The table below lists the skills in this repository, with their purpose and model. For more information, see the `SKILL.md` in each
skill's directory.

| Skill                                         | Purpose                                                                  | Model    |
| --------------------------------------------- | ------------------------------------------------------------------------ | -------- |
| [address-pr-reviews](address-pr-reviews)      | Evaluate and resolve a pull request's unresolved review comments         | inherits |
| [code-review](code-review)                    | Review changes for bugs, security flaws and correctness errors           | inherits |
| [commit](commit)                              | Write clear, consistent commit messages and commit                       | `haiku`  |
| [create-pr](create-pr)                        | Create or update a GitHub pull request, filling in its template          | `sonnet` |
| [create-release](create-release)              | Generate release notes for a pull request or branch                      | inherits |

> [!NOTE]
> Skills enabled on your claude.ai account (Anthropic's built-ins, organization-provisioned and personal uploads) are synced into the config
> directory's `skills/` folder. Because that folder is symlinked here, they appear in `synced/`. They are managed in claude.ai, so the
> folder is gitignored.

## Installation

Run the commands below from the root of this repository, and make sure `skills` doesn't already exist in the target directory, otherwise
`ln` creates the link inside it instead.

### Claude Code

Claude Code reads skills from the `skills` folder of its config directory (`$CLAUDE_CONFIG_DIR`, or `~/.claude` when unset). Point it at
this folder with a symlink:

```bash
ln -s "$PWD/.github/skills" "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"
```

### GitHub Copilot CLI

[GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-skills) discovers `.github/skills/`
automatically when started from inside this repository. However, you can also symlink it into its config directory (`$COPILOT_HOME`, or
`~/.copilot` when unset) to make it available for all projects.

```bash
ln -s "$PWD/.github/skills" "${COPILOT_HOME:-$HOME/.copilot}/skills"
```

In an interactive Copilot session, confirm the skills are available with `/skills list`, and use `/skills reload` to pick up changes made
during it.

## Validation

CI checks every skill on pull requests and pushes to `main` whenever the skills or the validator change. To run the same check locally:

```bash
.github/scripts/validate-skills.sh
```

It verifies that each skill's `name` matches its directory, that its `description` is 1-1024 characters, and that its frontmatter only uses
keys from the specification (`name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`) or this repository's own
(`argument-hint`, `model`, `color`).
