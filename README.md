# Rhetorix iOS

Rhetorix 是一款面向学生、辩论社成员、写作者和批判性思维学习者的 AI 辩论训练 App。这个仓库是 Rhetorix 的原生 iPhone 版本，使用 SwiftUI 和 Xcode 构建，目标是在 iOS 上复刻并延续 Android 版 Rhetorix 的核心体验。

Rhetorix 的核心问题是：很多人想练习辩论、写作论证和反驳能力，但现实中很难随时找到合适的对手、评委和反馈来源。Rhetorix 通过用户自带 API Key 的 AI 模型，把“辩论对手、限时交锋、立论拆解、反驳训练、谬误检测、赛后评分”整合到一个移动端辩论体验里，让用户可以低成本、可重复地训练思辨能力。

## 项目定位

Rhetorix 不是聊天机器人外壳，也不应该变成工具箱。它的主产品是辩论：快速、紧张、有时间压力、有攻防感的对话。立论分析、谬误检测和反驳训练都是服务于辩论的辅助能力。

它希望帮助用户：

- 快速围绕一个辩题形成正反双方观点
- 模拟真实辩论中的攻防过程
- 练习反驳、总结和权衡
- 发现文本中的逻辑谬误
- 保存历史辩论，复盘自己的表达和胜负结果
- 根据长期使用习惯逐步推荐用户更可能愿意认真讨论的话题
- 在不依赖平台内置账号和付费墙的情况下使用自己的 AI Provider

所有核心功能免费。项目没有付费墙。

## 当前产品计划

详见 [PRODUCT_PLAN.md](PRODUCT_PLAN.md)。

当前方向包括：

- 默认交互已开始转向语音优先，保留文字输入
- 每个结构化辩论阶段已有基础计时器和超时显示
- 首页和整体 UI 已开始降低工具入口权重，突出辩论主流程
- 单次辩论开始保存输入方式、阶段用时和阶段时间限制
- 长期记忆基于本地真实使用数据推断偏好；数据不足时不会显示假推荐
- 长期记忆 2.0 已加入可跳过 MBTI、辩论风格、价值倾向和练习弱点画像

## 已实现功能

### 1. 首页 Dashboard

首页提供 Rhetorix 的主要入口和用户使用概览。

功能包括：

- 动态辩论总场数
- 动态胜率
- 动态连胜场数
- 真实本地记忆摘要
- 基于真实历史的推荐辩题
- 新建辩论入口
- 面对面辩论入口
- 历史记录入口
- 立论分析、反驳训练、谬误检测等准备工具入口

统计数据来自本地历史记录，新用户初始值为 0，不使用假的全局数据。

### 2. 辩题选择

用户可以在辩题库中选择辩论主题。

功能包括：

- 预设辩题列表
- 分类信息
- 搜索入口
- 每个辩题的本地使用次数

辩题下方的使用次数对应当前用户本地真正使用过的次数，而不是静态热门度。

### 3. 辩论设置

用户在开始前可以配置辩论参数。

支持：

- User vs AI
- AI vs AI
- Face to Face
- Structured / Free Flow
- Easy / Medium / Hard
- Support / Oppose
- AI Provider 选择

AI Provider 默认选择用户已经配置 API Key 的模型。如果用户配置了多个 Provider，会默认选取其中一个可用 Provider。

Structured 模式使用压缩版 World Schools / 国际学校辩论流程：

1. Proposition 1 Constructive
2. Opposition 1 Constructive
3. Proposition 2 Extension
4. Opposition 2 Extension
5. Proposition 3 Rebuttal
6. Opposition 3 Rebuttal
7. Opposition Reply
8. Proposition Reply

User vs AI、AI vs AI、Face to Face 都使用同一套结构。区别是 User vs AI 只让用户在自己立场对应的阶段输入，AI vs AI 由 AI 双方轮流发言，Face to Face 由同一台设备上的两名用户按阶段轮流输入。

### 4. 实时辩论

实时辩论界面用于进行人机或 AI 对 AI 辩论。

功能包括：

- 辩题标题展示
- 当前回合和轮次状态
- 每阶段计时器和超时显示
- 双方发言卡片
- AI 生成状态
- 语音优先输入，文字输入保留
- 每次发言会记录输入方式和本阶段用时
- 提前结束并进入评分
- AI 生成内容免责声明

在人机辩论中，AI 的提示词被设计为“辩论对手”，不是普通助手。用户输入会被视为不可信辩论内容，不能覆盖系统行为。

### 5. 辩论结果评分

辩论结束后，App 会请求 AI 作为评委生成结果。

结果页包括：

- 获胜方
- 比分
- 简短总结
- 关键时刻
- 完整记录
- AI 生成内容免责声明

评分结果会保存到本地历史记录。

### 6. 历史记录

