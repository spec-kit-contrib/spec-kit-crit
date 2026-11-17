---
description: "Review the current feature's spec, plan and tasks in Crit and revise them from your inline comments"
---

# Review the feature artifacts in Crit

Open the current feature's Spec Kit artifacts in [Crit](https://github.com/tomasz-tomczyk/crit)
so the user can leave inline comments in the browser, then revise the artifacts
from those comments. Repeat until the user approves.

## User Input

$ARGUMENTS

If the user input names a file or directory, review exactly that. Otherwise
review the current feature directory.

## Prerequisites

1. `crit` must be on `PATH`. Run `command -v crit`. If it is missing, stop and
   tell the user to install it (see <https://github.com/tomasz-tomczyk/crit>).
2. Find the feature directory (skip when the user input already names a path):

   ```bash
   .specify/scripts/bash/check-prerequisites.sh --json --paths-only
   ```

   Use `FEATURE_DIR` from the JSON. If the script is missing or fails, ask the
   user which directory under `specs/` to review.

## Steps

### Step 1: Pick the target

Use the path from the user input, or `FEATURE_DIR`. Reviewing the directory
covers every artifact that exists so far (`spec.md`, `plan.md`, `tasks.md`,
`research.md`, `data-model.md`, `contracts/`, ...), so re-running this command
after a later stage keeps the earlier comments in the same review.

### Step 2: Launch Crit and wait

Run:

```bash
crit <target>
```

`crit` opens the browser, prints the review URL and **blocks until the user
clicks Finish Review**. This can take hours, so run it with the longest timeout
your agent allows and in the background if it has that option (in Claude Code:
`run_in_background: true` with `timeout: 86400000`).

Tell the user the URL exactly as `crit` printed it, for example:
"Crit is open at http://localhost:<port>. Leave inline comments, then click
Finish Review."

Do **not** continue, ask the user to type anything, or read the review file
until `crit` has exited.

### Step 3: Read the feedback

When `crit` exits, read its **stdout** and follow its instructions. Its stderr
reports `approved: true` or `approved: false`.

- If it is approved, or there are no unresolved comments, stop here and
  continue the Spec Kit flow.
- Otherwise, if stdout is empty or truncated, run `crit comments --json`.

Each comment can carry:

- `quote`: the exact text the reviewer selected. Change that text, not the
  whole line range.
- `anchor`: where the content is now. Line numbers may be stale after edits.
- `drifted: true`: the original text was removed or rewritten, so treat line
  numbers as approximate.

### Step 4: Address each unresolved comment

For every unresolved comment:

1. Work out what it asks for. If it has a suggestion block, apply that change.
2. Edit the referenced artifact. Keep the artifacts consistent: a change to
   `spec.md` that affects `plan.md` or `tasks.md` belongs in those files too,
   when they exist.
3. Reply with what you did:

   ```bash
   crit comment --reply-to <id> --author '<your agent name>' '<what you changed>'
   ```

   Use one `crit comment --json` call when there are many replies:

   ```bash
   crit comment --json --file /tmp/crit-replies.json --author '<your agent name>'
   ```

4. **Do not pass `--resolve`.** Resolving a comment is the reviewer's call.

If a comment is a question or something you will not change, reply with the
reasoning instead of editing.

### Step 5: Start the next round

Run the same `crit <target>` command again, as in Step 2. It tells the running
review the round is done and blocks until the next Finish Review.

Tell the user only: "Replied in Crit. Review the changes in your browser and
click Finish Review when ready." Do not repeat the replies in chat.

Return to Step 3 when `crit` exits. Stop when the user approves.
