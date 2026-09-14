import * as fs from "fs"
import * as path from "path"

export function getProjectRoot(ctx: { worktree?: string; directory?: string }): string {
  const candidates: string[] = []

  // Prefer explicit directory/worktree if they look like real project paths
  if (ctx.directory && ctx.directory !== "/" && ctx.directory !== ".") candidates.push(ctx.directory)
  if (ctx.worktree && ctx.worktree !== "/" && ctx.worktree !== ".") candidates.push(ctx.worktree)

  // cwd is often the most reliable when launched from project dir
  try {
    const cwd = process.cwd()
    if (cwd && cwd !== "/" && !candidates.includes(cwd)) candidates.push(cwd)
  } catch {}

  // Pick first candidate that actually contains project markers
  for (const c of candidates) {
    try {
      if (
        fs.existsSync(path.join(c, "opencode.json")) ||
        fs.existsSync(path.join(c, ".opencode")) ||
        fs.existsSync(path.join(c, ".behavior-os"))
      ) {
        return c
      }
    } catch {}
  }

  // Fallback: first non-root candidate
  for (const c of candidates) {
    try {
      if (fs.existsSync(c)) return c
    } catch {}
  }

  // Walk up from cwd looking for opencode.json
  try {
    let cur = process.cwd()
    while (cur && cur !== "/" && cur !== ".") {
      if (fs.existsSync(path.join(cur, "opencode.json"))) return cur
      const parent = path.dirname(cur)
      if (parent === cur) break
      cur = parent
    }
  } catch {}

  // Last resort: first candidate or cwd
  return candidates[0] || process.cwd() || "."
}
