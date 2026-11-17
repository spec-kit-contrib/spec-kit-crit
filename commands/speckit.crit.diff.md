---
description: "Review the implementation diff in Crit and fix the code from your inline comments"
---

# Review the implementation diff in Crit

Open the feature branch's changes in [Crit](https://github.com/tomasz-tomczyk/crit)
so the user can comment inline on the code, then fix the code from those
comments. Repeat until the user approves.

## User Input

$ARGUMENTS

If the user input is a Crit argument (`--pr <num|url>`, `--range <base>..<head>`,
a file, a directory), pass it through. Otherwise run `crit` with no arguments to
review the branch diff.

## Prerequisites

1. `crit` must be on `PATH`. Run `command -v crit`. If it is missing, stop and
   tell the user to install it (see <https://github.com/tomasz-tomczyk/crit>).
2. The working tree must be a git repository on the feature branch.

## Steps

### Step 1: Launch Crit and wait

Run:

```bash
crit $ARGUMENTS
```

`crit` opens the browser, prints the review URL and **blocks until the user
clicks Finish Review**. Run it with the longest timeout your agent allows and in
the background if it has that option (in Claude Code: `run_in_background: true`
with `timeout: 86400000`).

Tell the user the URL exactly as `crit` printed it. Do **not** continue or read
the review file until `crit` has exited.

### Step 2: Read the feedback

When `crit` exits, read its **stdout** and follow its instructions. Its stderr
reports `approved: true` or `approved: false`.

- If it is approved, or there are no unresolved comments, stop here.
- Otherwise, if stdout is empty or truncated, run `crit comments --json`.

Honour `quote` (change the selected text), `anchor` (current position) and
`drifted` (line numbers are approximate).

### Step 3: Address each unresolved comment

For every unresolved comment:

1. Work out what it asks for. If it has a suggestion block, apply that change.
2. Fix the code. Keep `tasks.md` accurate: if a comment shows a task is not
   really done, reopen it, and if it adds work, add a task.
3. Reply with what you did:

   ```bash
   crit comment --reply-to <id> --author '<your agent name>' '<what you changed>'
   ```

4. **Do not pass `--resolve`.** Resolving a comment is the reviewer's call.

### Step 4: Start the next round

Run the same `crit $ARGUMENTS` command again. It tells the running review the
round is done and blocks until the next Finish Review.

Tell the user only: "Replied in Crit. Review the changes in your browser and
click Finish Review when ready."

Return to Step 2 when `crit` exits. Stop when the user approves.
