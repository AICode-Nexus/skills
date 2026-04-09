# Optional Addons

支持的 addon：

## `ci`

- 复制 `.github/workflows/ci.yml`
- 默认执行 install、lint、typecheck、test

## `storybook`

- 追加 `.storybook/` 配置
- 添加 root `storybook` / `storybook:build` scripts
- 提供一个 `packages/ui` 示例 story

## `pwa`

- 给 `apps/web/vite.config.ts` 注入 `vite-plugin-pwa`
- 在 `src/main.tsx` 里注册基础 PWA 逻辑

## `i18n`

- 注入 `i18next` 与 `react-i18next`
- 生成 `en` / `zh-CN` 示例词条
- 在 `src/main.tsx` 里加载 i18n 初始化逻辑

原则：

- addon 默认关闭
- 主脚手架永远优先成功
- addon 如果失败，单独报错，不要污染基础模板
