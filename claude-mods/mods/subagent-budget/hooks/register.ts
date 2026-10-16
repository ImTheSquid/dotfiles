import type { Register } from 'claude-code'
import { WARN_AT, cost, fmt, parseBudget } from './budget'

const GUIDE = `Subagent budgets: to cap a subagent's token spend, put [budget: 50k] (or 200k, 1m) at the end of the Agent call's description. Omit it for no cap. The budget covers the work after the subagent's fixed starting prompt. Size it to the task: 30k for a lookup, 100k for a review, 300k for a broad search. A subagent over its budget has its tool calls refused and must report.`

export const register: Register = on => {
  const budgets = new Map<string, number>()
  const used = new Map<string, number>()
  const warned = new Set<string>()

  on('prompt.compose', async ($, e, next) => {
    const r = await next(e)
    return {
      ...r,
      sections: [...r.sections, { id: `${$.plugin.name}:guide`, text: GUIDE, scope: 'session' }],
    }
  })

  on('agent.spawn', async ($, e, next) => {
    const { budget, description } = parseBudget(e.description)
    if (budget === undefined) return next(e)

    const prompt = `${e.prompt}\n\nToken budget: ${fmt(budget)}. Work economically and report your findings before it runs out; once it is spent your tool calls are refused.`
    const r = await next({ ...e, description, prompt })
    if (r.agentId !== undefined) budgets.set(r.agentId, budget)
    return r
  }).catch(($, e, next) => next(e))

  on('turn.step', async function* ($, e, next) {
    const r = yield* next(e)
    const id = e.agentId
    if (id !== undefined && r.usage) {
      // Step 0 is the fixed prompt (system, CLAUDE.md, tool schemas); it is not charged.
      const total = (used.get(id) ?? 0) + (used.has(id) ? cost(r.usage) : 0)
      used.set(id, total)
      const budget = budgets.get(id)
      if (budget !== undefined) $.ui.status(`subagent ${fmt(total)}/${fmt(budget)}`)
    }
    return r
  })

  on('tool.call', async ($, e, next) => {
    const id = e.agentId
    const budget = id === undefined ? undefined : budgets.get(id)
    if (id === undefined || budget === undefined) return next(e)

    const spent = used.get(id) ?? 0
    if (spent >= budget) {
      return {
        deny: `${$.plugin.name}: token budget spent (${fmt(spent)}/${fmt(budget)}). Stop using tools and give your final report now.`,
      }
    }
    if (spent >= budget * WARN_AT && !warned.has(id)) {
      warned.add(id)
      const ran = await next(e)
      if (ran.deny !== undefined) return ran
      const note = `${$.plugin.name}: ${fmt(spent)}/${fmt(budget)} tokens used. Wrap up and report soon.`
      return { ...ran, context: [...(ran.context ?? []), note] }
    }
    return next(e)
  }).catch(($, e, next) => next(e))

  on('turn.complete', ($, e, next) => {
    if (e.agentId !== undefined) {
      const wasBudgeted = budgets.delete(e.agentId)
      used.delete(e.agentId)
      warned.delete(e.agentId)
      if (wasBudgeted && budgets.size === 0) $.ui.status(undefined)
    }
    return next(e)
  })
}
