# Quality Gates

初始化完成后的最低验证顺序：

1. `pnpm install`
2. `pnpm lint`
3. `pnpm typecheck`
4. `pnpm test`
5. `python scripts/verify_scaffold.py --target-dir <dir>`
6. 如需 E2E：
   - `pnpm --filter <scope>/web exec playwright install chromium`
   - `pnpm --filter <scope>/web test:e2e`

验证目标：

- 根目录规范文件齐全
- `CHANGELOG.md` 与 `.changeset/` 职责说明清晰
- `apps/web` 能运行、测试、构建
- workspace 包边界清楚，不需要改根基础设施就能新增 feature
