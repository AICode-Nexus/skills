# Stack Baseline

固定核心栈：

- React 19
- TypeScript 5.7.x
- Vite
- React Router
- TanStack Query
- Zustand
- React Hook Form + Zod
- Tailwind CSS v4
- shadcn/ui 风格基线
- lucide-react
- `fetch + typed client`
- Vitest + React Testing Library + `@testing-library/user-event`
- MSW
- Playwright
- pnpm workspace + Turborepo
- Oxlint + ESLint

约束：

- 这是 opinionated starter，不做高自由度技术栈矩阵。
- 只保留少量 addon 开关，不把 skill 做成交互式平台生成器。
- TypeScript 保持 `5.7.x`，不要自动升级到 6.x。
- Tailwind 使用 v4 的 CSS-first 方式，避免再退回旧版 `tailwind.config.js` 依赖。
