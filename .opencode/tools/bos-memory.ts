import { tool } from "@opencode-ai/plugin"
import * as fs from "fs"
import * as path from "path"
import { getProjectRoot } from "./_root.js"

export default tool({
  description: "Behavior OS: Memory layer for persistent knowledge across sessions.",
  args: {
    action: tool.schema.enum(["store", "retrieve", "list", "delete", "search"]).describe("Memory action"),
    layer: tool.schema.enum(["short_term", "session", "project", "domain", "behavior", "evidence"]).describe("Memory layer"),
    key: tool.schema.string().optional().describe("Memory key"),
    value: tool.schema.string().optional().describe("Value to store"),
    tags: tool.schema.string().optional().describe("Comma-separated tags"),
    query: tool.schema.string().optional().describe("Search query"),
  },
  async execute(args, ctx) {
    const root = getProjectRoot(ctx as any)
    const memoryDir = path.join(root, ".behavior-os", "memory", args.layer ?? "project")
    
    switch (args.action) {
      case "store":
        if (!args.key || !args.value) {
          return JSON.stringify({ error: "key and value required for store" }, null, 2)
        }
        fs.mkdirSync(memoryDir, { recursive: true })
        const entry = {
          id: `mem_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`,
          layer: args.layer,
          key: args.key,
          value: JSON.parse(args.value ?? "{}"),
          tags: args.tags ? args.tags.split(",").map(t => t.trim()) : [],
          createdAt: new Date().toISOString(),
        }
        fs.writeFileSync(path.join(memoryDir, `${args.key}.json`), JSON.stringify(entry, null, 2))
        return JSON.stringify({ status: "stored", entry }, null, 2)

      case "retrieve":
        if (!args.key) {
          return JSON.stringify({ error: "key required for retrieve" }, null, 2)
        }
        const filePath = path.join(memoryDir, `${args.key}.json`)
        if (!fs.existsSync(filePath)) {
          return JSON.stringify({ error: "not found", key: args.key }, null, 2)
        }
        return JSON.stringify(JSON.parse(fs.readFileSync(filePath, "utf-8")), null, 2)

      case "list":
        if (!fs.existsSync(memoryDir)) {
          return JSON.stringify({ entries: [], layer: args.layer })
        }
        const files = fs.readdirSync(memoryDir).filter(f => f.endsWith(".json"))
        const entries = files.map(f => JSON.parse(fs.readFileSync(path.join(memoryDir, f), "utf-8")))
        return JSON.stringify({ entries, layer: args.layer, count: entries.length }, null, 2)

      case "delete":
        if (!args.key) {
          return JSON.stringify({ error: "key required for delete" }, null, 2)
        }
        const delPath = path.join(memoryDir, `${args.key}.json`)
        if (fs.existsSync(delPath)) {
          fs.unlinkSync(delPath)
          return JSON.stringify({ status: "deleted", key: args.key })
        }
        return JSON.stringify({ error: "not found", key: args.key })

      case "search":
        if (!args.query) {
          return JSON.stringify({ error: "query required for search" }, null, 2)
        }
        const allEntries = await searchAcrossLayers(root, args.query, args.layer)
        return JSON.stringify({ results: allEntries, query: args.query }, null, 2)

      default:
        return JSON.stringify({ error: "unknown action" }, null, 2)
    }
  }
})

async function searchAcrossLayers(root: string, query: string, layer?: string): Promise<any[]> {
  const layers = layer ? [layer] : ["short_term", "session", "project", "domain", "behavior", "evidence"]
  const results: any[] = []
  
  for (const l of layers) {
    const memDir = path.join(root, ".behavior-os", "memory", l)
    if (!fs.existsSync(memDir)) continue
    
    const files = fs.readdirSync(memDir).filter(f => f.endsWith(".json"))
    for (const file of files) {
      const entry = JSON.parse(fs.readFileSync(path.join(memDir, file), "utf-8"))
      const match = 
        entry.key?.toLowerCase().includes(query.toLowerCase()) ||
        JSON.stringify(entry.value)?.toLowerCase().includes(query.toLowerCase()) ||
        entry.tags?.some((t: string) => t.toLowerCase().includes(query.toLowerCase()))
      
      if (match) {
        results.push({ ...entry, layer: l })
      }
    }
  }
  
  return results
}
