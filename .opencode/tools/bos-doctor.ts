import { tool } from "@opencode-ai/plugin"
import * as fs from "fs"
import * as path from "path"
import { getProjectRoot } from "./_root.js"

export default tool({
  description: "Behavior OS Doctor - Check system health, versions, DNA validity, and configuration.",
  args: {
    verbose: tool.schema.boolean().optional().describe("Show detailed checks"),
  },
  async execute(args, ctx) {
    const projectRoot = getProjectRoot(ctx as any)
    const boDir = path.join(projectRoot, ".behavior-os")
    const checks: any[] = []
    
    console.log(`[bos_doctor] Checking project: ${projectRoot}`)
    
    // Check .behavior-os structure
    const structureChecks = [
      { dir: "dna", name: "DNA directory" },
      { dir: "truth", name: "Truth directory" },
      { dir: "state", name: "State directory" },
      { dir: "evidence", name: "Evidence directory" },
      { dir: "profiles", name: "Profiles directory" },
    ]
    
    for (const check of structureChecks) {
      const exists = fs.existsSync(path.join(boDir, check.dir))
      checks.push({ check: check.name, status: exists ? "PASS" : "FAIL", detail: exists ? "exists" : "missing" })
    }
    
    // Check DNA files
    const dnaFiles = ["orchestrator.yaml", "backend.yaml", "frontend.yaml", "qa.yaml"]
    for (const dna of dnaFiles) {
      const exists = fs.existsSync(path.join(boDir, "dna", dna))
      checks.push({ check: `DNA: ${dna}`, status: exists ? "PASS" : "WARN", detail: exists ? "valid" : "missing (use default)" })
    }
    
    // Check opencode.json
    const opencodeExists = fs.existsSync(path.join(projectRoot, ".opencode", "opencode.json"))
    checks.push({ check: "OpenCode config", status: opencodeExists ? "PASS" : "WARN", detail: opencodeExists ? "found" : "run 'opencode' first" })
    
    // Check plugin
    const pluginExists = fs.existsSync(path.join(projectRoot, ".opencode", "plugins", "behavior-os.ts")) ||
                         fs.existsSync(path.join(projectRoot, ".opencode", "plugins", "behavior-os.js"))
    checks.push({ check: "Plugin", status: pluginExists ? "PASS" : "FAIL", detail: pluginExists ? "loaded" : "missing" })
    
    // Check tools
    const toolsDir = path.join(projectRoot, ".opencode", "tools")
    let toolCount = 0
    if (fs.existsSync(toolsDir)) {
      toolCount = fs.readdirSync(toolsDir).filter(f => f.startsWith("bos-")).length
    }
    checks.push({ check: "Custom Tools", status: toolCount >= 5 ? "PASS" : "WARN", detail: `${toolCount}/5 tools found` })
    
    // Check state
    let state = null
    try {
      const statePath = path.join(boDir, "state", "state.json")
      if (fs.existsSync(statePath)) {
        state = JSON.parse(fs.readFileSync(statePath, "utf-8"))
      }
    } catch {}
    checks.push({ check: "State", status: state ? "PASS" : "FAIL", detail: state?.phase || "not initialized" })
    
    // Check discovery
    checks.push({ 
      check: "Discovery", 
      status: state?.discoveryComplete ? "PASS" : "FAIL",
      detail: state?.discoveryComplete ? "completed" : "run /discover"
    })
    
    // Summary
    const passed = checks.filter(c => c.status === "PASS").length
    const failed = checks.filter(c => c.status === "FAIL").length
    const warnings = checks.filter(c => c.status === "WARN").length
    const status = failed === 0 ? "READY" : "ISSUES"

    return JSON.stringify({
      projectRoot,
      status,
      total: checks.length,
      passed,
      failed,
      warnings,
      checks,
      summary: failed === 0 ? `STATUS: ${status}` : `STATUS: ${status} — ${failed} issues found`
    }, null, 2)
  }
})
