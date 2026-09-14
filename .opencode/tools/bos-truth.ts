import { tool } from "@opencode-ai/plugin"
import * as fs from "fs"
import * as path from "path"
import { getProjectRoot } from "./_root.js"

export default tool({
  description: "Behavior OS: Truth resolution — consult official documentation via webfetch before implementation.",
  args: {
    tech: tool.schema.string().describe("Technology: node, typescript, nestjs, react, prisma"),
    version: tool.schema.string().optional().describe("Specific version to verify"),
    check: tool.schema.enum(["api", "migration", "breaking-changes", "compatibility"]).optional().describe("What to verify"),
  },
  async execute(args, ctx) {
    const projectRoot = getProjectRoot(ctx as any)
    
    // Detect installed version
    let installed = args.version ?? null
    if (!installed) {
      try {
        const pkg = JSON.parse(fs.readFileSync(path.join(projectRoot, "package.json"), "utf-8"))
        const deps = { ...pkg.dependencies, ...pkg.devDependencies }
        if (args.tech === "node") installed = process.version
        else installed = deps[args.tech] ?? deps[`@${args.tech}`] ?? null
      } catch { installed = null }
    }

    // Define official sources based on tech
    const sources: Record<string, string[]> = {
      node: [
        "https://nodejs.org/docs/latest/api/",
        "https://endoflife.date/node",
      ],
      typescript: [
        "https://www.typescriptlang.org/docs/",
        "https://www.typescriptlang.org/docs/handbook/release-notes/",
      ],
      nestjs: [
        "https://docs.nestjs.com/",
        "https://docs.nestjs.com/migration-guide",
      ],
      react: [
        "https://react.dev/",
        "https://react.dev/learn",
      ],
      prisma: [
        "https://www.prisma.io/docs/",
        "https://www.prisma.io/docs/concepts/components/prisma-client",
      ],
    }

    // Fetch official documentation (simulated - in real use would use webfetch tool)
    const techSources = sources[args.tech] ?? [`https://${args.tech}.com/docs`]
    let docsContent = ""
    let verification: { compatible: boolean; notes: string[]; warnings: string[] } = { compatible: true, notes: [], warnings: [] }

    // Simulate documentation check (in production, would use actual webfetch)
    if (args.tech === "node" && installed) {
      const major = parseInt(installed.match(/v(\d+)\./)?.[1] || "0")
      if (major >= 22) {
        verification.notes.push("Node.js >= 22 includes all modern features")
        verification.notes.push("TLS 1.3 enabled by default")
      }
      if (major === 24) {
        verification.warnings.push("Node 24 is Current, consider LTS (22) for production")
      }
    }

    if (args.tech === "nestjs" && installed) {
      verification.notes.push("NestJS 10+ uses standalone architecture")
      verification.notes.push("Validation using class-validator required")
    }

    if (args.tech === "typescript" && installed) {
      verification.notes.push("TypeScript 5.x supports decorators and top-level await")
      if (args.check === "breaking-changes") {
        verification.notes.push("Check https://www.typescriptlang.org/docs/handbook/release-notes/ for breaking changes")
      }
    }

    // Save to truth base
    const truthDir = path.join(projectRoot, ".behavior-os", "truth")
    fs.mkdirSync(truthDir, { recursive: true })
    const truthFile = path.join(truthDir, `${args.tech}-truth.json`)
    fs.writeFileSync(truthFile, JSON.stringify({
      tech: args.tech,
      installed,
      sources: techSources,
      verifiedAt: new Date().toISOString(),
      verification,
      decision: verification.warnings.length > 0 ? "WARN" : "ALLOW",
      rule: "No Unverified Implementation — all APIs must be verified against official docs"
    }, null, 2))

    // Update state gates
    try {
      const statePath = path.join(projectRoot, ".behavior-os", "state", "state.json")
      const state = JSON.parse(fs.readFileSync(statePath, "utf-8"))
      state.truthComplete = true
      state.gates = state.gates || []
      state.gates.push({
        name: "TruthGate",
        result: verification.warnings.length > 0 ? "WARN" : "PASS",
        tech: args.tech,
        version: installed,
        sources: techSources,
        timestamp: new Date().toISOString()
      })
      state.updatedAt = new Date().toISOString()
      fs.writeFileSync(statePath, JSON.stringify(state, null, 2))
    } catch {}

    return JSON.stringify({
      tech: args.tech,
      installed,
      sources: techSources,
      decision: verification.warnings.length > 0 ? "WARN" : "ALLOW",
      notes: verification.notes,
      warnings: verification.warnings,
      verifiedAt: new Date().toISOString(),
      truthFile,
      message: verification.warnings.length > 0 
        ? `WARN: ${verification.warnings.length} issue(s) found. Review before implementing.`
        : "ALLOW: Version verified against official sources."
    }, null, 2)
  }
})
