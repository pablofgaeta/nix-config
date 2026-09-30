---
name: jj-workspaces
description: Create, inspect, or retire Jujutsu workspaces in the XDG data directory, including project environment setup and an agent handoff. Use when the user asks for a jj workspace, a managed worktree, workspace cleanup, or a handoff without terminal automation.
---

Use Jujutsu workspaces to isolate concurrent work. Keep them discoverable at:

```text
${XDG_DATA_HOME:-$HOME/.local/share}/jj/workspaces/<platform>/<org>/<repo>/<workspace>/
```

`<platform>`, `<org>`, and `<repo>` come from a checkout at `~/workspace/<platform>/<org>/<repo>`. `<workspace>` is a short task slug. This layout is the source of truth for managed worker workspaces. The repository's normal workspace remains where it is.

## Create a Workspace

1. **Derive the destination.**
   - Run `jj workspace root` and `jj status` before changing anything.
   - Use a user-supplied workspace name, or derive a lowercase, hyphenated task slug. Reject names containing path separators or `..`.
   - Derive `<platform>`, `<org>`, and `<repo>` from the current workspace root relative to `$HOME/workspace`. When the current root already matches the managed layout, derive them from its parent directories so child workspaces remain in the same repository directory. If the checkout is outside either layout, ask the user to supply all three values.
   - Use user-supplied parent revision(s), or `@` when none are given. Derive a concise working-copy change message from the task.
   - Set `<workspace-dir>` to `${XDG_DATA_HOME:-$HOME/.local/share}/jj/workspaces/<platform>/<org>/<repo>/<workspace>`.
   - Check `jj workspace list` for the workspace name. If the name is already registered or the destination exists, stop and ask whether to reuse it, choose another name, or remove it. Removal is destructive. If its repository does not match the current repository, require a different `<repo>` name.
   - Completion: the parent revisions and absolute destination are explicit, and unrelated working-copy changes are accounted for.

2. **Create the jj workspace.**
   - Create its parent and run `jj workspace add` with one `-r` argument per parent:

     ```bash
     mkdir -p '<workspace-parent>'
     jj workspace add --name '<workspace>' '<workspace-dir>' -r '<parent-1>' [-r '<parent-2>' ...] -m '<change-message>'
     ```

   - Completion: `jj -R '<workspace-dir>' status` succeeds.

3. **Configure the project.**
   - Tracked configuration arrives through jj. Copy only untracked or ignored root configuration the new workspace requires.
   - Copy these low-risk files when present, preserving relative paths and without printing their contents: `.envrc`, `.tool-versions`, `.node-version`, `.nvmrc`, `.python-version`, `.ruby-version`, `.java-version`, `.sdkmanrc`, `.mise.toml`, `.mise.local.toml`, `.direnv/direnvrc`, `.env.example`, `.env.sample`, `.env.template`.
   - For `.env`, non-template `.env.*`, `.npmrc`, `.pypirc`, `.cargo/credentials*`, or cloud credential files, ask before copying or symlinking. State paths only.
   - Completion: required non-secret configuration exists in the new workspace, and the user has decided on every secret-bearing path found.

4. **Write the handoff.**
   - Create `<workspace-dir>/.jj/agent/HANDOFF.md` so the document is outside the working-copy change.
   - Include the task, source repository path, workspace path, parent revisions and descriptions, change message, relevant constraints, first command to run, and an explicit stop condition.
   - Keep secrets out of the handoff. Put task-specific implementation direction in this document, not in task changes made during setup.
   - Completion: the handoff tells a worker exactly what to do first, and `jj -R '<workspace-dir>' status` does not list it as a change.

5. **Report the workspace.**
   - Return the source workspace status, managed workspace path, and handoff path. Do not begin the handed-off work unless the user explicitly asks.

## Inspect or Retire Workspaces

1. **Inspect first.**
   - Run `jj workspace list` from the source repository and inspect the matching platform/org/repo directory. Report the workspace names, paths, and `jj -R '<workspace-dir>' status` for a workspace the user names.
   - Completion: each candidate is identified by both jj workspace name and on-disk path.

2. **Retire only named workspaces.**
   - Confirm the named workspace has no work the user needs, then run `jj workspace forget '<workspace>'` from another workspace of the same repository.
   - Report that `forget` leaves files on disk. Delete the named directory only after the user explicitly authorizes that deletion. Never bulk-delete a platform, organization, or repository directory.
   - Completion: `jj workspace list` no longer includes the workspace, and any deletion is separately authorized and verified.