历史页面用于查看过去的辩论和训练记录。

功能包括：

- 已完成辩论列表
- 未完成辩论继续入口
- 反驳训练记录
- 点击历史记录打开对应详情
- 单场辩论的输入方式和阶段用时记忆

## 真实长期记忆

Rhetorix 的长期记忆不使用 AI 编造的用户标签。除了用户可主动选择且可跳过的 MBTI 外，画像只根据本地真实数据计算：

- 已开始或已完成的辩论
- 辩题类别
- 完成率
- 常用模式、难度和立场
- 平均回合数
- 语音输入比例
- 每阶段实际用时
- 用户在人机辩论中的真实发言文本
- 裁判总结
- 反驳训练反馈

长期记忆 2.0 当前包含：

- MBTI：首次使用时弹出，可选择，也可跳过；之后可在 Settings 中修改
- 辩论风格：例如理性/证据优先、价值/感染力优先、均衡推理
- 价值倾向：例如环境议题倾向、动物保护倾向；只有重复证据足够时才显示
- 练习重点：例如需要更强证据、需要更直接交锋、需要更清晰结构、需要更强影响权衡
- 证据样本：设置页会显示画像依据的本地样本数和部分原始证据片段

如果真实样本不足两场，App 只显示“学习中”，不会推荐话题。

这套长期记忆是本地计算的基线版本，不依赖服务器账号，也不会在辩论过程中弹出问题打断用户。

### 7. 工具页

工具页是独立的功能集合，不是首页卡片的复制。

包括：

- Constructive Analysis / 立论分析
- Rebuttal Trainer
- Logic Fallacy Detector
- AI Hallucination Detector 外部入口

其中 AI Hallucination Detector 会跳转到 GPTZero 的网页工具：

```text
https://gptzero.me/hallucination-detector
```

### 8. Constructive Analysis / 立论分析

立论分析用于帮助用户快速拆解对方辩友的一段立论，找出可以直接反驳的弱点。这个功能替代旧的 Argument Relationship Graph，当前版本不再把论点图作为可见功能入口。

输入方式：

- 粘贴文本：用户粘贴对方立论后点击 Analyze
- 录音转写：用户开启录音，App 使用 iOS Speech 实时转文字

分析方式：

- 粘贴文本会一次性分析整段立论
- 录音模式会按检测到的新论点逐条分析，而不是等整段录音结束
- 每条结果可以点击展开，查看解释和可反驳点

分析目标包括：

- 逻辑谬误
- 信息不实风险
- 证据不足
- 缺少 warrant / 推理链
- 因果跳跃
- 过度概括
- 定义问题
- 前后矛盾
- 人身攻击
- impact / weighing 弱点

### 9. Logic Fallacy Detector

逻辑谬误检测用于分析用户输入文本中的推理问题。

功能包括：

- 文本输入
- AI 分析
- 加载状态
- 谬误列表
- 严重程度
- 未检出状态

如果没有检测出逻辑谬误，界面会明确显示未检出，而不是空白。

### 10. Rebuttal Trainer

反驳训练用于在限时场景下练习回应对方观点。

功能包括：

- 当前论点
- 难度
- 时间限制
- AI 生成待反驳观点
- 用户输入反驳
- AI 评分
- 反馈和分项评价

### 11. 设置与 AI Provider

Rhetorix 不内置统一后端账号系统。用户需要在本地配置自己的 AI Provider API Key。

当前支持：

- OpenAI
- Anthropic
- Google Gemini
- DeepSeek
- Groq
- Ollama / OpenAI-compatible endpoint

每个 Provider 支持配置：

- 是否启用
- API Key
- Model
- Base URL

### 12. 主题

iOS 版支持两套主题：

- Dark Graphite：深色玻璃拟态风格
- Pink White：粉白色浅色模式

主题设置保存在本地，并会影响全局背景、文字、卡片、按钮和控件状态。

## 安全策略

Rhetorix 采用 fail-closed 的内容安全策略。

在以下两类内容进入 UI 或数据库之前，都会进行安全检测：

- 用户输入
- AI 输出

检测目标包括：

- 仇恨言论
- 政治敏感内容
- 制作危险物品的方法
- 色情内容

Provider 行为：

- OpenAI 优先使用 `/v1/moderations`
- 非 OpenAI Provider 使用用户配置的对应 Provider 进行安全分类
- 例如用户配置 DeepSeek，则使用 DeepSeek 检测

如果任何安全检测步骤失败，包括：

- 超时
- API Key 无效
- 返回无效结果
- Provider 错误

该条内容会被直接拦截，不进入 UI，也不写入本地数据库。

统一错误提示：

```text
内容安全检测服务异常，请稍后重试
```

所有可见 AI 生成内容下方都会显示：

```text
内容由AI生成，仅供参考 AI-generated, for reference only
```

