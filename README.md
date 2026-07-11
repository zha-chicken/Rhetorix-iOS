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

- 首页新增 `Today's Practice`，把单次练习组织为技能讲解、示例、检查清单、聚焦辩论、自评、AI 量表和发言重试闭环
- 首次使用改为选择学习目标、经验水平和练习时长；MBTI 保留为设置页中的可选轻量偏好
- 默认交互已开始转向语音优先，保留文字输入
- 每个结构化辩论阶段已有基础计时器和超时显示
- 首页和整体 UI 已开始降低工具入口权重，突出辩论主流程
- 单次辩论开始保存输入方式、阶段用时和阶段时间限制
- 长期记忆基于本地真实使用数据推断偏好；数据不足时不会显示假推荐
- 长期记忆 2.0 已加入可跳过 MBTI、辩论风格、价值倾向和练习弱点画像

## 已实现功能

### 0. 引导练习 1.0

面向独自练习的学生，引导练习按一条公开的五步技能路径推进，用户随时可以看到自己在哪一步、下一步是什么：

1. 表达与清晰度（结构提示 / signposting）
2. 论证结构
3. 证据与案例
4. 直接交锋与反驳
5. 影响比较

推进规则是透明且防单场偶然的：某项技能需要在两场不同的有裁判评分的辩论中获得 4 分及以上，或者在一次聚焦该技能的引导练习中获得 4 分及以上，才视为掌握；只有一次高分时，路径卡片会显示“高分评分：1 / 2”的部分进度。今日技能永远是路径上第一个未掌握的技能。路径是开放的，不设锁定，用户可以在技能路径卡片上点击任意步骤直接练习；步骤进度（第 X / 5 步）只反映真实掌握情况，点击其他技能练习不会改变进度位置，此时状态行会显示“正在练习 X · 当前步骤 Y”。五项技能全部掌握后，首页和引导练习页会显示“路径已完成”状态，五个节点保留已掌握的对勾，今日技能转为复习：优先针对本地数据中最明显的弱点，数据不足时从学习目标对应的核心技能开始轮换。学习目标同时会传给 AI 教练（评委、发言重试和反驳评分），让改进建议围绕用户的目标展开。

每次引导练习包含简短策略、示范表达、三项检查清单和匹配训练标签的辩题。引导练习页面按“1 学习 → 2 辩论 → 3 复盘”三个明确步骤组织：顶部技能卡片说明今日要学什么和预计用时，三个编号步骤分别展示学习材料、练习辩题和教练反馈流程，开始按钮固定在页面底部。辩论结束后，用户先完成五项自评，再查看 AI 教练使用同一五项量表生成的评分、原文依据、优点和下一步改进。结果页允许选择一段真实发言立即重试，并保存前后分数、改进技能和对比反馈。

### 1. 首页 Dashboard

首页提供 Rhetorix 的主要入口和用户使用概览。

功能包括：

- 今日练习主入口：技能名称、一句话学习目标和开始引导练习按钮
- 自由辩论次入口
- 动态辩论总场数
- 动态胜率
- 动态连胜场数
- 真实本地记忆摘要
- 基于真实历史的推荐辩题
- 立论分析、反驳训练、谬误检测等准备工具入口

首页不包含重复入口：自由辩论只保留英雄卡片中的一个入口，历史记录和工具通过底部标签页进入，面对面辩论在辩论设置中选择。

统计数据来自本地历史记录，新用户初始值为 0，不使用假的全局数据。

### 2. 辩题选择

用户可以在辩题库中选择辩论主题。

功能包括：

- 300 个本地预设辩题
- 分类信息
- 搜索入口
- 每个辩题的本地使用次数

题库覆盖 AI 与科技、教育、社会文化、伦理哲学、法律政治、经济工作、环境能源、健康生物医学、媒体言论、国际关系和经典辩题。部分题目来自长期常见的经典辩论母题，例如自由与安全、民主与威权、资本主义与社会主义、自然与后天、科学与宗教等。

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
- AI 回答默认自动朗读；可在 Settings 中选择系统语音、火山引擎在线语音或 Voicebox 本地/远程语音服务
- 火山引擎语音需要用户配置 App ID、Access Token、Cluster 和 Voice Type；Voicebox 需要用户运行 Voicebox 服务并配置 Server URL、Profile ID、Engine 和 Model Size
- Voicebox 通过 `/generate/stream` 返回 WAV 音频，由 Rhetorix 在 iPhone 端播放；真机使用时通常需要填写局域网 IP 或远程 HTTPS 地址，而不是 `127.0.0.1`
- 在线语音不可用时自动回退到系统语音
- 可在 Settings 中关闭自动朗读，改为手动点击朗读
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
- 练习重点：例如需要更强证据、需要更直接交锋、需要更清晰结构、需要更强影响权衡、需要更清晰的表达（表达信号直接来自教练量表中表达与清晰度轴的评分，而不是关键词匹配）
- 立论分析训练重点：例如已分析立论中反复出现证据不足、定义问题、因果跳跃、影响权衡薄弱
- 反驳节奏：如果用户在反驳/总结阶段经常用掉大部分时间，会标记为反驳节奏偏慢
- 证据样本：设置页会显示画像依据的本地样本数和部分原始证据片段

