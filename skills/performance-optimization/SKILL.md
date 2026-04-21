# React Performance

Audit & fix React rendering bottlenecks.

## Rules

- Minimize re-renders: components should render only when props/state change
- Stable references in useEffect deps; no object/array literals in dep arrays
- Never mutate state directly; always return new references
- Avoid anonymous functions as props in render (causes child re-render)

## Profiling

- Profile with React DevTools before optimizing
- Check "Highlight updates" to spot unnecessary renders
- Use Profiler API for production measurements
- Measure first, optimize second; no premature optimization

## Optimization

- `React.memo` for pure/presentational components
- `useMemo` for expensive computations derived from props/state
- `useCallback` for event handlers passed as props
- Virtualization (react-window, react-virtuoso) for lists >50 items
- `lazy()` + `Suspense` for route-level code splitting

## State

- Colocate state: keep it as close to usage as possible
- Avoid lifting state unnecessarily; causes wider re-render tree
- Context: split providers by update frequency
- External stores (Zustand, Jotai) for high-frequency updates

## Patterns

- Key prop: use stable, unique IDs; never array index for dynamic lists
- Debounce/throttle input handlers triggering expensive updates
- Batch state updates (automatic in React 18+)
- Avoid `useEffect` for derived state; compute during render instead
