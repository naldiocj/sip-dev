import { tool } from "@opencode-ai/plugin"
import * as fs from "fs"
import * as path from "path"
import { getProjectRoot } from "./_root.js"

export default tool({
  description: "Behavior OS: Handoff between agents with documented context transfer.",
  args: {
    from: tool.schema.string().describe("Source agent (e.g., orchestrator)"),
    to: tool.schema.string().describe("Target agent (e.g., backend)"),
    missionId: tool.schema.string().describe("Mission ID"),
    context: tool.schema.string().optional().describe("Context to transfer (JSON string)"),
    task: tool.schema.string().describe("Task description for target agent"),
    constraints: tool.schema.string().optional().describe("Constraints (JSON string)"),
  },
  async execute(args, ctx) {
    const projectRoot = getProjectRoot(ctx as any)
    const handoffsDir = path.join(projectRoot, ".behavior-os", "handoffs")
    fs.mkdirSync(handoffsDir, { recursive: true })
    
    // Parse context and constraints
    let context = {}
    let constraints = {}
    try { context = args.context ? JSON.parse(args.context) : {} } catch { context = { raw: args.context } }
    try { constraints = args.constraints ? JSON.parse(args.constraints) : {} } catch { constraints = { raw: args.constraints } }

    // Generate handoff ID
    const handoffId = `handoff-${Date.now()}`
    const timestamp = new Date().toISOString()

    // Create handoff document
    const handoff = {
      id: handoffId,
      from: args.from,
      to: args.to,
      missionId: args.missionId,
      task: args.task,
      context,
      constraints,
      createdAt: timestamp,
      status: "pending",
      evidence: []
    }

    // Save handoff
    const handoffPath = path.join(handoffsDir, `${handoffId}.json`)
    fs.writeFileSync(handoffPath, JSON.stringify(handoff, null, 2))

    // Update mission state
    try {
      const statePath = path.join(projectRoot, ".behavior-os", "state", "state.json")
      const state = JSON.parse(fs.readFileSync(statePath, "utf-8"))
      state.currentHandoff = handoffId
      state.handoffHistory = state.handoffHistory || []
      state.handoffHistory.push({
        id: handoffId,
        from: args.from,
        to: args.to,
        at: timestamp
      })
      fs.writeFileSync(statePath, JSON.stringify(state, null, 2))
    } catch {}

    return JSON.stringify({
      status: "created",
      handoffId,
      from: args.from,
      to: args.to,
      task: args.task,
      path: handoffPath,
      message: `Handoff created: ${args.from} → ${args.to}. Target agent should read ${handoffPath}.`
    }, null, 2)
  }
})
