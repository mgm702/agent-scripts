---
name: Performance Optimization
description: Audit and fix performance bottlenecks across Go, Ruby, React, React Native, Python, and C — measure first, optimize second.
triggers:
  - performance
  - slow
  - optimize
  - profiling
  - bottleneck
  - memory leak
  - N+1
  - rendering performance
---

# Performance Optimization

Audit and fix performance bottlenecks. Always measure before optimizing — never assume.

## When to Use

- Response times or frame rates are measurably slow
- Memory usage grows unbounded
- Pre-shipping performance audit on a critical path
- After a feature lands and metrics regress

## Universal Rules

- **Measure first** — get a baseline before touching code; optimization without data is guessing
- **One change at a time** — isolate what actually helped
- **Profile in production-equivalent conditions** — dev builds lie
- **No premature optimization** — if it's not slow, don't touch it

---

## Go

### Profiling Tools
- `go tool pprof` — CPU and heap profiles; attach with `net/http/pprof` in a running service
- `go tool trace` — goroutine scheduling, GC pauses, latency breakdown
- `benchstat` — compare benchmark runs statistically

### Common Issues & Fixes

**Goroutine leaks**
- Symptom: goroutine count climbs indefinitely; heap grows
- Fix: ensure every goroutine has a cancellation path (`context.Context`); use `goleak` in tests

**Excessive allocations in hot paths**
- Symptom: high GC pause time; `pprof` heap shows many small allocs
- Fix: `sync.Pool` for reusable buffers; pre-allocate slices with known capacity (`make([]T, 0, n)`)

**Interface boxing**
- Symptom: `pprof` shows `runtime.convT*` in hot path
- Fix: use concrete types in tight loops; avoid `interface{}` / `any` where performance matters

**String concatenation in loops**
- Fix: `strings.Builder` instead of `+`

**Unnecessary copying of large structs**
- Fix: pass pointers to large structs; return pointers from constructors

### Benchmarks
```go
func BenchmarkFoo(b *testing.B) {
    for b.Loop() {
        // target code
    }
}
```
Run: `go test -bench=. -benchmem -count=5`

---

## Ruby

### Profiling Tools
- `rack-mini-profiler` — per-request breakdown in Rails
- `ruby-prof` — call graph profiler; use with `RubyProf::FlatPrinter`
- `stackprof` — sampling profiler; low overhead in production
- `memory_profiler` — object allocation by gem/file/line
- `bullet` — detects N+1 queries and missing eager loads

### Common Issues & Fixes

**N+1 queries**
- Symptom: `bullet` logs `USE eager loading detected`; SQL log shows repeated queries
- Fix: `includes(:association)` or `preload` / `eager_load` depending on whether you filter on the association

**Object allocation storms**
- Symptom: `memory_profiler` shows thousands of short-lived objects per request
- Fix: freeze string literals (`# frozen_string_literal: true`); avoid building arrays/hashes inside loops

**Slow ActiveRecord queries**
- Fix: add DB indexes for `WHERE`, `ORDER BY`, `JOIN` columns; use `explain` to verify index use
- Avoid `SELECT *`; scope to needed columns with `select(:id, :name)`

**GC pressure**
- Fix: tune `RUBY_GC_HEAP_GROWTH_FACTOR` and `RUBY_GC_MALLOC_LIMIT` for your workload; measure with `GC::Profiler`

**Rack middleware overhead**
- Fix: audit `config.middleware` stack; remove unused middleware (e.g., session middleware on API-only routes)

---

## React

### Profiling Tools
- React DevTools Profiler — flame chart of render time per component
- "Highlight updates" toggle — visually shows unnecessary re-renders
- `React.Profiler` API — programmatic measurement for production

### Rules
- Minimize re-renders: components should only render when props/state change
- Stable references in `useEffect` deps — no object/array literals in dep arrays
- Never mutate state directly; always return new references
- Avoid anonymous functions as props in render (new reference every render → child re-renders)

### Optimization Toolkit

| Problem | Fix |
|---|---|
| Pure/presentational component re-renders | `React.memo` |
| Expensive derived value recomputed every render | `useMemo` |
| Event handler causes child re-render | `useCallback` |
| Long list causes slow render | `react-window` or `react-virtuoso` (>50 items) |
| Large route bundle | `lazy()` + `Suspense` |
| High-frequency state updates | Zustand or Jotai instead of Context |

