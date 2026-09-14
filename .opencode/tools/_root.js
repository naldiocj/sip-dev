import * as fs from "fs"
import * as path from "path"

export function getProjectRoot(ctx) {
  const candidates = []

  if (ctx.directory && ctx.directory !== "/" && ctx.directory !== ".") candidates.push(ctx.directory)
  if (ctx.worktree && ctx.worktree !== "/" && ctx.worktree !== ".") candidates.push(ctx.worktree)

  try {
    const cwd = process.cwd()
    if (cwd && cwd !== "/" && !candidates.includes(cwd)) candidates.push(cwd)
  } catch {}

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

  for (const c of candidates) {
    try {
      if (fs.existsSync(c)) return c
    } catch {}
  }

  try {
    let cur = process.cwd()
    while (cur && cur !== "/" && cur !== ".") {
      if (fs.existsSync(path.join(cur, "opencode.json"))) return cur
      const parent = path.dirname(cur)
      if (parent === cur) break
      cur = parent
    }
  } catch {}

  return candidates[0] || process.cwd() || "."
}
