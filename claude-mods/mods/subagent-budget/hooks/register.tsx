import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

import type { Run } from '../types'
import { WARN_AT, bar, cost, fmt, parseBudget } from './budget'

const GUIDE = `Token budgets: to cap a subagent's token spend, put [budget: 50k] (or 200k, 1m) at the end of the Agent call's description. Omit it for no cap. The budget covers the work after the subagent's fixed starting prompt. Size it to the task: 30k for a lookup, 100k for a review, 300k for a broad search. A subagent over its budget has its tool calls refused and must report.`

// Keyed by agentId. Held in $.state so live budgets survive a hot reload.
const runs = atom({ plugin: 'subagent-budget', key: 'runs' } as const, {})

function without(all: Record<string, Run>, id: string): Record<string, Run> {
  const { [id]: _, ...rest } = all
  return rest
}

export const register: Register = on => {
  // On the Agent tool rather than the system prompt: org policy holds prompt.compose past the user tier.
  on('tool.describe', { tool: 'Agent' }, async ($, e, next) => {
    const r = await next(e)
    return { ...r, description: `${r.description}\n\n${GUIDE}` }
  })

  on('agent.spawn', async ($, e, next) => {
    const { budget, description } = parseBudget(e.description)
    if (budget === undefined) return next(e)

    const prompt = `${e.prompt}\n\nToken budget: ${fmt(budget)}. Work economically and report your findings before it runs out; once it is spent your tool calls are refused.`
    const r = await next({ ...e, description, prompt })
    const id = r.agentId
    if (id !== undefined) {
      await update($, runs, all => ({ ...all, [id]: { description, budget, used: null, warned: false } }))
    }
    return r
  }).catch(($, e, next) => next(e))

  on('turn.step', async function* ($, e, next) {
    const r = yield* next(e)
    const id = e.agentId
    const usage = r.usage
    if (id !== undefined && usage) {
      // The first step is the fixed prompt (system, CLAUDE.md, tool schemas); it is not charged.
      await update($, runs, all => {
        const run = all[id]
        if (!run) return all
        return { ...all, [id]: { ...run, used: run.used === null ? 0 : run.used + cost(usage) } }
      })
    }
    return r
  })

  on('tool.call', async ($, e, next) => {
    const id = e.agentId
    if (id === undefined) return next(e)
    const run = (await read($, runs))[id]
    if (!run) return next(e)

    const spent = run.used ?? 0
    if (spent >= run.budget) {
      return {
        deny: `${$.plugin.name}: token budget spent (${fmt(spent)}/${fmt(run.budget)}). Stop using tools and give your final report now.`,
      }
    }
    if (spent >= run.budget * WARN_AT && !run.warned) {
      await update($, runs, all => (all[id] ? { ...all, [id]: { ...all[id], warned: true } } : all))
      const ran = await next(e)
      if (ran.deny !== undefined) return ran
      const note = `${$.plugin.name}: ${fmt(spent)}/${fmt(run.budget)} tokens used. Wrap up and report soon.`
      return { ...ran, context: [...(ran.context ?? []), note] }
    }
    return next(e)
  }).catch(($, e, next) => next(e))

  on('turn.complete', async ($, e, next) => {
    const id = e.agentId
    if (id !== undefined) await update($, runs, all => (all[id] ? without(all, id) : all))
    return next(e)
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const live = Object.entries(await read($, runs))
    if (e.props.hasSurvey || live.length === 0) return next(e)

    const { Box, Text } = $.ui.resolve(e)
    const width = Math.min(40, Math.max(...live.map(([, r]) => r.description.length)))
    return (
      <Box flexDirection="column">
        {live.map(([id, r]) => {
          const used = r.used ?? 0
          const color = used >= r.budget ? 'error' : used >= r.budget * WARN_AT ? 'warning' : 'subtle'
          return (
            <Box key={id} flexDirection="row" gap={1}>
              <Box width={width}>
                <Text wrap="truncate-end">{r.description}</Text>
              </Box>
              <Text color={color}>{bar(used, r.budget)}</Text>
              <Text tabular dimColor>
                {fmt(used)}/{fmt(r.budget)}
              </Text>
            </Box>
          )
        })}
      </Box>
    )
  })
}