### State
- Colocate state as close to usage as possible
- Split Context providers by update frequency
- Batch state updates (automatic in React 18+)
- Avoid `useEffect` for derived state — compute during render instead
- Key prop: use stable unique IDs; never array index for dynamic lists

---

## React Native

### Profiling Tools
- React DevTools Profiler — same as web; attach via Metro
- Flipper → React Native Performance plugin — JS thread + UI thread frame times
- Hermes sampling profiler — CPU flamegraph for JS execution
- `InteractionManager.runAfterInteractions` — defer heavy work until animations complete

### RN-Specific Issues & Fixes

**JS thread jank**
- Symptom: `UI thread FPS` is fine but `JS thread FPS` drops during interactions
- Fix: move heavy computation off the JS thread with `react-native-reanimated` worklets or `useDeferredValue`

**Bridge serialization overhead** (old architecture)
- Symptom: many small bridge calls per frame
- Fix: batch bridge calls; use `react-native-reanimated` v2+ (runs on UI thread via JSI)

**Hermes engine**
- Enabled by default in RN 0.70+; reduces startup time and memory vs JSC
- Avoid large synchronous `JSON.parse` on startup; defer or stream

**FlatList performance**
- Use `keyExtractor` returning stable IDs
- Set `getItemLayout` when item height is fixed — skips measurement
- Tune `windowSize`, `initialNumToRender`, `maxToRenderPerBatch` for long lists
- `removeClippedSubviews={true}` on Android for very long lists

**Image loading**
- Use `react-native-fast-image` for caching and priority control
- Resize images server-side to display dimensions; never decode a large image to show a thumbnail

---

## Python

### Profiling Tools
- `cProfile` + `pstats` — built-in; cumulative time per function
- `py-spy` — sampling profiler; attaches to running process; no code changes needed
- `line_profiler` (`@profile` decorator) — line-by-line timing
- `memory_profiler` — line-by-line memory usage
- `scalene` — CPU + memory in one tool

### Common Issues & Fixes

**GIL-bound CPU work**
- Symptom: multiple threads, but only one core utilized
- Fix: `multiprocessing` for CPU-bound parallelism; `asyncio` for I/O-bound; numpy/pandas release the GIL

**Unvectorized loops over data**
- Symptom: Python `for` loop over large dataset
- Fix: vectorize with numpy/pandas operations — they execute in C

**Repeated attribute lookups in tight loops**
- Fix: cache `obj.method` in a local variable before the loop

**Slow I/O**
- Fix: `asyncio` + `aiohttp`/`aiofiles` for concurrent I/O; avoid blocking calls in async context

---

## C

### Profiling Tools
- `perf` (Linux) — hardware counter-based CPU profiler
- `valgrind --tool=callgrind` — instruction-level profiling
- `gprof` — function-level timing with `-pg` compile flag
- Address Sanitizer (`-fsanitize=address`) — memory errors and leaks

### Common Issues & Fixes

**Cache misses**
- Symptom: `perf stat` shows high `cache-misses` rate
- Fix: structure data for sequential access (AoS → SoA); keep hot data together; avoid pointer chasing

**Stack vs heap allocation**
- Stack allocation is faster (no malloc overhead); use for small fixed-size buffers
- Pool-allocate heap objects to avoid fragmentation

**Branch misprediction**
- Symptom: `perf stat` shows high `branch-misses`
- Fix: sort data so branches are predictable; use branchless arithmetic where profiling confirms benefit

**Compiler optimization flags**
- Development: `-O0 -g`
- Production: `-O2` (safe); `-O3` adds aggressive vectorization — benchmark before shipping
- Profile-guided: `-fprofile-generate` → run workload → `-fprofile-use`

**Loop optimization**
- Hoist invariant computations out of loops
- Let the compiler unroll; only intervene when profiling proves manual unrolling helps

---

## Output

Produce a performance audit summary:

```
## Performance Audit: <component/feature>

### Baseline
- Metric: <what was measured, e.g. p95 response time, FPS, memory>
- Before: <value>

### Root Cause
<what profiling revealed>

### Changes Made
1. <change> → <result>
2. <change> → <result>

### After
- Metric: <same metric>
- After: <value>
- Improvement: <delta or %>
```
