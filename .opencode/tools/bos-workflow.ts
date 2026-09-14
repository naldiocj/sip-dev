import { tool } from "@opencode-ai/plugin"
import * as fs from "fs"
import * as path from "path"
import { getProjectRoot } from "./_root.js"

export default tool({
  description: "Behavior OS: Execute workflow templates (feature, bugfix, refactor, security, deploy).",
  args: {
    workflow: tool.schema.enum(["feature", "bugfix", "refactor", "security", "deploy"]).describe("Workflow type"),
    params: tool.schema.string().optional().describe("Comma-separated key=value pairs"),
  },
  async execute(args, ctx) {
    const root = getProjectRoot(ctx as any)
    const workflowPath = path.join(root, ".behavior-os", "workflows", `${args.workflow}.yaml`)
    
    if (!fs.existsSync(workflowPath)) {
      return JSON.stringify({ error: `Workflow ${args.workflow} not found` }, null, 2)
    }

    // Parse workflow (simple YAML-like parsing)
    const content = fs.readFileSync(workflowPath, "utf-8")
    const steps = content.split("\n").filter(l => l.trim().startsWith("- id:"))
      .map(l => l.replace("- id:", "").trim())
    
    // Parse params
    const params: Record<string, string> = {}
    if (args.params) {
      for (const pair of args.params.split(",")) {
        const [k, v] = pair.split("=")
        if (k && v) params[k.trim()] = v.trim()
      }
    }

    // Generate task ID
    const taskId = params.taskId || `${args.workflow}-${Date.now()}`
    
    // Create knowledge pack for this workflow
    const knowledgeDir = path.join(root, ".behavior-os", "knowledge", taskId)
    fs.mkdirSync(knowledgeDir, { recursive: true })
    fs.writeFileSync(path.join(knowledgeDir, "workflow.yaml"), `workflow: ${args.workflow}\ntaskId: ${taskId}\nstartedAt: ${new Date().toISOString()}\nparams: ${JSON.stringify(params)}\n`)
    fs.writeFileSync(path.join(knowledgeDir, "steps.md"), steps.map(s => `- [ ] ${s}`).join("\n"))

    return JSON.stringify({
      status: "started",
      workflow: args.workflow,
      taskId,
      steps,
      knowledgePack: knowledgeDir,
      message: `Workflow ${args.workflow} started. Execute steps in order.`
    }, null, 2)
  }
})
