export const WARN_AT = 0.8

const TAG = /\s*\[budget:\s*(\d+(?:\.\d+)?)\s*([km])?\]\s*/i

/** Pulls a `[budget: 50k]` tag out of a description. */
export function parseBudget(description: string): { budget?: number; description: string } {
  const m = TAG.exec(description)
  if (!m) return { description }
  const unit = m[2]?.toLowerCase()
  const scale = unit === 'm' ? 1_000_000 : unit === 'k' ? 1_000 : 1
  return {
    budget: Math.round(Number(m[1]) * scale),
    description: description.replace(TAG, ' ').trim(),
  }
}

/** Uncached input + output + cache writes; cache reads are not counted. */
export function cost(u: {
  input_tokens: number
  output_tokens: number
  cache_creation_input_tokens: number
}): number {
  return u.input_tokens + u.output_tokens + u.cache_creation_input_tokens
}

export function fmt(n: number): string {
  return n >= 1000 ? `${Math.round(n / 100) / 10}k` : String(n)
}

/** A fixed-width bar of `width` cells filled to used/budget, capped at full. */
export function bar(used: number, budget: number, width = 12): string {
  const filled = Math.min(width, Math.round((used / budget) * width))
  return '█'.repeat(filled) + '░'.repeat(width - filled)
}