如果真实样本不足两场，App 只显示“学习中”，不会推荐话题。

这套长期记忆是本地计算的基线版本，不依赖服务器账号，也不会在辩论过程中弹出问题打断用户。

### 推荐系统 2.0 公式

Rhetorix 的辩题推荐不是“猜你喜欢”的黑箱，也不会只根据 MBTI 推断用户。推荐只在用户至少有两场有效辩论后出现，核心依据是真实本地使用历史和训练弱点。

当前每个候选辩题的排序分数为：

```text
score =
  favoriteCategoryMatch * 16
  + weaknessTrainingTagMatches * 52
  + weaknessKeywordMatches * 18
  + mbtiKeywordMatches * 5
  + categoryFeedbackScore
  - previousDebateCountForSameTopic * 9
  - recentRepeatPenalty
```

其中：

- `favoriteCategoryMatch`：辩题类别是否等于用户最常辩的类别，命中为 1，否则为 0
- `weaknessTrainingTagMatches`：辩题的结构化训练标签是否命中当前最明显弱点，例如 `evidence-heavy`、`definition-heavy`、`impact-weighing`、`policy-mechanism`
- `weaknessKeywordMatches`：训练标签之外的轻量文本兜底匹配，用于兼容自定义辩题和旧数据
- `mbtiKeywordMatches`：MBTI 只提供轻量话题偏好关键词，每个命中只加 5 分
- `categoryFeedbackScore`：辩论结束后用户选择 `like + category` 会让同类题目每次 `+12`；选择 `dislike + category` 会让同类题目每次 `-18`
- `previousDebateCountForSameTopic`：用户已经辩过同一个题目的次数，次数越多扣分越多
- `recentRepeatPenalty`：如果题目出现在最近 5 场辩论中，额外扣 18 分

基础分数计算后，推荐列表会再做一次类别多样性选择：同一个 `category` 在本轮推荐中每已经出现一次，后续同类题目的有效排序分额外扣 `24`。这不会禁止同类题目出现，但会尽量让推荐覆盖不同类别。

权重设计原则：

- 训练价值优先：结构化训练标签命中每项 `+52`
- 文本匹配只做兜底：弱点关键词命中每项 `+18`
- 真实历史轻量参考：用户实际常辩领域 `+16`
- MBTI 只做轻微偏置：每项 `+5`
- 显式用户反馈参与 category 偏好：喜欢类别 `+12`，不喜欢类别 `-18`
- 避免重复：同题每辩过一次 `-9`，最近重复 `-18`
- 尽量多样：同一推荐批次中重复类别每次额外 `-24`

因此推荐会优先命中训练弱点，同时尽可能给用户不同 category 的辩题。MBTI 不会压过真实行为数据。它只在多个题目都符合用户历史和训练目标时，轻微影响排序。用户在赛后选择 `technique` 的喜欢/不喜欢反馈只会被记录，用于未来解释和产品分析，不影响辩题推荐排序。

每个本地辩题现在会携带最多 5 个训练标签。默认题库会在启动时根据题目、类别和说明自动补充标签；旧本地数据和自定义题如果没有标签，也会通过同一套规则补齐。当前标签集合包括：

- `evidence-heavy`
- `definition-heavy`
- `impact-weighing`
- `policy-mechanism`
- `value-clash`
- `rights-autonomy`
- `stakeholder-analysis`
- `causal-reasoning`
- `comparative-weighing`
- `feasibility`
- `direct-clash`
- `structure-burden`

### 推荐算法设计依据

Rhetorix 的推荐系统不是通用内容消费推荐，而是面向辩论训练的学习型推荐。因此，算法目标不是单纯最大化用户过去偏好的相似度，而是在“用户愿意开始辩论”和“本场辩论能训练到具体能力”之间取得平衡。

相关资料对当前设计有三点支持：

