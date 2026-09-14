import { tool } from "@opencode-ai/plugin"
import * as fs from "fs"
import * as path from "path"
import { getProjectRoot } from "./_root.js"

export default tool({
  description: "Behavior OS: Build knowledge pack for current mission in .behavior-os/knowledge/task-<id>/",
  args: {
    taskId: tool.schema.string().describe("Task ID, e.g. 2026-0910-cache"),
    context: tool.schema.string().optional().describe("Context JSON string: { stack, goal, decisions }"),
    sources: tool.schema.string().optional().describe("Comma-separated official sources"),
  },
  async execute(args, ctx) {
    const root = getProjectRoot(ctx as any)
    const dir = path.join(root, ".behavior-os", "knowledge", `task-${args.taskId}`)
    fs.mkdirSync(dir, { recursive: true })
    let contextObj: Record<string, any> = {}
    try { contextObj = args.context ? JSON.parse(args.context) : {} } catch { contextObj = { raw: args.context } }
    const sourceList = args.sources ? args.sources.split(",").map(s => s.trim()).filter(Boolean) : []
    const now = new Date().toISOString()
    fs.writeFileSync(path.join(dir, "context.yaml"), Object.entries(contextObj).map(([k,v]) => `${k}: ${JSON.stringify(v)}`).join("\n") + `\ncreatedAt: ${now}\n`)
    fs.writeFileSync(path.join(dir, "sources.md"), `# Sources\n\n${sourceList.map(s => `- ${s}`).join("\n") || "- (add official sources)"}\n`)
    fs.writeFileSync(path.join(dir, "decisions.md"), `# Decisions\n\n- Task: ${args.taskId}\n- Created: ${now}\n- Stack: ${JSON.stringify(contextObj.stack ?? [])}\n`)
    fs.writeFileSync(path.join(dir, "implementation-notes.md"), `# Implementation Notes\n\nCreated: ${now}\nTask: ${args.taskId}\n\n## Context\n\`\`\`json\n${JSON.stringify(contextObj, null, 2)}\n\`\`\`\n`)
    return JSON.stringify({ status: "created", taskId: args.taskId, dir, files: fs.readdirSync(dir) }, null, 2)
  }
})
