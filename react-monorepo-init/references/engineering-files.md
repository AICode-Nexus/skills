# Engineering Files

默认根文件及用途：

- `AGENTS.md`: Agent/协作约定，帮助人和 AI 在仓库里安全协作
- `DESIGN.md`: 当前架构边界、目录职责、扩展约定
- `README.md`: 项目介绍、命令、目录结构、快速开始
- `CHANGELOG.md`: 项目级总 Changelog，使用 Keep a Changelog 风格
- `.changeset/config.json`: 版本流入口，不替代根级 `CHANGELOG.md`
- `.nvmrc`: 推荐 Node 版本
- `.npmrc`: pnpm/workspace 相关约定
- `.editorconfig`: 编辑器基础格式约定
- `.gitattributes`: 统一 LF/文本属性
- `.gitignore`: Node、构建产物、测试产物忽略项
- `commitlint.config.js`: Conventional Commits 约束
- `.husky/commit-msg`: 提交信息校验
- `.husky/pre-commit`: lint-staged 入口
