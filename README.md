# skills

个人专业的 skills hub。约定是“一个 skill 一个文件夹”，每个 skill 至少包含一个 `SKILL.md`。

## 推荐安装方式

这个仓库现在已经内置了 npm CLI 安装器。发布到 npm 后，用户可以直接用 `npx` 安装 skill 到 `~/.codex/skills`。

### 1. 列出可安装 skill

```bash
npx @aicode-nexus/skills list
```

### 2. 安装单个 skill

```bash
npx @aicode-nexus/skills install react-monorepo-init
```

### 3. 一次安装多个 skill

```bash
npx @aicode-nexus/skills install react-monorepo-init codex-switch-snapshot
```

### 4. 安装全部 skill

```bash
npx @aicode-nexus/skills install --all
```

### 常用参数

```bash
npx @aicode-nexus/skills install react-monorepo-init --dest ~/.codex/skills
npx @aicode-nexus/skills install react-monorepo-init --force
npx @aicode-nexus/skills install react-monorepo-init --dry-run
```

默认行为：

- 默认目标目录：`~/.codex/skills`
- 默认不覆盖已有目录
- 传 `--force` 才会覆盖
- 传 `--dry-run` 只打印将执行的安装动作
- 安装完成后应重启 Codex

### 本地开发验证

在这个仓库根目录里，可以直接用下面的方式验证 CLI：

```bash
npx . list
npx . install react-monorepo-init --dry-run
```

## 手动安装方式

如果 npm 包还没有发布，或者你想直接从仓库本地安装，也可以继续使用下面这些方式。

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

## INSTALL SKILLS 模板

以后这个仓库新增 skill，建议在介绍或发布说明里复用下面这段，统一用户安装路径和表达方式。

````md
### 安装 `<skill-name>`

推荐安装：

```bash
npx @aicode-nexus/skills install <skill-name>
```

多个一起安装：

```bash
npx @aicode-nexus/skills install <skill-name> <another-skill-name>
```

本地复制安装：

```bash
mkdir -p ~/.codex/skills
cp -R <skill-name> ~/.codex/skills/
```

开发联动安装：

```bash
mkdir -p ~/.codex/skills
ln -s /path/to/skills-repo/<skill-name> ~/.codex/skills/<skill-name>
```

用 `skill-installer` 安装：

```text
用 $skill-installer 从 GitHub 仓库 AICode-Nexus/skills 安装 <skill-name> 到我的 Codex skills 目录。
```

说明：

- 适合场景：`<一句话说明这个 skill 解决什么问题>`
- 安装后：重启 Codex 以识别新 skill
- 如果还没发布 npm 包：退回到复制安装、符号链接或 `skill-installer`
````

推荐约定：

- skill 名称统一使用目录名
- 安装命令优先展示 `npx` 版，再展示复制版
- 对外发布时优先给 `npx` 和复制安装两种方式
- 不要在模板里写死本机绝对路径，统一使用 `/path/to/skills-repo/<skill-name>`

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
