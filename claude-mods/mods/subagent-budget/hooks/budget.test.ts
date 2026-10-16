import { test, expect } from 'claude-code/testing'
import { cost, parseBudget } from './budget'

test('parses k, m and bare budgets and strips the tag', () => {
  expect(parseBudget('scan repo [budget: 50k]')).toEqual({ budget: 50_000, description: 'scan repo' })
  expect(parseBudget('big job [Budget: 1.5M]')).toEqual({ budget: 1_500_000, description: 'big job' })
  expect(parseBudget('tiny [budget: 800]').budget).toBe(800)
  expect(parseBudget('no tag')).toEqual({ description: 'no tag' })
})

test('cost excludes cache reads', () => {
  expect(cost({ input_tokens: 10, output_tokens: 20, cache_creation_input_tokens: 5 })).toBe(35)
})
