# Engineering Files

默认根文件及用途：

- `AGENTS.md`: Agent/协作约定，帮助人和 AI 在仓库里安全协作
- `DESIGN.md`: 当前架构边界、目录职责、扩展约定
- `README.md`: 项目介绍、命令、目录结构、快速开始
- `CHANGELOG.md`: 面向人的项目级总 Changelog，使用 Keep a Changelog 风格，适合沉淀长期可读的变化摘要
- `.changeset/config.json`: 版本流入口，配合 `.changeset/*.md` 管理版本和发布，不替代根级 `CHANGELOG.md`
- `.nvmrc`: 推荐 Node 版本
- `.npmrc`: pnpm/workspace 相关约定
- `.editorconfig`: 编辑器基础格式约定
- `.gitattributes`: 统一 LF/文本属性
- `.gitignore`: Node、构建产物、测试产物忽略项
- `commitlint.config.js`: Conventional Commits 约束
- `.husky/commit-msg`: 提交信息校验
- `.husky/pre-commit`: lint-staged 入口

Changelog 维护约定：

- 会影响包版本、发布说明或对外分发结果的改动：先写 `.changeset/*.md`
- 需要长期保留、方便团队快速浏览的项目级变化：写入 `CHANGELOG.md`
- 同一个变化可以同时出现在两者里，但职责不同：`.changeset/` 服务发布流，`CHANGELOG.md` 服务人工阅读
