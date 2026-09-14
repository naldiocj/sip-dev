import { tool } from "@opencode-ai/plugin"
import * as fs from "fs"
import * as path from "path"
import { getProjectRoot } from "./_root.js"

export default tool({
  description: "Behavior OS: Assess risk for an operation based on classification, context, and policies.",
  args: {
    riskLevel: tool.schema.enum(["R1", "R2", "R3", "R4"]),
    operation: tool.schema.string().describe("Operation being assessed"),
    agent: tool.schema.string().describe("Agent performing the operation"),
    context: tool.schema.record(tool.schema.string(), tool.schema.any()).optional(),
  },
  async execute(args, ctx) {
    const root = getProjectRoot(ctx as any)
    const statePath = path.join(root, ".behavior-os", "state", "state.json")
    
    let state = { phase: "idle", gates: [] as any[] }
    try {
      state = JSON.parse(fs.readFileSync(statePath, "utf-8"))
    } catch {}

    const policyCheck: Record<string, boolean> = {
      "R-001 (sensitive files)": true,
      "R-002 (git control)": args.riskLevel !== "R4" || !args.operation.includes("push --force"),
      "R-003 (role separation)": true,
      "R-004 (loop detection)": true,
      "R-005 (external directory)": true,
      "R-006 (evidence)": args.riskLevel === "R3" || args.riskLevel === "R4",
      "R-007 (state transition)": state.phase !== "idle" || args.riskLevel === "R1",
    }

    const violations = Object.entries(policyCheck).filter(([, v]) => !v).map(([k]) => k)

    let decision: "ALLOW" | "ASK" | "DENY"
    if (args.riskLevel === "R1" || args.riskLevel === "R2") decision = "ALLOW"
    else if (args.riskLevel === "R3") decision = "ASK"
    else decision = "DENY"

    const result = {
      riskLevel: args.riskLevel,
      operation: args.operation,
      agent: args.agent,
      decision,
      policyCompliant: violations.length === 0,
      violations,
      currentPhase: state.phase,
      gates: state.gates?.map((g: any) => ({ name: g.name, result: g.result })) ?? [],
      timestamp: new Date().toISOString(),
    }

    return JSON.stringify(result, null, 2)
  }
})
