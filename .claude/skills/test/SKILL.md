---
name: test
description: Write or run tests for specified code
user-invocable: true
argument-hint: file or feature to test
---

Write or run tests for: $ARGUMENTS

## Conventions

- Test files: `[name].test.ts` next to source files
- Framework: vitest + @testing-library/react
- No snapshot tests — they rot quickly
- No mocking internals — mock at boundaries (db, external APIs)
- Test behavior, not implementation

## Test Patterns

### tRPC Router Tests
```typescript
import { describe, it, expect } from 'vitest'
import { createCaller } from '../trpc'

describe('[router]', () => {
  it('returns data for authenticated user', async () => {
    const caller = createCaller({ session: mockSession, db })
    const result = await caller.[procedure]()
    expect(result).toBeDefined()
  })

  it('rejects unauthenticated access', async () => {
    const caller = createCaller({ session: null, db })
    await expect(caller.[procedure]()).rejects.toThrow('UNAUTHORIZED')
  })
})
```

### Zod Schema Tests
```typescript
describe('Create[Entity]Schema', () => {
  it('accepts valid input', () => {
    const result = schema.safeParse(validData)
    expect(result.success).toBe(true)
  })
  it('rejects invalid input', () => {
    const result = schema.safeParse(invalidData)
    expect(result.success).toBe(false)
  })
})
```

## Running

```bash
bun test              # Run all tests
bun test src/path     # Run specific tests
bun test --watch      # Watch mode
```
