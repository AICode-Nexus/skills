# Draft C - Case Review / Decision Memo

## 标题方向

当产品经理不想再等前端排期，他真正需要的不是一个页面，而是一个项目

假设有这样一个场景。

一个产品经理想在下周用户访谈前，验证新的 onboarding 流程。他的需求并不复杂：几个页面、一些表单状态、几个接口占位、一个看起来足够像真的体验版本。

按照传统节奏，他会先写文档，再找设计出稿，再争取前端排期。运气好，一两周后拿到一个半成品。运气不好，这件事会被判断成“还没到开发阶段”，然后无限停留在 PPT、Figma 和会议纪要里。

AI 出现以后，事情看起来像是变快了。产品经理可以直接对 agent 说：“给我做个 onboarding demo。”  
问题是，agent 往往真的只会先给他做一个 demo。

这听上去没毛病，实际上却暴露了一个更深的问题：**页面可以很快被生成，项目却不会自动专业地出现。**

## 问题不在于写不出页面，而在于接不下去

第一次结果往往很令人兴奋。页面能打开，按钮能点，甚至视觉上也像模像样。

但当第二轮需求出现时，问题就来了：

- 想接真实接口，数据请求散在组件里。
- 想加第二个流程页，路由组织开始混乱。
- 想把某套 UI 抽出来复用，没有明确落点。
- 想交给前端接手，别人一眼看过去只觉得“得重搭”。

所以最痛的部分不在第一步，而在第二步。不是“做不出来”，而是“做出来之后很难接着走”。

这就是为什么 `react-monorepo-init` 这种 skill 很重要。它不是在强调“AI 还能多快”，而是在解决“AI 生成的第一版，能不能成为真正项目的第一步”。

## 这类 skill 真正交付的，是标准起点

如果我们把那个产品经理的场景继续往下推，他真正需要的，不是一份孤立页面代码，而是一套前端起点：

- React 19 + TypeScript，保证现代项目的基础表达能力。
- Vite，确保启动轻快。
- React Router，让业务流程真正以页面路径形式存在。
- TanStack Query + Zustand，把服务端状态和本地状态各自安放。
- Tailwind CSS v4，提高 UI 试错速度。
- Vitest / MSW / Playwright，让测试和验证不是最后才想起来补。
- pnpm monorepo 结构，为共享 UI、hooks、theme、配置留出位置。

这不是“堆栈更全”那么简单，而是从一开始就告诉团队：**这个东西是准备继续长大的。**

可选增强也被收束为 `ci`、`storybook`、`pwa`、`i18n`，说明它不是要包打天下，而是要在最常见的扩展方向上给足抓手。

同时，它也明确不把后端、认证、部署平台、埋点平台一口气捆进来。因为在 MVP 和 demo 阶段，最危险的不是功能不够全，而是起步就过载。

## 最有说服力的时刻，是目录出来的那一刻

如果你把下面这棵树给一个做过项目的人看，他很容易在几秒钟内判断：这是不是一个值得接着做的起点。

```text
demo-web/
├─ apps/
│  └─ web/
├─ packages/
│  ├─ ui/
│  ├─ api-client/
│  ├─ shared/
│  ├─ hooks/
│  ├─ theme/
│  ├─ config-eslint/
│  ├─ config-typescript/
│  ├─ config-tailwind/
│  └─ config-vitest/
├─ .changeset/
├─ .husky/
├─ AGENTS.md
├─ DESIGN.md
├─ README.md
├─ CHANGELOG.md
└─ commitlint.config.js
```

为什么这很重要？

因为对产品、设计、运营、销售来说，这棵树意味着“终于不是临时拼的 demo 了”；对前端工程师来说，这意味着“这玩意儿至少尊重了项目应该有的边界、共享层和质量入口”。

这也是这类 skill 最容易被低估的一点：它吸引人的，不只是“能生成”，而是“生成出来看起来就能接着干”。

## 这不是替代前端，而是把前端最重复的工作标准化

如果把这件事讲成“以后非研发也不需要前端了”，那就是典型的 AI 误读。

更准确的说法是：前端工程师的价值，不该长期消耗在重复初始化上。真正贵的是架构选择、复杂交互、性能调优、可维护性判断、跨模块演进，而不是每次都重新铺一遍基础设施。

`react-monorepo-init` 的好处，是把一部分高频重复动作沉淀下来，让团队把判断力用在更值得的地方。

它当然有取舍。它不是无限灵活，而是明显偏向“先给你一套靠谱默认值”。但对于 demo、MVP、内部工具和早期验证来说，这正是更实用的选择。

## 谁会最先感受到这件事的价值

产品经理会发现，自己第一次真正拥有了把想法推到“可试用版本”的工具。

设计师会发现，自己的交付可以从静态稿再往前走一步，进入真实交互和流程验证。

运营会发现，内部小工具不必每次都从一张空白纸开始。

销售和解决方案团队会发现，客户演示不一定非要依赖正式排期，很多时候先起一个标准项目，已经足够抓住窗口。

## 怎么马上试

公开入口在这里：

- npm: [@aicode-nexus/skills](https://www.npmjs.com/package/@aicode-nexus/skills?activeTab=readme)
- GitHub: [AICode-Nexus/skills](https://github.com/AICode-Nexus/skills)

最短路径：

```bash
npx -y @aicode-nexus/skills list
npx @aicode-nexus/skills install react-monorepo-init
```

如果你在 Claude Code 里使用：

```bash
npx @aicode-nexus/skills install react-monorepo-init --dest ~/.claude/skills
```

如果你想装进项目目录，让团队一起用：

```bash
npx @aicode-nexus/skills install react-monorepo-init --dest ./tools/agent-skills
```

## 结论

AI 把“做一个页面”变简单了。  
真正更重要的一步，是把“启动一个专业前端项目”也变简单。

`react-monorepo-init` 做的，正是把这一步抽出来，交给一个可复用、可传播、可协作的 skill。
