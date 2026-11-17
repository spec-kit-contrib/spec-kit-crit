# spec-kit-crit

> Crit review for GitHub Spec Kit — comment inline on specs, plans, tasks and the final diff, and let your agent revise until you approve.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Spec-Driven Development works when the spec, plan and tasks are right before
any code is written. `spec-kit-crit` is a [Spec Kit](https://github.github.com/spec-kit/)
extension that hooks [Crit](https://github.com/tomasz-tomczyk/crit) into that
flow: after each stage Spec Kit offers to open the artifact in your browser,
you leave GitHub PR-style inline comments, and the agent replies and revises
from them — round after round — until you approve.

## Requirements

- [Spec Kit](https://github.com/github/spec-kit) (`specify`) 1.4.0 or newer
- [Crit](https://github.com/tomasz-tomczyk/crit) (`crit`)
- A coding agent Spec Kit supports, such as [Claude Code](https://docs.anthropic.com/en/docs/claude-code)

## Installation

From a clone, inside your Spec Kit project:

```bash
git clone git@github.com:spec-kit-contrib/spec-kit-crit.git
specify extension add --dev ./spec-kit-crit
```

Check that it is registered:

```bash
specify extension list
```

Remove it with `specify extension remove crit`.

## Usage

The extension registers hooks that Spec Kit offers after a stage finishes.
Every hook is **optional**: you are asked first and can skip it.

| Hook | Command | Opens in Crit |
| --- | --- | --- |
| `after_specify` | `speckit.crit.review` | the feature directory (`spec.md`) |
| `after_plan` | `speckit.crit.review` | the feature directory (`spec.md`, `plan.md`, ...) |
| `after_tasks` | `speckit.crit.review` | the feature directory (`spec.md`, `plan.md`, `tasks.md`, ...) |
| `after_implement` | `speckit.crit.diff` | the branch diff |

You can also run the commands yourself. In Claude Code they appear as skills:

```text
/speckit-crit-review                    # review the current feature's artifacts
/speckit-crit-review specs/001-foo/spec.md   # review one file or directory
/speckit-crit-diff                      # review the branch diff
/speckit-crit-diff --pr 42              # review a GitHub PR
```

### The review loop

1. The agent runs `crit <target>`. Crit opens in your browser and the agent
   waits.
2. You leave inline comments, then click **Finish Review**.
3. The agent reads the comments, edits the artifacts (or code), and replies on
   each comment with `crit comment --reply-to`.
4. The agent runs `crit` again for the next round. You review the replies and
   click **Finish Review** again.
5. Finish with no unresolved comments to approve. Spec Kit carries on with the
   next stage.

The agent never resolves a comment. Resolving is your call.

Reviewing the whole feature directory means a later stage keeps the comments
from the earlier ones, because Crit keys a review by directory and arguments.

### Skipping a hook

Answer no when Spec Kit asks, or turn a hook off in `.specify/extensions.yml`
by setting its `enabled` to `false`:

```yaml
hooks:
  after_tasks:
    - extension: crit
      command: speckit.crit.review
      enabled: false
```

Disable the whole extension with `specify extension disable crit`.

## Configuration

There is nothing to configure here. Crit has its own settings — see its
documentation for the port, the author name and the config files.

## Development

Install your working copy into a scratch Spec Kit project and edit the command
files under `commands/`:

```bash
specify extension add --dev /path/to/spec-kit-crit
```

Reinstall after changing `extension.yml` or a command file.

## The spec-kit-contrib Ecosystem

| Repo | What it provides |
| --- | --- |
| **spec-kit-crit** ← you are here | Inline browser review for Spec Kit specs, plans, tasks and diffs |

## License

[MIT](LICENSE) — Copyright (c) 2026 spec-kit-contrib

<!-- markdownlint-disable-file MD013 MD036 -->
