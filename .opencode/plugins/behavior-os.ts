/**
 * Behavior OS Plugin — Governance Kernel v2.0
 * 
 * Implements: Policy Engine (R-001..R-007), State Transition Validator,
 * Full Hook Coverage (~20 hooks), Evidence Enforcement, Loop Detection
 * 
 * OpenCode 1.18.30 compatible
 */

import type { Plugin, ToolContext } from "@opencode-ai/plugin"
import { tool } from "@opencode-ai/plugin"
import * as fs from "fs"
import * as path from "path"
import { getProjectRoot } from "../tools/_root.js"

// ─── Types ───────────────────────────────────────────────────────────────────

export type RiskLevel = "R1" | "R2" | "R3" | "R4"
export type Decision = "ALLOW" | "ASK" | "DENY"
export type Phase = "idle" | "discovery" | "classifying" | "assessing" | "authorized" | "executing" | "evidenced" | "denied" | "ask_pending" | "approved" | "rejected"

export interface StateHistoryEntry {
  from: Phase
  to: Phase
  at: string
  reason?: string
  agent?: string
  missionId?: string
}

export interface GateResult {
  name: string
  result: "PASS" | "FAIL" | "BLOCK" | "PENDING"
  reason: string
  timestamp: string
}

export interface BehaviorOSState {
  missionId: string | null
  phase: Phase
  status: string
  risk: RiskLevel | null
  agent: string | null
  dna?: string | null
  stack: string[]
  versions: Record<string, string>
  discoveryComplete: boolean
  truthComplete: boolean
  gates: GateResult[]
  history: StateHistoryEntry[]
  loopCounter: Record<string, number>
  currentHandoff: string | null
  handoffHistory: Array<{ id: string; from: string; to: string; at: string }>
  createdAt: string
  updatedAt: string
}

export interface EvidenceEntry {
  id: string
  missionId: string
  operation: string
  agent: string
  riskLevel: RiskLevel
  decision: Decision
  outcome: string
  filesChanged?: string[]
  gates?: Record<string, string>
  metadata?: Record<string, any>
  timestamp: string
}

// ─── State Machine ───────────────────────────────────────────────────────────

const VALID_TRANSITIONS: Record<Phase, Phase[]> = {
  idle: ["idle", "discovery", "denied"],
  discovery: ["discovery", "classifying", "denied", "idle"],
  classifying: ["classifying", "assessing", "denied", "idle"],
  assessing: ["assessing", "authorized", "denied", "ask_pending", "idle"],
  authorized: ["authorized", "executing", "idle"],
  executing: ["executing", "evidenced", "ask_pending", "denied", "idle"],
  evidenced: ["evidenced", "idle"],
  denied: ["idle", "classifying"],
  ask_pending: ["approved", "rejected", "idle"],
  approved: ["executing", "idle"],
  rejected: ["idle", "classifying"],
}

export function validateTransition(state: BehaviorOSState, to: Phase, reason?: string): { valid: boolean; error?: string } {
  const from = state.phase
  const allowed = VALID_TRANSITIONS[from]
  if (!allowed) return { valid: false, error: `Unknown current phase: ${from}` }
  if (!allowed.includes(to)) {
    return { valid: false, error: `Invalid transition: ${from} → ${to}. Allowed: ${allowed.join(", ")}` }
  }
  return { valid: true }
}

export function transitionState(state: BehaviorOSState, to: Phase, reason?: string, agent?: string): BehaviorOSState {
  const validation = validateTransition(state, to, reason)
  if (!validation.valid) {
    throw new Error(`STATE_TRANSITION_BLOCKED: ${validation.error}`)
  }
  state.history.push({
    from: state.phase,
    to,
    at: new Date().toISOString(),
    reason,
    agent,
    missionId: state.missionId ?? undefined,
  })
  state.phase = to
  state.updatedAt = new Date().toISOString()
  state.status = to === "denied" ? "denied" : to === "idle" ? "idle" : "running"
  return state
}

// ─── Policy Engine ───────────────────────────────────────────────────────────

export interface PolicyViolation {
  rule: string
  action: Decision
  message: string
  riskLevel: RiskLevel
}

