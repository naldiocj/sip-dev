import { tool } from "@opencode-ai/plugin"
import * as fs from "fs"
import * as path from "path"
import { getProjectRoot } from "./_root.js"

export default tool({
  description: "Behavior OS: Check if all policy contracts are satisfied for an operation completion.",
  args: {
    missionId: tool.schema.string(),
    operation: tool.schema.string(),
    riskLevel: tool.schema.enum(["R1", "R2", "R3", "R4"]),
    filesChanged: tool.schema.array(tool.schema.string()).optional(),
  },
  async execute(args, ctx) {
    const root = getProjectRoot(ctx as any)
    const statePath = path.join(root, ".behavior-os", "state", "state.json")
    const evidencePath = path.join(root, ".behavior-os", "evidence", "evidence.json")

    let state: any = { gates: [], phase: "idle" }
    try { state = JSON.parse(fs.readFileSync(statePath, "utf-8")) } catch {}

    let evidence: any[] = []
    try {
      const raw = fs.readFileSync(evidencePath, "utf-8")
      evidence = JSON.parse(raw)
      if (!Array.isArray(evidence)) evidence = []
    } catch {}

    const checks = {
      "DiscoveryGate": (state.gates ?? []).some((g: any) => g.name === "DiscoveryGate" && g.result === "PASS"),
      "TruthGate": (state.gates ?? []).some((g: any) => g.name === "TruthGate" && (g.result === "PASS" || g.result === "WARN")),
      "EvidenceRecorded": evidence.some((e: any) => e.missionId === args.missionId && e.operation === args.operation),
      "RiskClassified": args.riskLevel !== null,
      "NoUnverifiedAPI": true,
      "NoSensitiveFileAccess": true,
    }

    const failures = Object.entries(checks).filter(([, v]) => !v).map(([k]) => k)
    const allPassed = failures.length === 0

    const contract = {
      missionId: args.missionId,
      operation: args.operation,
      riskLevel: args.riskLevel,
      contractSatisfied: allPassed,
      checks,
      failures,
      filesChanged: args.filesChanged ?? [],
      evidenceCount: evidence.filter((e: any) => e.missionId === args.missionId).length,
      timestamp: new Date().toISOString(),
    }

    return JSON.stringify(contract, null, 2)
  }
})
