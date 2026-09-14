import { tool } from "@opencode-ai/plugin"
import * as fs from "fs"
import * as path from "path"
import { getProjectRoot } from "./_root.js"

// Valid state transitions for Behavior OS
const VALID_TRANSITIONS: Record<string, string[]> = {
  idle: ["discovery", "denied"],
  discovery: ["classifying", "denied"],
  classifying: ["assessing", "denied"],
  assessing: ["authorized", "denied", "ask_pending"],
  authorized: ["executing"],
  executing: ["evidenced", "ask_pending", "denied"],
  evidenced: ["idle"],
  denied: ["idle", "classifying"],
  ask_pending: ["approved", "rejected"],
  approved: ["executing"],
  rejected: ["idle", "classifying"],
}

export default tool({
  description: "Behavior OS: Validate a state transition. Returns PASS/FAIL with reason.",
  args: {
    from: tool.schema.string().describe("Current phase"),
    to: tool.schema.string().describe("Target phase"),
    reason: tool.schema.string().optional(),
    agent: tool.schema.string().optional(),
  },
  async execute(args, ctx) {
    const root = getProjectRoot(ctx as any)
    const statePath = path.join(root, ".behavior-os", "state", "state.json")
    
    let state: any = { phase: "idle", history: [] }
    try { state = JSON.parse(fs.readFileSync(statePath, "utf-8")) } catch {}

    const allowed = VALID_TRANSITIONS[args.from] ?? []
    const isValid = allowed.includes(args.to)

    let result: "PASS" | "FAIL" | "BLOCK"
    let reason: string

    if (!isValid) {
      result = "BLOCK"
      reason = `Invalid transition: ${args.from} → ${args.to}. Allowed: ${allowed.join(", ") || "none"}`
    } else {
      result = "PASS"
      reason = `Transition ${args.from} → ${args.to} is valid${args.reason ? ": " + args.reason : ""}`
      
      // Apply transition
      state.history.push({
        from: args.from,
        to: args.to,
        at: new Date().toISOString(),
        reason: args.reason,
        agent: args.agent,
      })
      state.phase = args.to
      state.updatedAt = new Date().toISOString()
      fs.writeFileSync(statePath, JSON.stringify(state, null, 2))
    }

    return JSON.stringify({
      valid: result === "PASS",
      result,
      from: args.from,
      to: args.to,
      reason,
      allowedTransitions: allowed,
      currentState: state.phase,
      historyLength: state.history.length,
      timestamp: new Date().toISOString(),
    }, null, 2)
  }
})