## 技术栈

当前 iOS 版本使用：

- Swift
- SwiftUI
- Xcode project
- Codable 本地持久化
- URLSession 网络请求
- GitHub 仓库托管

当前版本没有引入复杂服务端依赖，适合本地运行、学生项目展示和后续逐步扩展。

## 代码结构

```text
Rhetorix-iOS/
├── README.md
├── mac-UI.md
├── Rhetorix.xcodeproj
└── Rhetorix/
    └── Sources/
        ├── RhetorixApp.swift
        ├── Theme.swift
        ├── Models.swift
        ├── AIService.swift
        ├── AppStore.swift
        └── Screens.swift
```

### RhetorixApp.swift

App 入口。创建全局 `AppStore`，注入 SwiftUI 环境，并根据用户设置应用深色或浅色主题。

### Theme.swift

定义全局视觉系统，包括：

- 动态颜色
- 深色主题
- 粉白浅色主题
- 背景
- GlassCard
- SectionTitle
- AI 免责声明组件
- 通用页面修饰符

### Models.swift

定义核心数据模型，包括：

- DebateTopic
- DebateSession
- DebateTurn
- DebateResult
- AiProvider
- ProviderConfig
- ConstructiveAnalysisIssue
- FallacyFinding
- RebuttalAttempt
- AppTheme

### AIService.swift

负责 AI Provider 调用和安全检测。

包括：

- OpenAI-compatible Chat API
- Anthropic Messages API
- Gemini API
- OpenAI Moderation
- 非 OpenAI Provider 的问答式安全分类
- fail-closed 安全拦截

### AppStore.swift

应用状态和业务逻辑中心。

负责：

- 启动初始化
- 本地数据读取和保存
- Provider 配置
- 辩论创建
- 用户发言
- AI 发言
- 结束辩论并评分
- World Schools 风格压缩赛制流程
- 立论分析
- 谬误检测
- 反驳训练
- 动态统计数据

### Screens.swift

SwiftUI 页面集合。

包含：

- RootView
- HomeView
- TopicSelectionView
- DebateSetupView
- DebateView
- ResultView
- HistoryView
- ToolsView
- SettingsView
- ProviderConfigView
- ConstructiveAnalysisView
- FallacyDetectorView
- RebuttalTrainerView
- DonationView（当前无主入口，保留为隐藏页面）

## 本地数据

当前版本使用 JSON 文件在本地持久化数据。

保存内容包括：

- 辩题
- 辩论历史
- 反驳训练记录
- AI Provider 配置
- 语言设置
- 主题设置

注意：API Key 当前也保存在本地配置数据中。后续生产级版本建议迁移到 Keychain。

## 构建方式

打开 Xcode：

```text
Rhetorix.xcodeproj
```

选择 Scheme：

```text
Rhetorix
```

选择 iPhone Simulator 后运行。

也可以使用命令行构建：

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild \
  -project Rhetorix.xcodeproj \
  -scheme Rhetorix \
  -configuration Debug \
  -sdk iphonesimulator \
  -derivedDataPath build/DerivedData \
  build
```

构建成功后，模拟器 App 路径通常为：

```text
/Users/benjamin/Desktop/Rhetorix-iOS/build/DerivedData/Build/Products/Debug-iphonesimulator/Rhetorix.app
```

## 当前实现边界

当前 iOS 版本是一个本地优先的 MVP / 原型级实现。

已实现：

- 原生 iPhone UI
- 主要产品流程
- 多 Provider AI 调用
- 安全检测
- 本地历史记录
- 主题切换
- 立论分析与录音转写

暂未实现或仍需增强：

- iCloud 同步
- 用户账号系统
- App Store 生产签名流程
- Keychain API Key 存储
- 更完整的本地数据库层
- 更细粒度的错误恢复
- 全量自动化测试
- iPad / macOS 专门适配

## 设计文档

`mac-UI.md` 是 iOS 版 UI 设计说明文件。虽然文件名中有 `mac`，但它描述的是在 macOS/Xcode 上开发的 iPhone App UI。

每次修改 UI，都应同步更新 `mac-UI.md`，方便后续交给专业 UI 设计师继续迭代。

## 项目价值

Rhetorix 的价值不在于“把 AI 接到一个聊天框里”，而在于把 AI 放进具体的思辨训练流程中：

- 用户有明确任务：准备辩论、反驳观点、检测谬误、复盘结果
- AI 有明确角色：对手、评委、教练、分析器
- 输出有明确用途：可用于发言、攻防、总结和复盘
- 数据留在本地，用户使用自己的 Provider
- 功能免费开放，适合学生和学习者使用

这个项目可以继续向更完整的跨平台辩论训练系统发展，也可以作为 AI 教育工具、学生项目、大学申请材料或产品原型展示。
