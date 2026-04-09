# Releasing

## Goal

发布 npm CLI 包 `@aicode-nexus/skills`，让外部用户可以直接运行：

```bash
npx @aicode-nexus/skills list
npx @aicode-nexus/skills install react-monorepo-init
```

## Before You Start

确认本机具备：

- Node.js 20+
- npm 可用
- 对 npm scope `@aicode-nexus` 的发布权限

这个仓库已经在 `package.json` 里固定了：

- `publishConfig.access=public`
- `publishConfig.registry=https://registry.npmjs.org/`

这样可以避免本机默认 registry 是镜像源时把包发布错地方。

如果你希望通过 GitHub Actions 自动发布，还需要在 GitHub 仓库设置里配置：

- Secret 名称：`NPM_TOKEN`
- Secret 内容：拥有 npm publish 权限的 token

当前仓库的自动发布 workflow 在：

- `.github/workflows/release.yml`

它支持两种触发方式：

- 发布 GitHub Release 时自动触发
- 在 Actions 页面手动 `Run workflow`，并传入一个 tag

## Release Steps

### 1. 推荐使用 GitHub Release 自动发布

推荐流程：

1. 推送代码到 `main`
2. 创建并推送版本 tag，例如 `v0.1.2`
3. 在 GitHub 上基于该 tag 发布 Release
4. GitHub Actions 自动执行：
   - `npm test`
   - `npm run publish:dry-run`
   - 校验 tag 与 `package.json` 版本一致
   - `npm publish --provenance`

如果需要补发，也可以在 GitHub Actions 页面手动触发 `Release` workflow，并传入例如 `v0.1.2` 的 tag。

### 2. 本地脚本仍可用于手动发布

最省事的方式：

```bash
npm run release:patch
```

也可以按需选择：

```bash
npm run release:minor
npm run release:major
```

如果你想先看脚本将执行什么，不真正改版本也不发布：

```bash
npm run release:patch:dry-run
```

这个脚本会依次执行：

- 检查 git 工作区是否干净
- 运行 `npm test`
- 运行 `npm run publish:dry-run`
- 执行 `npm version <patch|minor|major>`
- 执行 `npm publish`
- 执行 `git push origin <current-branch> --follow-tags`

### 3. 手动执行时，先跑发布前检查

```bash
npm run release:check
```

这条命令会依次执行：

```bash
npm test
npm run pack:check
npm run publish:dry-run
```

### 4. 检查 npm 官方 registry 登录态

```bash
npm whoami --registry=https://registry.npmjs.org/
```

如果失败，登录：

```bash
npm login --registry=https://registry.npmjs.org/ --scope=@aicode-nexus
```

### 5. 确认包名还未被占用

```bash
npm view @aicode-nexus/skills version
```

- 如果返回 `404 Not Found`，通常表示这个包名还没发布
- 如果返回具体版本号，说明已经存在，应先决定是升级版本还是换包名

### 6. 升级版本号

```bash
npm version patch
```

按需选择：

- `patch`: 小修复或文档更新
- `minor`: 新增功能
- `major`: 破坏性变更

### 7. 正式发布

```bash
npm publish
```

### 8. 推送分支和 tag

```bash
git push origin "$(git rev-parse --abbrev-ref HEAD)" --follow-tags
```

### 9. 发布后验证

```bash
npx @aicode-nexus/skills@latest list
npx @aicode-nexus/skills@latest install react-monorepo-init --dry-run
```

也建议做一次真实安装验证：

```bash
tmpdir=$(mktemp -d)
npx @aicode-nexus/skills@latest install react-monorepo-init --dest "$tmpdir"
ls "$tmpdir/react-monorepo-init"
```

## Troubleshooting

### `npm whoami` 失败，但本机配置了镜像源

很多机器会把默认 registry 配成：

```text
https://registry.npmmirror.com
```

这会导致：

- `npm whoami` 看起来未登录
- `npm publish` 可能指向错误 registry

优先使用官方 registry 显式命令：

```bash
npm whoami --registry=https://registry.npmjs.org/
npm login --registry=https://registry.npmjs.org/ --scope=@aicode-nexus
```

这个仓库已经通过 `publishConfig.registry` 固定正式发布目标为 npmjs。

### `npm publish --dry-run` 成功，但正式发布失败

优先检查：

- 当前账号是否有 `@aicode-nexus` scope 权限
- 是否登录到了 npm 官方 registry
- 是否试图发布一个已存在但无权限覆盖的版本

### 包太大

先执行：

```bash
npm run pack:check
```

确认 tarball 里没有误带大素材或开发期缓存文件。
