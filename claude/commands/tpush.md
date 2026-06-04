---
description: Push this Claude session into a detached background tmux session
---

Push the **current** Claude session into a detached tmux session so it keeps
running in the background and can be managed with the `dev`/`tgo`/`dev list`
tooling. This is the CLI `tpush` command, run on your behalf.

Do this:

1. Run `tpush` in the Bash tool. It auto-detects the current session via
   `$CLAUDE_CODE_SESSION_ID` and `$PWD`, picks a `dev-<repo>-<slot>` name, and
   prints the attach command. **The detached `claude -r` is spawned when you
   exit, not now** — resuming the session while this foreground copy is still
   live would put two processes on one transcript (no lock → they diverge), so
   the spawn is deferred to the moment this session releases the id.
2. Report the exact attach command it printed back to the user (e.g.
   `tgo ff 3` or `tmux attach -t dev-dotfiles-1`).
3. Remind the user that **this foreground Claude must now be exited** (`/exit`
   or Ctrl-D) — that's what actually launches the background copy and drops them
   into it. Do not keep working in this one; the conversation continues there.

Notes:
- If `tpush` says "Already inside tmux", this session is already backgrounded —
  just tell the user that and stop.
- To later pull it back to a normal terminal, that's `/tpop` (or the `tpop`
  shell command).