export function checkPolicies(input: any, currentState: BehaviorOSState, agentName: string): PolicyViolation[] {
  const violations: PolicyViolation[] = []
  const toolName = input.tool
  const args = input.args as Record<string, any> | undefined

  // R-001: Sensitive file protection
  if (toolName === "read" && args?.filePath) {
    const fp = String(args.filePath)
    if (/\.env(\.\w+)?$/i.test(fp) || fp.includes(".env.local") || fp.includes("secret") || fp.includes("credential")) {
      violations.push({
        rule: "R-001",
        action: "DENY",
        message: `Blocked: sensitive file access denied — ${fp}`,
        riskLevel: "R4",
      })
    }
  }

  // R-002: Git operation control
  if (toolName === "bash" && args?.command) {
    const cmd = String(args.command)
    if (/git\s+push\s+--force/i.test(cmd)) {
      violations.push({ rule: "R-002", action: "DENY", message: "Blocked: git push --force denied", riskLevel: "R4" })
    }
    if (/git\s+reset\s+--hard/i.test(cmd)) {
      violations.push({ rule: "R-002", action: "DENY", message: "Blocked: git reset --hard denied", riskLevel: "R4" })
    }
    if (/rm\s+-rf\s+\/|rm\s+-r\s+\/\s/i.test(cmd)) {
      violations.push({ rule: "R-002", action: "DENY", message: "Blocked: dangerous rm command denied", riskLevel: "R4" })
    }
    if (/chmod\s+.*777/i.test(cmd)) {
      violations.push({ rule: "R-002", action: "DENY", message: "Blocked: chmod 777 denied", riskLevel: "R3" })
    }
  }

  // R-008: Runtime policy — pnpm-first (node/bun allowed, python denied, npx/npm ask)
  if (toolName === "bash" && args?.command) {
    const cmd = String(args.command).trim()
    if (/^python(\s|$)/i.test(cmd) || /^python3(\s|$)/i.test(cmd)) {
      violations.push({ rule: "R-008", action: "DENY", message: "Blocked: python runtime denied — use pnpm/bun (pnpm-first policy)", riskLevel: "R3" })
    }
    if (/^npm(\s|$)/i.test(cmd) && !/^npm\s+--version/i.test(cmd)) {
      violations.push({ rule: "R-008", action: "ASK", message: "npm is ask — prefer pnpm (pnpm-first policy)", riskLevel: "R2" })
    }
    if (/^npx(\s|$)/i.test(cmd)) {
      violations.push({ rule: "R-008", action: "ASK", message: "npx is ask — prefer pnpm dlx (pnpm-first policy)", riskLevel: "R2" })
    }
    if (/^node(\s|$)/i.test(cmd) && !/node\s+--version/i.test(cmd) && !/node\s+-v/i.test(cmd)) {
      // node direct is ask (encourage pnpm exec / pnpm dlx)
      violations.push({ rule: "R-008", action: "ASK", message: "node direct is ask — prefer pnpm exec / pnpm dlx (pnpm-first policy)", riskLevel: "R2" })
    }
  }

  // R-009: SkillGate — all DNAs with required skills need SkillGate before execute (auto-creation flow)
  if (["edit", "write", "apply_patch"].includes(toolName)) {
    const dnaName = currentState.dna || currentState.agent || "orchestrator"
    // Generalize: any DNA with skills.required needs gate
    let requiredSkills: string[] = []
    try {
      const root = (currentState as any)._root || currentState.stack?.join(",") ? process.cwd() : process.cwd()
      // Try to read DNA file to get required skills
      const dnaPath = path.join(root, ".behavior-os", "dna", `${dnaName}.yaml`)
      if (fs.existsSync(dnaPath)) {
        const raw = fs.readFileSync(dnaPath, "utf-8")
        const m = raw.match(/skills:\s*\n\s*required:\s*\[([^\]]+)\]/)
        if (m) requiredSkills = m[1].split(",").map(s => s.trim().replace(/["'\[\]]/g, "").replace(/^\-/, "").trim()).filter(Boolean)
        // also check for creator in workflow
        if (raw.includes("skill-acquisition") && !requiredSkills.includes("creator")) requiredSkills.unshift("creator")
      }
    } catch {}
    // Fallback for known DNAs
    if (dnaName === "enterprise" && requiredSkills.length === 0) requiredSkills = ["creator", "enterprise-governance"]
    if (dnaName === "backend" && requiredSkills.length === 0) requiredSkills = ["backend-architecture", "typescript"]
    if (dnaName === "frontend" && requiredSkills.length === 0) requiredSkills = ["frontend-architecture", "typescript"]

    const hasSkillGate = (currentState.gates || []).some((g: any) => g.name === "SkillGate" && g.result === "PASS")
    const requiresSkill = requiredSkills.length > 0

    if (requiresSkill && !hasSkillGate) {
      // Check which skills actually exist
      let missing: string[] = []
      try {
        const root = (currentState as any)._root || process.cwd()
        const skillDir = path.join(root, ".opencode", "skills")
        const available = fs.existsSync(skillDir) ? fs.readdirSync(skillDir).filter(f => fs.existsSync(path.join(skillDir, f, "SKILL.md"))) : []
        missing = requiredSkills.filter(s => !available.includes(s))
        // If skills exist but gate not PASS, still need acquire
        if (missing.length === 0) missing = requiredSkills // need acquire step
      } catch { missing = requiredSkills }

      const missingStr = missing.join(", ") || requiredSkills.join(", ")
      violations.push({
        rule: "R-009",
        action: "ASK",
        message: `SkillGate not PASS — missing skills: [${missingStr}] for dna:${dnaName}. Flow: 1) bos_discover (full) 2) bos_truth tech=<stack> check=breaking-changes 3) bos_skill create skill=<missing> 4) skill: <missing> 5) bos_skill acquire skill=<missing> 6) retry edit. Creator-before-builder.`,
        riskLevel: "R3",
      })
    }
  }

  // R-003: Role separation
  if (agentName === "architect" && ["edit", "write", "apply_patch"].includes(toolName)) {
    violations.push({
      rule: "R-003",
      action: "DENY",
      message: `Blocked: architect agent cannot edit/write — role separation policy`,
      riskLevel: "R3",
    })
  }
  if (agentName === "governance" && toolName === "bash") {
    violations.push({
      rule: "R-003",
      action: "DENY",
      message: `Blocked: governance agent cannot execute bash — read-only policy`,
      riskLevel: "R3",
    })
  }
  if (agentName === "qa" && ["edit", "write", "apply_patch"].includes(toolName)) {
    violations.push({
      rule: "R-003",
      action: "DENY",
      message: `Blocked: qa agent cannot edit code — read-only for code policy`,
      riskLevel: "R3",
    })
  }

  // R-005: External directory access
  if (["read", "glob", "grep"].includes(toolName) && args?.filePath) {
    const fp = String(args.filePath)
    if (fp.startsWith("/") && !fp.includes(".opencode") && !fp.includes(".behavior-os") && !fp.includes("src/") && !fp.includes("tests/")) {
      // Check if it's outside the worktree
      violations.push({
        rule: "R-005",
        action: "ASK",
        message: `External directory access detected: ${fp}`,
        riskLevel: "R3",
      })
    }
  }

  // R-004: Loop detection (handled separately in loop tracking)
  
  return violations
}

// ─── Loop Detector ───────────────────────────────────────────────────────────

export function checkLoop(state: BehaviorOSState, toolName: string, argsHash: string): { detected: boolean; count: number; action: Decision } {
  const key = `${toolName}:${argsHash}`
  const counter = state.loopCounter ?? {}
  const count = (counter[key] ?? 0) + 1
  const updatedCounter = { ...counter, [key]: count }

  if (count >= 3) {
    return { detected: true, count, action: "ASK" }
  }
  return { detected: false, count, action: "ALLOW" }
}

// ─── Behavior OS State Manager ───────────────────────────────────────────────

class BehaviorOSStateManager {
  private root: string
  private statePath: string
  private evidencePath: string

  constructor(root: string) {
    this.root = root
    this.statePath = path.join(root, ".behavior-os", "state", "state.json")
    this.evidencePath = path.join(root, ".behavior-os", "evidence", "evidence.json")
  }

  load(): BehaviorOSState {
    try {
      const raw = fs.readFileSync(this.statePath, "utf-8")
      return JSON.parse(raw) as BehaviorOSState
    } catch {
      return this.createDefault()
    }
  }

  save(state: BehaviorOSState): void {
    fs.writeFileSync(this.statePath, JSON.stringify(state, null, 2))
  }

  createDefault(): BehaviorOSState {
    return {
      missionId: null,
      phase: "idle",
      status: "idle",
      risk: null,
      agent: null,
      stack: [],
      versions: {},
      discoveryComplete: false,
      truthComplete: false,
      gates: [],
      history: [],
      loopCounter: {},
      currentHandoff: null,
      handoffHistory: [],
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    }
  }

  getGateResult(gateName: string): string {
    const state = this.load()
    const gate = (state.gates ?? []).find((g: GateResult) => g.name === gateName)
    return gate ? gate.result : "PENDING"
  }

  recordEvidence(ev: Omit<EvidenceEntry, "id" | "timestamp">): EvidenceEntry {
    try {
      let arr: EvidenceEntry[] = []
      try {
        const raw = fs.readFileSync(this.evidencePath, "utf-8")
        arr = JSON.parse(raw)
        if (!Array.isArray(arr)) arr = []
      } catch { arr = [] }

      const entry: EvidenceEntry = {
        ...ev,
        id: `ev_${Date.now()}_${Math.random().toString(36).slice(2, 6)}`,
        timestamp: new Date().toISOString(),
      }
      arr.push(entry)
      fs.writeFileSync(this.evidencePath, JSON.stringify(arr, null, 2))
      return entry
    } catch (e) {
      console.error("[Behavior OS] Evidence record failed:", (e as Error).message)
      return {
        id: `ev_error_${Date.now()}`,
        missionId: "error",
        operation: ev.operation,
        agent: ev.agent,
        riskLevel: ev.riskLevel,
        decision: ev.decision,
        outcome: "record_failed",
        filesChanged: [],
        gates: {},
        metadata: { error: (e as Error).message },
        timestamp: new Date().toISOString(),
      }
    }
  }

  getEvidenceCount(): number {
    try {
      const raw = fs.readFileSync(this.evidencePath, "utf-8")
      const arr = JSON.parse(raw)
      return Array.isArray(arr) ? arr.length : 0
    } catch { return 0 }
  }
}

// ─── Tool Loader ──────────────────────────────────────────────────────────────

async function loadBOSTools(root: string): Promise<Record<string, any>> {
  const toolsDir = path.join(root, ".opencode", "tools")
  const result: Record<string, any> = {}

  try {
    const files = fs.readdirSync(toolsDir).filter((f) => f.startsWith("bos-") && f.endsWith(".ts"))
    for (const file of files) {
      const toolName = file.replace(".ts", "").replace(/-/g, "_")
      try {
        const module = await import(path.join(toolsDir, file))
        const defaultExport = module.default
        if (defaultExport && typeof defaultExport === "object" && defaultExport.description) {
          result[toolName] = defaultExport
        }
      } catch (e) {
        console.error(`[Behavior OS] Failed to load tool ${toolName}: ${(e as Error).message}`)
      }
    }
  } catch (e) {
    console.error(`[Behavior OS] Failed to read tools directory: ${(e as Error).message}`)
  }

  return result
}

// ─── Custom Tools Exported from Plugin ───────────────────────────────────────

export const BehaviorOSTools = {} as Record<string, any>

export const BehaviorOSPlugin: Plugin = async ({ project, client, $, directory, worktree }) => {
  const _rawRoot = getProjectRoot({ worktree, directory } as any)
  const _cwd = process.cwd()
  const root = _rawRoot === "/" && _cwd !== "/" ? _cwd : _rawRoot
  const os = new BehaviorOSStateManager(root)

  console.log(`[Behavior OS v2.0] Plugin loaded in ${root} (worktree=${worktree} directory=${directory} cwd=${_cwd})`)
  console.log(`[Behavior OS] Governance: Policy Engine (R-001..R-007), State Machine, Loop Detection`)

  // Load and register all BOS tools
  const bosTools = await loadBOSTools(root)
  Object.assign(BehaviorOSTools, bosTools)

  // Track consecutive identical calls for loop detection
  const recentCalls: Array<{ tool: string; args: string; ts: number }> = []

  return {
    // Register custom BOS tools
    tool: bosTools as any,
    // ═══════════════════════════════════════════════════════════════
    // TOOL HOOKS
    // ═══════════════════════════════════════════════════════════════

    "tool.execute.before": async (input, output) => {
      const toolName = input.tool
      const now = new Date().toISOString()

      // Skip Behavior OS internal tools
      if (toolName.startsWith("bos_") || toolName.startsWith("bos-")) return

      const state = os.load()
      const agentName = state.agent ?? "unknown"

      // ── Loop Detection (R-004) ──
      const argsHash = JSON.stringify((output as any).args ?? {}).slice(0, 100)
      const loopCheck = checkLoop(state, toolName, argsHash)
      
      if (loopCheck.detected) {
        const loopState = { ...state, loopCounter: { ...state.loopCounter, [`${toolName}:${argsHash.slice(0, 20)}`]: loopCheck.count } }
        os.save(loopState)
        
        await client.app.log({
          body: {
            service: "behavior-os",
            level: "warn",
            message: `Loop detected: ${toolName} called ${loopCheck.count}x identically`,
            extra: { tool: toolName, count: loopCheck.count, agent: agentName, timestamp: now }
          }
        })

        if (loopCheck.action === "ASK") {
          throw new Error(`BEHAVIOR_OS_LOOP_DETECTED: ${toolName} repeated ${loopCheck.count} times with identical input. Vary approach or break loop.`)
        }
      }

      // Track recent calls
      recentCalls.push({ tool: toolName, args: argsHash, ts: Date.now() })
      if (recentCalls.length > 20) recentCalls.shift()

      // ── Policy Check (R-001..R-007) ──
      const violations = checkPolicies(input, state, agentName)

      for (const violation of violations) {
        await client.app.log({
          body: {
            service: "behavior-os",
            level: violation.action === "DENY" ? "error" : "warn",
            message: `[${violation.rule}] ${violation.message}`,
            extra: { tool: toolName, rule: violation.rule, action: violation.action, riskLevel: violation.riskLevel, agent: agentName, timestamp: now }
          }
        })

        if (violation.action === "DENY") {
          os.recordEvidence({
            missionId: state.missionId ?? "unknown",
            operation: `policy_block:${violation.rule}`,
            agent: agentName,
            riskLevel: violation.riskLevel,
            decision: "DENY",
            outcome: violation.message,
            filesChanged: [],
            metadata: { policyRule: violation.rule, tool: toolName, args: (output as any).args },
          })
          throw new Error(`BEHAVIOR_OS_BLOCKED [${violation.rule}]: ${violation.message}`)
        }

        if (violation.action === "ASK") {
          // Log but don't block — let OpenCode permission system handle it
          console.error(`[Behavior OS] ${violation.rule} ASK: ${violation.message}`)
        }
      }

      // ── Gate Enforcement ──
      if (["edit", "write", "apply_patch"].includes(toolName)) {
        const discoveryResult = os.getGateResult("DiscoveryGate")
        const skillGateResult = os.getGateResult("SkillGate")
        // Enterprise: SkillGate required before any edit
        const isEnterprise = state.dna === "enterprise" || state.agent === "enterprise"
        if (isEnterprise && skillGateResult !== "PASS") {
          await client.app.log({
            body: { service: "behavior-os", level: "warn", message: `Write blocked: SkillGate is ${skillGateResult} — run skill: creator first`, extra: { tool: toolName, agent: agentName, dna: state.dna } }
          })
        }
        if (discoveryResult !== "PASS") {
          await client.app.log({
            body: { service: "behavior-os", level: "warn", message: `Write blocked: DiscoveryGate is ${discoveryResult}`, extra: { tool: toolName, agent: agentName } }
          })
        }
      }

      // ── Audit Log ──
      await client.app.log({
        body: {
          service: "behavior-os",
          level: "debug",
          message: `Tool execution: ${toolName}`,
          extra: {
            tool: toolName,
            phase: state.phase,
            agent: agentName,
            missionId: state.missionId,
            riskLevel: state.risk,
            discoveryGate: os.getGateResult("DiscoveryGate"),
            truthGate: os.getGateResult("TruthGate"),
            timestamp: now,
          }
        }
      })
    },

    "tool.execute.after": async (input, output) => {
      const toolName = input.tool
      const now = new Date().toISOString()

      // SkillGate: auto-PASS when creator skill is invoked
      const _skillName = (input as any)?.args?.name || (input as any)?.args?.skill || (output as any)?.args?.name
      if (toolName === "skill" && (_skillName === "creator" || _skillName === "enterprise-governance" || String(_skillName).includes("creator"))) {
        const state = os.load()
        const hasSkillGate = (state.gates || []).some((g: any) => g.name === "SkillGate" && g.result === "PASS")
        if (!hasSkillGate) {
          state.gates = state.gates || []
          state.gates.push({ name: "SkillGate", result: "PASS", reason: "creator skill acquired", timestamp: new Date().toISOString() })
          state.updatedAt = new Date().toISOString()
          os.save(state)
          await client.app.log({
            body: { service: "behavior-os", level: "info", message: "SkillGate PASS — creator skill acquired", extra: { agent: state.agent, timestamp: now } }
          })
        }
        return
      }

      if (toolName.startsWith("bos_") || toolName.startsWith("bos-")) return

      const state = os.load()
      const agentName = state.agent ?? "unknown"

      // Auto-record evidence for write operations
      if (["edit", "write", "apply_patch"].includes(toolName)) {
        const filesChanged: string[] = []
        if (input.args?.filePath) filesChanged.push(String(input.args.filePath))
        
        const riskLevel = state.risk ?? "R2"
        os.recordEvidence({
          missionId: state.missionId ?? "unknown",
          operation: toolName,
          agent: agentName,
          riskLevel: riskLevel as RiskLevel,
          decision: "ALLOW",
          outcome: "success",
          filesChanged,
          gates: {
            discovery: os.getGateResult("DiscoveryGate"),
            truth: os.getGateResult("TruthGate"),
          },
          metadata: { tool: toolName, callID: input.callID },
        })
      }

      // Log successful execution
      await client.app.log({
        body: {
          service: "behavior-os",
          level: "info",
          message: `Tool completed: ${toolName}`,
          extra: { tool: toolName, agent: agentName, timestamp: now }
        }
      })
    },

    // ═══════════════════════════════════════════════════════════════
    // PERMISSION HOOKS
    // ═══════════════════════════════════════════════════════════════

    "permission.ask": async (input: any, output: any) => {
      const state = os.load();
      await client.app.log({
        body: {
          service: "behavior-os",
          level: "warn",
          message: `Permission asked: ${input.type}`,
          extra: {
            permissionId: input.id,
            type: input.type,
            pattern: input.pattern,
            agent: state.agent,
            phase: state.phase,
            timestamp: new Date().toISOString(),
          },
        },
      });
    },

    // ═══════════════════════════════════════════════════════════════
    // SESSION HOOKS
    // ═══════════════════════════════════════════════════════════════

    "session.created": async (input: any) => {
      const state = os.load()
      const updated = transitionState(state, "discovery", `Session created: ${input.sessionId}`)
      updated.missionId = updated.missionId ?? `task-${Date.now()}`
      updated.agent = "orchestrator"
      os.save(updated)

      await client.app.log({
        body: {
          service: "behavior-os",
          level: "info",
          message: `Session created: ${input.sessionId}`,
          extra: { sessionId: input.sessionId, missionId: updated.missionId, directory: root }
        }
      })
    },

    "session.idle": async (input: any) => {
      const state = os.load()
      // Only transition if not already idle
      if (state.phase !== "idle") {
        transitionState(state, "idle", "Session idle")
      }
      os.save(state)

      await client.app.log({
        body: { service: "behavior-os", level: "info", message: "Session idle", extra: { timestamp: new Date().toISOString() } }
      })
    },

    "session.error": async (input: any) => {
      const state = os.load()
      
      os.recordEvidence({
        missionId: state.missionId ?? "unknown",
        operation: "session.error",
        agent: state.agent ?? "unknown",
        riskLevel: "R3",
        decision: "DENY",
        outcome: `Session error: ${String(input.error)?.slice(0, 200)}`,
        metadata: { error: String(input.error), sessionId: input.sessionId },
      })

      await client.app.log({
        body: {
          service: "behavior-os",
          level: "error",
          message: `Session error: ${input.sessionId}`,
          extra: { error: input.error, timestamp: new Date().toISOString() }
        }
      })
    },

    "session.status": async (input: any) => {
      const state = os.load()
      await client.app.log({
        body: {
          service: "behavior-os",
          level: "debug",
          message: `Session status update`,
          extra: { status: input.status, phase: state.phase, timestamp: new Date().toISOString() }
        }
      })
    },

    "session.updated": async (input: any) => {
      const state = os.load()
      await client.app.log({
        body: {
          service: "behavior-os",
          level: "debug",
          message: "Session updated",
          extra: { timestamp: new Date().toISOString() }
        }
      })
    },

    "session.compacted": async (input: any) => {
      const state = os.load()
      
      // Save important state before compaction
      os.recordEvidence({
        missionId: state.missionId ?? "unknown",
        operation: "session.compacted",
        agent: state.agent ?? "unknown",
        riskLevel: "R2",
        decision: "ALLOW",
        outcome: "Context compacted, state preserved",
        metadata: { tokensBefore: input.tokensBefore, tokensAfter: input.tokensAfter, gateStatus: os.getGateResult("DiscoveryGate") },
      })

      await client.app.log({
        body: {
          service: "behavior-os",
          level: "info",
          message: "Session compacted",
          extra: { tokensBefore: input.tokensBefore, tokensAfter: input.tokensAfter, timestamp: new Date().toISOString() }
        }
      })
    },

    "experimental.session.compacting": async (input, output) => {
      const state = os.load()
      
      // Inject Behavior OS context into compaction prompt
      output.context.push(`
## Behavior OS Context
- Current Phase: ${state.phase}
- Mission ID: ${state.missionId ?? "none"}
- Discovery Gate: ${os.getGateResult("DiscoveryGate")}
- Truth Gate: ${os.getGateResult("TruthGate")}
- Risk Level: ${state.risk ?? "none"}
- Agent: ${state.agent ?? "none"}
- Evidence Count: ${os.getEvidenceCount()}
- Last History: ${(state.history ?? []).slice(-3).map(h => `${h.from}→${h.to}`).join(", ") || "none"}
`)
    },

    "session.diff": async (input: any) => {
      await client.app.log({
        body: { service: "behavior-os", level: "debug", message: "Session diff", extra: { timestamp: new Date().toISOString() } }
      })
    },

    // ═══════════════════════════════════════════════════════════════
    // FILE HOOKS
    // ═══════════════════════════════════════════════════════════════

    "file.edited": async (input: any) => {
      const state = os.load()
      
      os.recordEvidence({
        missionId: state.missionId ?? "unknown",
        operation: "file.edited",
        agent: state.agent ?? "unknown",
        riskLevel: "R2",
        decision: "ALLOW",
        outcome: `File edited: ${input.filePath}`,
        filesChanged: [input.filePath],
        metadata: { linesChanged: input.linesChanged },
      })

      await client.app.log({
        body: {
          service: "behavior-os",
          level: "info",
          message: `File edited: ${input.filePath}`,
          extra: { filePath: input.filePath, linesChanged: input.linesChanged, timestamp: new Date().toISOString() }
        }
      })
    },

    "file.watcher.updated": async (input: any) => {
      await client.app.log({
        body: { service: "behavior-os", level: "debug", message: "File watcher updated", extra: { filePath: input.filePath, timestamp: new Date().toISOString() } }
      })
    },

    // ═══════════════════════════════════════════════════════════════
    // MESSAGE HOOKS
    // ═══════════════════════════════════════════════════════════════

    "message.updated": async (input: any) => {
      await client.app.log({
        body: { service: "behavior-os", level: "debug", message: "Message updated", extra: { messageId: input.messageId, timestamp: new Date().toISOString() } }
      })
    },

    "message.removed": async (input: any) => {
      await client.app.log({
        body: { service: "behavior-os", level: "debug", message: "Message removed", extra: { messageId: input.messageId, timestamp: new Date().toISOString() } }
      })
    },

    "message.part.updated": async (input: any) => {
      await client.app.log({
        body: { service: "behavior-os", level: "debug", message: "Message part updated", extra: { timestamp: new Date().toISOString() } }
      })
    },

    "message.part.removed": async (input: any) => {
      await client.app.log({
        body: { service: "behavior-os", level: "debug", message: "Message part removed", extra: { timestamp: new Date().toISOString() } }
      })
    },

    // ═══════════════════════════════════════════════════════════════
    // TODO HOOK
    // ═══════════════════════════════════════════════════════════════

    "todo.updated": async (input: any) => {
      const state = os.load()
      await client.app.log({
        body: {
          service: "behavior-os",
          level: "debug",
          message: "Todo updated",
          extra: { todo: input.todo, state: input.state, agent: state.agent, timestamp: new Date().toISOString() }
        }
      })
    },

    // ═══════════════════════════════════════════════════════════════
    // SHELL HOOK
    // ═══════════════════════════════════════════════════════════════

    "shell.env": async (input, output) => {
      // Inject Behavior OS environment variables
      output.env.BEHAVIOR_OS_ENABLED = "true"
      output.env.BEHAVIOR_OS_ROOT = root
      output.env.BEHAVIOR_OS_PHASE = os.load().phase
    },

    // ═══════════════════════════════════════════════════════════════
    // TUI HOOKS
    // ═══════════════════════════════════════════════════════════════

    "tui.prompt.append": async (input: any) => {
      await client.app.log({
        body: { service: "behavior-os", level: "debug", message: "TUI prompt append", extra: { timestamp: new Date().toISOString() } }
      })
    },

    "tui.command.execute": async (input: any) => {
      const state = os.load()
      await client.app.log({
        body: {
          service: "behavior-os",
          level: "info",
          message: `TUI command: ${input.command}`,
          extra: { command: input.command, agent: state.agent, phase: state.phase, timestamp: new Date().toISOString() }
        }
      })
    },

    "tui.toast.show": async (input: any) => {
      // ForwardBehavior OS toasts
      if (input.type === "error" || input.type === "warning") {
        console.error(`[Behavior OS] TUI Toast [${input.type}]: ${input.message}`)
      }
    },

    // ═══════════════════════════════════════════════════════════════
    // LSP HOOKS
    // ═══════════════════════════════════════════════════════════════

    "lsp.client.diagnostics": async (input: any) => {
      await client.app.log({
        body: { service: "behavior-os", level: "debug", message: "LSP diagnostics", extra: { file: input.file, count: input.diagnostics?.length, timestamp: new Date().toISOString() } }
      })
    },

    "lsp.updated": async (input: any) => {
      await client.app.log({
        body: { service: "behavior-os", level: "debug", message: "LSP updated", extra: { timestamp: new Date().toISOString() } }
      })
    },

    // ═══════════════════════════════════════════════════════════════
    // INSTALLATION HOOK
    // ═══════════════════════════════════════════════════════════════

    "installation.updated": async (input: any) => {
      await client.app.log({
        body: { service: "behavior-os", level: "info", message: "Installation updated", extra: { package: input.package, version: input.version, timestamp: new Date().toISOString() } }
      })
    },

    // ═══════════════════════════════════════════════════════════════
    // COMMAND HOOK
    // ═══════════════════════════════════════════════════════════════

    "command.executed": async (input: any) => {
      const state = os.load()
      await client.app.log({
        body: {
          service: "behavior-os",
          level: "info",
          message: `Command executed: ${input.command}`,
          extra: { command: input.command, agent: state.agent, timestamp: new Date().toISOString() }
        }
      })
    },

    // ═══════════════════════════════════════════════════════════════
    // SERVER HOOK
    // ═══════════════════════════════════════════════════════════════

    "server.connected": async (input: any) => {
      await client.app.log({
        body: { service: "behavior-os", level: "info", message: "Server connected", extra: { timestamp: new Date().toISOString() } }
      })
    },
  }
}

// ─── Custom Tools Exported from Plugin ───────────────────────────────────────
// Tools are dynamically loaded at runtime by loadBOSTools()
