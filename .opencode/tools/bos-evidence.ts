import { tool } from "@opencode-ai/plugin"
import * as fs from "fs"
import * as path from "path"
import { getProjectRoot } from "./_root.js"

export interface EvidenceEntry {
  id: string
  missionId: string
  operation: string
  agent: string
  riskLevel: "R1" | "R2" | "R3" | "R4"
  decision: "ALLOW" | "ASK" | "DENY"
  outcome: string
  filesChanged?: string[]
  gates?: Record<string, string>
  metadata?: Record<string, any>
  timestamp: string
}

export default tool({
  description: "Behavior OS: Record evidence for audit trail. Schema: operation, agent, riskLevel (R1-R4), decision (ALLOW/ASK/DENY), outcome, filesChanged, gates, metadata.",
  args: {
    missionId: tool.schema.string(),
    operation: tool.schema.string(),
    agent: tool.schema.string(),
    riskLevel: tool.schema.enum(["R1","R2","R3","R4"]),
    decision: tool.schema.enum(["ALLOW","ASK","DENY"]),
    outcome: tool.schema.string().optional(),
    filesChanged: tool.schema.array(tool.schema.string()).optional(),
    gates: tool.schema.record(tool.schema.string(), tool.schema.string()).optional(),
    metadata: tool.schema.record(tool.schema.string(), tool.schema.any()).optional(),
  },
  async execute(args, ctx) {
    const root = getProjectRoot(ctx as any)
    const file = path.join(root, ".behavior-os", "evidence", "evidence.json")
    
    let arr: EvidenceEntry[] = []
    try { arr = JSON.parse(fs.readFileSync(file, "utf-8")); if (!Array.isArray(arr)) arr = [] } catch {}
    
    const entry: EvidenceEntry = {
      id: `ev_${Date.now()}_${Math.random().toString(36).slice(2,6)}`,
      missionId: args.missionId,
      operation: args.operation,
      agent: args.agent,
      riskLevel: args.riskLevel,
      decision: args.decision,
      outcome: args.outcome ?? "completed",
      filesChanged: args.filesChanged ?? [],
      gates: args.gates ?? {},
      metadata: args.metadata ?? {},
      timestamp: new Date().toISOString(),
    }
    arr.push(entry)
    fs.writeFileSync(file, JSON.stringify(arr, null, 2))
    
    return JSON.stringify({ status: "recorded", evidenceId: entry.id, riskLevel: entry.riskLevel, decision: entry.decision }, null, 2)
  }
})