- 推荐系统研究通常认为，若过度追求准确命中过去偏好，推荐结果容易出现过度专门化，变得单调且可预测。因此，推荐列表需要在相关性之外保留多样性、新颖性和一定探索空间。Rhetorix 使用最近重复惩罚和同批次 category 多样性惩罚，目的就是避免用户反复看到同一类辩题。
- 个性化学习路径推荐研究强调，学习型推荐应当结合学习者画像、学习过程数据、反馈和目标约束，而不应只做静态兴趣匹配。Rhetorix 使用本地辩论历史、完成情况、阶段用时、裁判反馈、立论分析结果和赛后显式反馈，符合“动态学习者模型”的基本方向。
- 刻意练习研究强调，能力提升需要具体任务、针对性反馈、重复练习和对特定弱点的改进。Rhetorix 将 `weaknessTrainingTagMatches` 设置为最高权重，是因为它的推荐目标不是娱乐内容分发，而是帮助用户持续练习证据、定义、交锋、结构和影响权衡等辩论能力。

基于以上原则，当前推荐算法采用“弱点优先、训练标签匹配、兴趣辅助、MBTI 轻量参考、显式反馈校准、多样性约束”的结构。这个设计适合当前阶段的 Rhetorix：它可解释、可本地运行、对小样本用户友好，并且不需要服务器端协同过滤或大规模用户行为数据。相比早期纯关键词匹配，结构化训练标签让推荐更接近“本题能训练什么能力”，而不是只判断题面中是否出现某个词。

参考资料：

- [Serendipity in Recommender Systems: A Systematic Literature Review](https://jcst.ict.ac.cn/article/cstr/32374.14.s11390-020-0135-9)
- [Personalized Learning Path Recommendation Based on Knowledge Graphs: A Survey](https://www.mdpi.com/2079-9292/15/1/238)
- [A Personalized Learning Path Recommendation Method Incorporating Multi-Algorithm](https://www.mdpi.com/2076-3417/13/10/5946)
- [Deliberate practice and acquisition of expert performance: a general overview](https://pubmed.ncbi.nlm.nih.gov/18778378/)

MBTI 关键词不是四组粗分类，而是 16 个类型分别映射。映射参考 Myers-Briggs 官方对各类型偏好、决策方式和关注点的描述，再转化为辩题关键词。例如：

- INTJ / INTP 更容易轻微偏向系统、科学、技术、哲学和抽象因果问题
- INFJ / INFP 更容易轻微偏向伦理、权利、教育、尊严和社会价值问题
- ESTJ / ISTJ 更容易轻微偏向法律、监管、责任、学校、工作和公共政策问题
- ENTP / ENTJ 更容易轻微偏向创新、政策、经济、监管、资本主义和系统效率问题

这些 MBTI 关键词不会作为用户画像结论展示给用户，只用于推荐排序中的小权重修正。

MBTI 类型描述参考：[Myers & Briggs Foundation - The 16 MBTI Personality Types](https://www.myersbriggs.org/my-mbti-personality-type/the-16-mbti-personality-types/)。

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

Ollama 已从 Provider 列表移除：iPhone App 无法访问 `localhost` 上的本地模型服务，保留它只会误导用户。旧本地数据中的 Ollama 配置和历史记录会在读取时安全回退，不会导致数据丢失。

每个 Provider 支持配置：

- 是否启用
- API Key
- Model
- Base URL

### 12. 主题

iOS 版支持两套主题：

- Dark：中性近黑深色模式
- Light：冷调纸白浅色模式

主题设置保存在本地，并会影响全局背景、文字、卡片、按钮和控件状态。

## 安全策略

Rhetorix 采用 fail-closed 的内容安全策略。

在以下两类内容进入 UI 或数据库之前，都会进行安全检测：

- 用户输入
- 用户创建的自定义辩题标题和说明
- AI 输出

检测目标包括：

- 仇恨言论
- 政治敏感内容
- 制作危险物品的方法
- 色情内容

Provider 行为：

- OpenAI 优先使用 `/v1/moderations`
- 如果 `/v1/moderations` 不可用或返回异常，则回退到同一个 OpenAI/兼容 Provider 的普通问答接口进行安全分类
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
- DebateReviewPoint
- AiProvider
- ProviderConfig
- ConstructiveAnalysisIssue
- FallacyFinding
- RebuttalAttempt
- AppTheme

`DebateResult` 不只保存胜负和一句总结，还会保存结构化深度复盘：裁判判决理由、关键交锋、支持方最强论点、反对方最强论点、下一轮可执行改进项和下一次训练重点。旧版本本地数据仍可读取；缺失的新字段会以空值处理。

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
- 学习目标、经验水平和练习时长
- 五项技能量表、自评和发言重试记录

AI Provider API Key 和火山引擎 Access Token 使用 iOS Keychain 保存。旧版本 JSON 中的凭据会在首次启动时自动迁移；只有 Keychain 写入成功后，本地 JSON 快照才会清除对应明文值。

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
- 引导练习、自评、五项教练量表和发言重试
- Keychain 凭据存储与旧数据迁移

暂未实现或仍需增强：

- iCloud 同步
- 用户账号系统
- App Store 生产签名流程
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
