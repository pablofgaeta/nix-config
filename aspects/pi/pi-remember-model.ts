import { mkdir, readFile, rename, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

type ModelSelection = {
  provider: string;
  model: string;
};

const statePath = join(process.env.PI_CODING_AGENT_DIR ?? join(homedir(), ".pi", "agent"), "last-model.json");

async function readSelection(): Promise<ModelSelection | undefined> {
  try {
    const value: unknown = JSON.parse(await readFile(statePath, "utf8"));
    if (
      typeof value === "object" &&
      value !== null &&
      "provider" in value &&
      typeof value.provider === "string" &&
      "model" in value &&
      typeof value.model === "string"
    ) {
      return { provider: value.provider, model: value.model };
    }
  } catch {
    return undefined;
  }
}

async function writeSelection(selection: ModelSelection): Promise<void> {
  await mkdir(dirname(statePath), { recursive: true });
  const temporaryPath = `${statePath}.${process.pid}.tmp`;
  await writeFile(temporaryPath, `${JSON.stringify(selection)}\n`, "utf8");
  await rename(temporaryPath, statePath);
}

export default function rememberModel(pi: ExtensionAPI): void {
  pi.on("model_select", async (event) => {
    if (event.source === "restore") return;
    await writeSelection({ provider: event.model.provider, model: event.model.id });
  });

  pi.on("session_start", async (event, ctx) => {
    if ((event.reason !== "startup" && event.reason !== "new") || pi.getFlag("model")) return;

    const selection = await readSelection();
    if (!selection) return;

    const model = ctx.modelRegistry.find(selection.provider, selection.model);
    if (model) await pi.setModel(model);
  });
}
