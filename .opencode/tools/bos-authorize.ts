import { tool } from "@opencode-ai/plugin"
import * as fs from "fs"
import * as path from "path"
import { getProjectRoot } from "./_root.js"

export default tool({
  description: "Behavior OS: Authorize an operation — final ALLOW/ASK/DENY with full trace.",
  args: {
    operation: tool.schema.string(),
    agent: tool.schema.string(),
    riskLevel: tool.schema.enum(["R1", "R2", "R3", "R4"]),
    classifyResult: tool.schema.string().optional(),
    assessResult: tool.schema.string().optional(),
  },
  async execute(args, ctx) {
    const root = getProjectRoot(ctx as any)
    const statePath = path.join(root, ".behavior-os", "state", "state.json")
    
    let state: any = { phase: "idle", gates: [], history: [] }
    try { state = JSON.parse(fs.readFileSync(statePath, "utf-8")) } catch {}

    const decision = args.riskLevel === "R1" || args.riskLevel === "R2" ? "ALLOW"
      : args.riskLevel === "R3" ? "ASK"
      : "DENY"

    const trace = {
      operation: args.operation,
      agent: args.agent,
      riskLevel: args.riskLevel,
      decision,
      classify: args.classifyResult,
      assess: args.assessResult,
      stateBefore: { phase: state.phase, gates: state.gates?.length ?? 0 },
      timestamp: new Date().toISOString(),
    }

    // Update state to authorized
    state.risk = args.riskLevel
    state.agent = args.agent
    if (!state.gates) state.gates = []
    state.gates.push({
      name: "AuthorizeGate",
      result: decision === "DENY" ? "BLOCK" : "PASS",
      reason: `Risk ${args.riskLevel} → ${decision}`,
      timestamp: new Date().toISOString(),
    })
    state.history.push({ from: state.phase, to: "authorized", at: new Date().toISOString(), reason: args.operation })
    state.updatedAt = new Date().toISOString()
    fs.writeFileSync(statePath, JSON.stringify(state, null, 2))

    return JSON.stringify({ ...trace, stateAfter: { phase: state.phase, risk: state.risk } }, null, 2)
  }
})
