import { tool } from "@opencode-ai/plugin"
import * as fs from "fs"
import * as path from "path"
import { getProjectRoot } from "./_root.js"

export default tool({
  description: "Behavior OS: Get current mission state, phase, gates, and history.",
  args: {
    missionId: tool.schema.string().optional().describe("Filter by mission ID"),
  },
  async execute(args, ctx) {
    const root = getProjectRoot(ctx as any)
    const statePath = path.join(root, ".behavior-os", "state", "state.json")
    try {
      const state = JSON.parse(fs.readFileSync(statePath, "utf-8"))
      
      // Filter by mission if provided
      let filtered = state
      if (args.missionId) {
        filtered = { ...state, history: (state.history || []).filter((h: any) => h.missionId === args.missionId || h.type === args.missionId) }
      }

      return JSON.stringify(filtered, null, 2)
    } catch (e) {
      return JSON.stringify({
        error: "State not found or unreadable.",
        state: null,
        triedPath: statePath,
        hint: "Run `node bin/behavior-os init` or execute `/discover` first to initialize."
      }, null, 2)
    }
  }
})
