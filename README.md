# skills

个人专业的 skills hub。约定是“一个 skill 一个文件夹”，每个 skill 至少包含一个 `SKILL.md`。

## 安装方式

这个仓库里的 skill 默认不会自动安装到 Codex。本地一般有两种用法：

### 1. 手动安装单个 skill

把某个 skill 文件夹复制到 `~/.codex/skills/`：

```bash
mkdir -p ~/.codex/skills
cp -R react-monorepo-init ~/.codex/skills/
```

安装后重启 Codex，新的 skill 才会被识别。

### 2. 一次安装多个 skill

直接复制多个目录：

```bash
mkdir -p ~/.codex/skills
cp -R react-monorepo-init codex-switch-snapshot producing-animated-icons ~/.codex/skills/
```

如果你希望仓库内修改能立即反映到 Codex，也可以改用符号链接：

```bash
mkdir -p ~/.codex/skills
ln -s /path/to/skills-repo/react-monorepo-init ~/.codex/skills/react-monorepo-init
ln -s /path/to/skills-repo/codex-switch-snapshot ~/.codex/skills/codex-switch-snapshot
```

### 3. 用 `skill-installer` 从 GitHub 安装

如果用户已经在 Codex 里可用系统级 `skill-installer`，也可以直接让它从 GitHub 仓库安装指定路径的 skill。

单个 skill：

```text
用 $skill-installer 从 GitHub 仓库 AICode-Nexus/skills 安装 react-monorepo-init 到我的 Codex skills 目录。
```

多个 skill：

```text
用 $skill-installer 从 GitHub 仓库 AICode-Nexus/skills 安装 react-monorepo-init、codex-switch-snapshot 和 producing-animated-icons。
```

建议：

- 日常开发者自己维护：优先用符号链接
- 给别人分发稳定版本：优先用复制或 `skill-installer`
- 安装后如果看不到新 skill：先重启 Codex

## Skills

- `producing-animated-icons`
  - 面向动态图标生产。
  - 主要能力来源：Yesicon、SVGL、Lucide Animated、itshover、useAnimations。
  - 案例和预览放在 `producing-animated-icons/assets/examples/`。

- `codex-switch-snapshot`
  - 面向 Codex 本地连续性。
  - 一次安装共享本地会话池，在账号或 API key 切换后继续复用本机会话。
  - 支持 `safe/full` 快照与恢复，认证和运行态仍保持本地独立。

- `react-monorepo-init`
  - 面向 React 前端 monorepo 初始化。
  - 固定 React 19、TypeScript 5.7、Vite、React Router、TanStack Query、Zustand、React Hook Form、Zod、Tailwind CSS v4、shadcn/ui 风格基线、Vitest、MSW、Playwright、pnpm workspace 与 Turborepo。
  - 支持 `ci`、`storybook`、`pwa`、`i18n` 可选增强，并附带脚手架生成、占位符同步与结构校验脚本。
