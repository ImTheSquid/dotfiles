export type Run = {
  description: string
  budget: number
  /** Tokens charged so far; null until the uncharged first step lands. */
  used: number | null
  warned: boolean
}

declare module 'claude-code' {
  interface PluginState {
    'subagent-budget': { runs: Record<string, Run> }
  }
}
