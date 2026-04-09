# Repo Layout

目标结构：

```text
<project>/
├── apps/
│   └── web/
├── packages/
│   ├── api-client/
│   ├── config-eslint/
│   ├── config-tailwind/
│   ├── config-typescript/
│   ├── config-vitest/
│   ├── hooks/
│   ├── shared/
│   ├── theme/
│   └── ui/
├── docs/
├── .changeset/
├── .husky/
└── root config files
```

目录职责：

- `apps/web`: 唯一默认应用，包含路由、providers、features、tests、e2e
- `packages/ui`: 可复用 UI 组件基线
- `packages/api-client`: typed `fetch` client
- `packages/shared`: 轻量共享类型与纯函数
- `packages/hooks`: 跨应用可复用 hooks
- `packages/theme`: 设计令牌与主题 CSS
- `packages/config-*`: 工程配置复用层
