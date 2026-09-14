import { tool } from "@opencode-ai/plugin"
import * as fs from "fs"
import * as path from "path"
import { spawnSync } from "child_process"
import { getProjectRoot } from "./_root.js"

export default tool({
  description: "Behavior OS: Run validation gates (typecheck, lint, tests). Returns PASS/FAIL for each gate.",
  args: {
    gates: tool.schema.array(tool.schema.string()).optional().describe("Gates to run: ['type','lint','test','evidence']"),
  },
  async execute(args, ctx) {
    const root = getProjectRoot(ctx as any)
    const gates = args.gates ?? ["type", "lint", "test", "evidence"]
    const results: any[] = []

    // Type check
    if (gates.includes("type")) {
      try {
        const proc = spawnSync("npx", ["tsc", "--noEmit"], { cwd: root, encoding: "utf-8" })
        const ok = proc.status === 0
        results.push({ gate: "TypeGate", result: ok ? "PASS" : "FAIL", reason: ok ? "No type errors" : (proc.stderr ?? "").slice(0, 500), timestamp: new Date().toISOString() })
      } catch (e: any) { results.push({ gate: "TypeGate", result: "FAIL", reason: String(e), timestamp: new Date().toISOString() }) }
    }

    // Lint check
    if (gates.includes("lint")) {
      try {
        const proc = spawnSync("npx", ["biome", "check", "."], { cwd: root, encoding: "utf-8" })
        const ok = proc.status === 0
        results.push({ gate: "LintGate", result: ok ? "PASS" : "FAIL", reason: ok ? "No lint errors" : (proc.stderr ?? "").slice(0, 500), timestamp: new Date().toISOString() })
      } catch (e: any) { results.push({ gate: "LintGate", result: "FAIL", reason: String(e), timestamp: new Date().toISOString() }) }
    }

    // Test check
    if (gates.includes("test")) {
      try {
        const proc = spawnSync("bun", ["test"], { cwd: root, encoding: "utf-8" })
        const ok = proc.status === 0
        results.push({ gate: "TestGate", result: ok ? "PASS" : "FAIL", reason: ok ? "Tests passed" : (proc.stderr ?? "").slice(0, 500), timestamp: new Date().toISOString() })
      } catch (e: any) { results.push({ gate: "TestGate", result: "FAIL", reason: String(e), timestamp: new Date().toISOString() }) }
    }

    // Evidence check
    if (gates.includes("evidence")) {
      const statePath = path.join(root, ".behavior-os", "state", "state.json")
      let missionId = null
      try {
        const s = JSON.parse(fs.readFileSync(statePath, "utf-8"))
        missionId = s.missionId
      } catch {}
      if (missionId) {
        try {
          const evPath = path.join(root, ".behavior-os", "evidence", "evidence.json")
          const ev = JSON.parse(fs.readFileSync(evPath, "utf-8"))
          const found = Array.isArray(ev) && ev.some((e: any) => e.missionId === missionId)
          results.push({ gate: "EvidenceGate", result: found ? "PASS" : "FAIL", reason: found ? "Evidence recorded" : "No evidence for mission", timestamp: new Date().toISOString() })
        } catch { results.push({ gate: "EvidenceGate", result: "FAIL", reason: "No evidence file", timestamp: new Date().toISOString() }) }
      } else {
        results.push({ gate: "EvidenceGate", result: "PASS", reason: "No mission to check", timestamp: new Date().toISOString() })
      }
    }

    const failed = results.filter(r => r.result === "FAIL" || r.result === "BLOCK")
    const allPassed = failed.length === 0

    return JSON.stringify({ valid: allPassed, results, passed: results.length - failed.length, failed: failed.length }, null, 2)
  }
})
