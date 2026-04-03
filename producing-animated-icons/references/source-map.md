# Source Map

Load this file only when the task needs exact source selection, install syntax, or official links.

## Primary Sources

- Yesicon: [yesicon.app](https://yesicon.app/)
  - Best for discovering static SVG candidates across many open icon sets before animation work starts.
- SVGL: [svgl.app](https://svgl.app/)
  - Best for brand, framework, and tool logos.
  - Docs: [SVGL shadcn/ui registry](https://svgl.app/docs/shadcn-ui)
  - API: [SVGL API](https://svgl.app/api)
- Lucide Animated: [lucide-animated.com](https://lucide-animated.com/)
  - Motion-powered animated Lucide-style React icons.
- itshover: [itshover.com](https://www.itshover.com/)
  - Motion-first, editable React icons with hover intent.
  - Example registry install pattern: `npx shadcn@latest add https://itshover.com/r/<icon-name>.json`
- useAnimations: [useanimations.com](https://useanimations.com/)
  - Overview of the animation catalog and downloadable assets.
  - React package docs: [react.useanimations.com](https://react.useanimations.com/)

## Selection Heuristic

- Need broad icon exploration: start with Yesicon.
- Need logos or stack marks: start with SVGL.
- Need polished UI-state animation in React: start with Lucide Animated.
- Need hover-first affordance: start with itshover.
- Need loaders or simple reusable micro-animations: start with useAnimations.

## Guardrails

- Preserve license and attribution expectations from the upstream source.
- Keep one visual language per surface when possible.
- Prefer animating state-bearing subpaths, not the entire icon.
