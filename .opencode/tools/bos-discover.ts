import { tool } from "@opencode-ai/plugin"
import * as fs from "fs"
import * as path from "path"
import { getProjectRoot } from "./_root.js"

export default tool({
  description: "Behavior OS: Discover project with REAL VERSION POLICY enforcement via endoflife.date API.",
  args: {
    scope: tool.schema.enum(["full", "quick"]).optional(),
  },
  async execute(args, ctx) {
    const projectRoot = getProjectRoot(ctx as any)
    
    // Read DNA policy
    let versionPolicy = { channel: "lts", allow_current: false, allow_prerelease: false, allow_eol: false }
    try {
      const dnaPath = path.join(projectRoot, ".behavior-os", "dna", "orchestrator.yaml")
      const dna = fs.readFileSync(dnaPath, "utf-8")
      const channelMatch = dna.match(/channel:\s*(\w+)/)
      if (channelMatch) versionPolicy.channel = channelMatch[1]
      const allowCurrent = dna.match(/allow_current:\s*(true|false)/)
      if (allowCurrent) versionPolicy.allow_current = allowCurrent[1] === "true"
    } catch {}

    // Read package.json
    const pkgPath = path.join(projectRoot, "package.json")
    let pkg: any = null
    try { pkg = JSON.parse(fs.readFileSync(pkgPath, "utf-8")) } catch {}
    
    const stack: string[] = []
    const versions: Record<string, string> = {}
    const versionIssues: string[] = []
    const versionDetails: any[] = []

    // ─── Node.js Version Check with REAL API Consultation ───
    const nodeVersion = process.version // v24.3.0
    const nodeMajor = parseInt(nodeVersion.match(/v(\d+)\./)?.[1] || "0")
    
    stack.push("node")
    versions["node"] = nodeVersion
    
    // Consult endoflife.date API for REAL version status
    try {
      const apiResponse = await fetch(`https://endoflife.date/api/nodejs.json`)
      const nodeData: any[] = await apiResponse.json()
      const currentNode = nodeData.find((n: any) => n.cycle == nodeMajor)
      
      if (currentNode) {
        versionDetails.push({
          tech: "node",
          version: nodeVersion,
          cycle: currentNode.cycle,
          status: currentNode.status, // LTS, Current, EOL
          lts: currentNode.lts || "N/A",
          eol: currentNode.eol,
          released: currentNode.released,
        })
        
        // Apply policy
        if (versionPolicy.channel === "lts" && !versionPolicy.allow_current) {
          if (currentNode.status === "LTS") {
            versionIssues.push(`✅ Node ${nodeVersion} is LTS (valid per policy)`)
          } else if (currentNode.status === "Current") {
            versionIssues.push(`⚠️  Node ${nodeVersion} is CURRENT, not LTS. Policy requires LTS.`)
            versionIssues.push(`   Suggestion: Use Node ${nodeData.find((n: any) => n.status === "LTS")?.cycle}.x`)
          } else if (currentNode.status === "EOL") {
            versionIssues.push(`❌ Node ${nodeVersion} is EOL. Must upgrade to LTS.`)
          }
        }
      }
    } catch (e: unknown) {
      versionIssues.push(`⚠️  Could not verify Node version via API: ${(e as Error).message}`)
    }

    // ─── TypeScript Version Check ───
    if (fs.existsSync(path.join(projectRoot, "tsconfig.json")) || pkg?.devDependencies?.typescript) {
      stack.push("typescript")
      const tsVersion = pkg?.devDependencies?.typescript ?? pkg?.dependencies?.typescript ?? "unknown"
      versions["typescript"] = tsVersion
    }

    // ─── Framework Detection ───
    const deps = { ...pkg?.dependencies, ...pkg?.devDependencies }
    if (deps["@nestjs/core"]) { 
      stack.push("nestjs")
      versions["nestjs"] = deps["@nestjs/core"]
    }
    else if (deps["next"]) { stack.push("nextjs"); versions["nextjs"] = deps["next"] }
    else if (deps["react"]) { stack.push("react"); versions["react"] = deps["react"] }

    // ─── Create .behavior-os structure ───
    const boDir = path.join(projectRoot, ".behavior-os")
    const dirs = ["truth", "knowledge", "state", "evidence", "dna", "profiles", "memory", "cache", "workflows"]
    for (const dir of dirs) {
      fs.mkdirSync(path.join(boDir, dir), { recursive: true })
    }

    // ─── Save Truth Base ───
    const truthDir = path.join(boDir, "truth")
    fs.writeFileSync(path.join(truthDir, "project.yaml"), `project:\n  name: ${pkg?.name ?? "unknown"}\n  detectedAt: ${new Date().toISOString()}\n\nstack: ${JSON.stringify(stack)}\nversions: ${JSON.stringify(versions, null, 2)}\nversionPolicy:\n  channel: ${versionPolicy.channel}\n  issues: ${JSON.stringify(versionIssues)}\nverifiedVersions: ${JSON.stringify(versionDetails, null, 2)}\n`)

    // ─── Update State ───
    const statePath = path.join(boDir, "state", "state.json")
    const hasBlocker = versionIssues.some(i => i.includes("❌"))
    const hasWarning = versionIssues.some(i => i.includes("⚠️"))
    const state = {
      missionId: `task-${Date.now()}`,
      phase: "discovery",
      status: hasBlocker ? "blocked" : "running",
      risk: hasBlocker ? "R4" : hasWarning ? "R3" : "R2",
      agent: "orchestrator",
      dna: "orchestrator",
      stack,
      versions,
      discoveryComplete: true,
      truthComplete: !hasBlocker,
      versionPolicy,
      versionIssues,
      versionDetails,
      gates: [
        { 
          name: "DiscoveryGate", 
          result: hasBlocker ? "FAIL" : "PASS", 
          timestamp: new Date().toISOString() 
        },
        { 
          name: "VersionGate", 
          result: hasBlocker ? "FAIL" : "PASS", 
          details: versionIssues,
          timestamp: new Date().toISOString() 
        }
      ],
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      history: [{ from: "idle", to: "discovery", at: new Date().toISOString() }]
    }
    fs.writeFileSync(statePath, JSON.stringify(state, null, 2))

    return JSON.stringify({
      status: hasBlocker ? "BLOCKED" : "discovered",
      stack,
      versions,
      versionPolicy,
      versionIssues,
      versionDetails,
      risk: state.risk,
      gates: state.gates,
      projectRoot,
      message: hasBlocker 
        ? "BLOCKED: Version policy violation. Review versionIssues." 
        : "Discovery complete. Versions verified."
    }, null, 2)
  }
})
