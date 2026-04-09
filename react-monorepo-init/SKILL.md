---
name: react-monorepo-init
description: Use when creating a new React web app, initializing a Vite frontend monorepo, bootstrapping a pnpm + Turborepo React starter, or setting up a standard React 19 + TypeScript workspace with React Router, TanStack Query, Zustand, Tailwind CSS v4, shadcn/ui, Vitest, MSW, and Playwright.
---

# React Monorepo Init

## Overview

用这个 skill 初始化一个标准化的 React 前端 monorepo。它固定核心技术栈与工程约定，优先把“能开发、能测试、能扩展、能协作”的底座一次搭好。

## Inputs

先确认 4 个输入：

- `project_name`: 仓库名与根 `package.json` 名称
- `target_dir`: 项目输出目录，默认应为空目录或新目录
- `scope`: workspace 包作用域，例如 `@acme`
- `addons`: 可选增强，支持 `ci`、`storybook`、`pwa`、`i18n`

如果用户没有给出可选增强，默认留空，不主动打开。

## Workflow

1. 检查目标目录是否为空；如果非空，停止并请用户确认，不要覆盖。
2. 优先用官方 CLI 起一个新鲜底座。
   - 推荐命令：`python scripts/bootstrap_project.py --project-name <name> --target-dir <dir> --scope <scope> --base-strategy auto`
   - `auto` 会先尝试 `pnpm dlx create-vite@latest apps/web --template react-ts`，失败时回退到纯模板模式。
3. 用内置模板补齐标准 monorepo 结构、共享包、文档、测试和工程化配置。
4. 如果用户选择了 addon，再追加对应模板与依赖。
5. 运行占位符同步脚本，确保项目名、作用域、文档标题和包名全部落到位。
6. 初始化完成后，按顺序执行：
   - `pnpm install`
   - `python scripts/verify_scaffold.py --target-dir <dir>`
   - `pnpm --filter <scope>/web test:e2e`（如需 E2E，再先安装 Playwright 浏览器）

## Addons

- `ci`: GitHub Actions 基础 CI 工作流
- `storybook`: 组件预览配置与示例 story
- `pwa`: `vite-plugin-pwa` 与基础注册逻辑
- `i18n`: `i18next`、`react-i18next` 与中英文示例词条

不要发散到后端、认证、部署平台、埋点平台；这些不属于默认职责。

## Failure Handling

- `pnpm` 或网络不可用：保留 `asset-only` 回退路径，继续生成可安装模板。
- 目标目录非空：直接失败，不要隐式覆盖。
- addon 依赖不兼容：先保留主脚手架成功，再单独说明 addon 问题。
- 验证失败：回到失败命令，对应修复模板或脚本，而不是只改说明文档。

## Output Checklist

生成结果至少应包含：

- `apps/web`
- `packages/ui`
- `packages/api-client`
- `packages/shared`
- `packages/hooks`
- `packages/theme`
- `packages/config-eslint`
- `packages/config-typescript`
- `packages/config-tailwind`
- `packages/config-vitest`
- 根目录 `AGENTS.md`、`DESIGN.md`、`README.md`、`CHANGELOG.md`
- `.changeset/`、`.husky/`、`commitlint.config.js`、`.editorconfig`、`.gitattributes`、`.gitignore`、`.nvmrc`、`.npmrc`

## Validation

优先读取这些参考文件，而不是把所有细节塞进正文：

- `references/stack-baseline.md`
- `references/repo-layout.md`
- `references/engineering-files.md`
- `references/quality-gates.md`
- `references/optional-addons.md`

完成后给用户的总结要包含：

- 创建了哪些核心目录与包
- 是否启用了 addon
- 运行了哪些验证命令，哪些已通过
- 如果还没装依赖或浏览器，明确写出下一步命令
