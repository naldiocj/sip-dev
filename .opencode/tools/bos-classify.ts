import { tool } from "@opencode-ai/plugin"
import * as fs from "fs"
import * as path from "path"

export default tool({
  description: "Behavior OS: Classify an operation by type and impact. Returns RiskLevel (R1-R4) and Complexity.",
  args: {
    description: tool.schema.string().describe("Description of the operation or task"),
    files: tool.schema.array(tool.schema.string()).optional().describe("Files affected"),
    keywords: tool.schema.array(tool.schema.string()).optional().describe("Keywords for classification"),
  },
  async execute(args, ctx) {
    const desc = (args.description + " " + (args.keywords ?? []).join(" ")).toLowerCase()
    const files = args.files ?? []
    const fileCount = files.length

    const hasArchImpact = /architect|refactor|migration|breaking/i.test(desc)
    const hasDatabase = /database|prisma|migration|schema|sql/i.test(desc)
    const hasAuth = /auth|login|permission|guard/i.test(desc)
    const hasPayments = /payment|stripe|checkout|billing/i.test(desc)
    const hasPublicApi = /public.*api|endpoint.*public/i.test(desc)
    const hasMigrations = /migration/i.test(desc)

    let riskLevel: "R1" | "R2" | "R3" | "R4"
    let complexity: "TRIVIAL" | "LOW" | "MEDIUM" | "HIGH" | "CRITICAL"
    let reason: string

    if (hasPayments || (hasArchImpact && hasDatabase) || /production.*critical/i.test(desc)) {
      riskLevel = "R4"
      complexity = "CRITICAL"
      reason = "Critical path: payments, arch+db or production critical"
    } else if (hasArchImpact || hasDatabase || hasAuth || fileCount > 8) {
      riskLevel = "R3"
      complexity = "HIGH"
      reason = "High impact: arch/db/auth or many files"
    } else if (fileCount > 3 || /feature|implement|create/i.test(desc)) {
      riskLevel = "R3"
      complexity = "MEDIUM"
      reason = "Medium: multi-file feature"
    } else if (fileCount > 0 || /fix|update|edit/i.test(desc)) {
      riskLevel = "R2"
      complexity = "LOW"
      reason = "Low: small local edit"
    } else {
      riskLevel = "R1"
      complexity = "TRIVIAL"
      reason = "Trivial: read-only or docs"
    }

    return JSON.stringify({
      riskLevel,
      complexity,
      fileCount,
      hasArchImpact,
      hasDatabase,
      hasAuth,
      hasPayments,
      hasPublicApi,
      hasMigrations,
      reason,
      recommendation: riskLevel === "R1" || riskLevel === "R2" ? "ALLOW" : riskLevel === "R3" ? "ASK" : "DENY",
    }, null, 2)
  }
})
