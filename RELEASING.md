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

## Release Steps

### 1. 运行发布前检查

```bash
npm run release:check
```

这条命令会依次执行：

```bash
npm test
npm run pack:check
npm run publish:dry-run
```

### 2. 检查 npm 官方 registry 登录态

```bash
npm whoami --registry=https://registry.npmjs.org/
```

如果失败，登录：

```bash
npm login --registry=https://registry.npmjs.org/ --scope=@aicode-nexus
```

### 3. 确认包名还未被占用

```bash
npm view @aicode-nexus/skills version
```

- 如果返回 `404 Not Found`，通常表示这个包名还没发布
- 如果返回具体版本号，说明已经存在，应先决定是升级版本还是换包名

### 4. 升级版本号

```bash
npm version patch
```

按需选择：

- `patch`: 小修复或文档更新
- `minor`: 新增功能
- `major`: 破坏性变更

### 5. 正式发布

```bash
npm publish
```

### 6. 发布后验证

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
