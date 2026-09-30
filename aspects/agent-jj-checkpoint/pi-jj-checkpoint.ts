import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";

const checkpointCommand = `${process.env.HOME}/.nix-profile/bin/agent-jj-checkpoint`;
let sawJjWorkspace = false;
let queue: Promise<unknown> = Promise.resolve();

function enqueue<T>(work: () => Promise<T>): Promise<T> {
  const run = queue.then(work, work);
  queue = run.catch(() => undefined);
  return run;
}

async function checkpoint(
  pi: ExtensionAPI,
  ctx: ExtensionContext,
  phase: string,
  print = false,
): Promise<string | undefined> {
  const args = [phase];
  if (print) args.push("--print");

  const result = await enqueue(() =>
    pi.exec(checkpointCommand, args, {cwd: ctx.cwd, timeout: 10_000}),
  );
  if (result.code !== 0) return undefined;

  const output = result.stdout.trim();
  if (!output) return undefined;
  sawJjWorkspace = true;
  return output;
}

export default function jjCheckpoint(pi: ExtensionAPI): void {
  pi.on("before_agent_start", async (_event, ctx) => {
    const note = await checkpoint(pi, ctx, "before-agent-turn", true);
    if (!note) return;

    return {
      message: {
        customType: "jj-checkpoint",
        content: `Automated jj checkpoint hook is active.\n${note}`,
        display: true,
      },
    };
  });

  pi.on("agent_settled", async (_event, ctx) => {
    const note = await checkpoint(pi, ctx, "after-agent-turn", true);
    if (note && ctx.hasUI && sawJjWorkspace) {
      ctx.ui.notify("jj checkpoint updated", "info");
    }
  });
}
