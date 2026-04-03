---
name: producing-animated-icons
description: Use when creating animated icons, SVG motion assets, hover icons, loading indicators, or 动态图标 with Yesicon, SVGL, Lucide Animated, itshover, or useAnimations.
---

# Producing Animated Icons

Treat each icon as a tiny motion system. Start by locking four things:

- semantic role: action, status, brand, loading, or delight
- output target: raw SVG, React/TSX component, shadcn-friendly block, or exported asset
- trigger: idle, hover, pressed, success, error, or loop
- constraints: size, `currentColor`, stroke/fill style, dark mode, and reduced motion

## Source Selection

- `Yesicon`: default search surface for broad static SVG discovery across many open icon sets.
- `SVGL`: use for logos, brands, frameworks, and tool marks rather than generic UI icons.
- `Lucide Animated`: default for product UI icons that need polished React-ready motion in a consistent stroke language.
- `itshover`: use when the brief is primarily about hover affordance or intent-driven interaction.
- `useAnimations`: use for loaders, toggles, micro-feedback, and repeated motion states.

Pick one primary source per icon. Mix libraries only when there is a strong semantic reason.

## Workflow

1. Search 3-5 candidates that match meaning before style.
2. Pick one family and lock the resting silhouette first.
3. Animate only the part that communicates state: reveal, rotate, pulse, slide, draw, or bounce.
4. Keep the `viewBox` stable so the icon does not shift layout when animated.
5. Expose controllable props such as `size`, `className`, `strokeWidth`, `isActive`, or `isLoading`.
6. Always provide a reduced-motion fallback. Hover behavior must degrade cleanly on touch devices.

If the request is vague, propose 2-3 directions such as `precise`, `playful`, and `system`.

## Motion Rules

- Action icons: fast, directional, and single-beat.
- Status icons: confirm briefly, then settle.
- Loading icons: smooth loops with low amplitude and no jitter.
- Brand or logo icons: animate the container, accent, or entry first. Do not distort official marks unless the user explicitly asks.

## Deliverables

Default to a compact output set:

- one chosen icon direction with a short rationale
- the final SVG or TSX component
- a usage snippet for idle and active states
- notes about motion triggers and reduced-motion behavior

If this skill ships examples or showcase outputs in this repo, keep them under `assets/examples/` inside the skill folder instead of at the repo root.

Read [references/source-map.md](references/source-map.md) only when exact source URLs, registry usage, or install patterns are needed.

## Common Mistakes

- animating every path at once
- mixing incompatible stroke styles
- turning loaders into decorative motion
- over-animating logos
- ignoring `prefers-reduced-motion`
