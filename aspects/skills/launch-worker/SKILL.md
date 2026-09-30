---
name: launch-worker
description: Launch a worker agent in a managed Jujutsu workspace with a handoff and zellij tab.
disable-model-invocation: true
---

Use the `jj-workspaces` skill to create the workspace, copy permitted project configuration, and write `.jj/agent/HANDOFF.md`. This skill adds the terminal session only.

## Dispatcher Boundary

The current agent is the dispatcher, not the worker. It MAY inspect files needed for an accurate handoff and setup, but MUST NOT implement, debug, or verify the handed-off task in the worker workspace unless the user explicitly asks.

After the workspace, handoff, and zellij tab are created, stop and report the source workspace status, worker workspace path, handoff path, and tab title or manual launch command.

## Open the Worker Session

1. **Prepare the workspace.**
   - Run the `jj-workspaces` skill with the worker task, workspace name, parents, change message, and implementation constraints.
   - Derive `<title>` as a brief tab label, under 24 characters when practical.
   - Completion: `<workspace-dir>` exists and `<workspace-dir>/.jj/agent/HANDOFF.md` is readable.

2. **Write the agent start script.**
   - Create `<workspace-dir>/.jj/agent/start-agent.sh` so zellij does not need nested shell quoting.
   - Prefer the current interactive coding-agent family when it can be detected from environment variables, process names, or available commands. Preserve only generic provider, model, or session flags that do not expose secrets.
   - Seed it with: `Read .jj/agent/HANDOFF.md, confirm the objective, run the first verification command, then proceed.`
   - If no reliable command can be chosen, make the script print the handoff path and prompt, then `exec "${SHELL:-bash}"` in `<workspace-dir>`.
   - Mark it executable.
   - Completion: the script starts the agent or gives exact handoff instructions without exposing secrets.

3. **Open zellij.**
   - Add to the current zellij session with actions. Do not start a new session or pass a layout file to `zellij action new-tab`.
   - If `$ZELLIJ` is unset, stop after setup and give the commands to run from zellij.
   - Use one tab with stacked panes: editor, agent, and shell. Start the shell explicitly because some zellij versions ignore `--cwd` for an empty command.

     ```bash
     tab_id=$(zellij action new-tab --name '<title>' --cwd '<workspace-dir>' -- nvim .)
     zellij action new-pane --tab-id "$tab_id" --stacked --name agent --cwd '<workspace-dir>' -- .jj/agent/start-agent.sh
     zellij action new-pane --tab-id "$tab_id" --stacked --name shell --cwd '<workspace-dir>' -- "${SHELL:-bash}"
     ```

   - Completion: the current session has a new `<title>` tab with a stacked editor, agent, and shell, all rooted at `<workspace-dir>`.

4. **Report the handoff.**
   - Confirm the dispatcher has not started worker implementation.
   - Return the source workspace status, worker workspace path, tab title, and handoff path. If the agent could not be seeded, give: `Read .jj/agent/HANDOFF.md and start with the first verification command.`
