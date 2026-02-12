# Frontend Design

Elevate UI/UX beyond generic AI output. Production-grade CSS/HTML.

## HTML

- Strict semantic HTML5: nav, main, section, article, aside
- ARIA labels on all interactive elements
- No div soup; every element has purpose
- Landmark roles for screen readers

## Architecture

- Component-driven: Atomic Design (atoms > molecules > organisms)
- Design Tokens for spacing, colors, typography, shadows
- Single source of truth for theme values
- Responsive-first; mobile breakpoint as default

## Style

- No inline styles ever
- Prefer Tailwind CSS or CSS Modules
- Consistent spacing scale (4px base)
- Typography: max 2 font families, clear hierarchy
- Color: accessible contrast ratios (WCAG AA minimum)

## UX

- Loading states: skeleton screens over spinners
- Empty states: helpful copy + primary action
- Error boundaries: graceful fallback UI
- Transitions: subtle, purposeful (150-300ms)
- Focus management: visible focus rings, logical tab order

## Performance

- Critical CSS inlined; rest deferred
- Images: lazy load below fold; proper srcset
- Fonts: display=swap; subset when possible
- Bundle: code-split per route
