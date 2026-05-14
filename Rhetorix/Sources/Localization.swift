import Foundation

extension AppStore {
    var usesChinese: Bool {
        selectedLanguage == "中文"
    }

    func t(_ key: String) -> String {
        guard usesChinese else { return key }
        return Self.zhCN[key] ?? key
    }

    func topicTitle(_ topic: DebateTopic) -> String {
        guard usesChinese else { return topic.title }
        return Self.zhCNTopics[topic.title] ?? topic.title
    }

    func topicDetails(_ topic: DebateTopic) -> String {
        guard usesChinese else { return topic.details }
        return Self.zhCNTopicDetails[topic.title] ?? topic.details
    }

    func category(_ value: String) -> String {
        t(value)
    }

    func debateMode(_ mode: DebateMode) -> String {
        t(mode.rawValue)
    }

    func debateFormat(_ format: DebateFormat) -> String {
        t(format.rawValue)
    }

    func debateDifficulty(_ difficulty: DebateDifficulty) -> String {
        t(difficulty.rawValue)
    }

    func debateSide(_ side: DebateSide) -> String {
        t(side.rawValue)
    }

    func speaker(_ role: SpeakerRole) -> String {
        t(role.rawValue)
    }

    func themeName(_ theme: AppTheme) -> String {
        t(theme.rawValue)
    }

    func debateCountText(_ count: Int) -> String {
        usesChinese ? "\(count) 场辩论" : "\(count) \(count == 1 ? "debate" : "debates")"
    }

    private static let zhCN: [String: String] = [
        "Home": "首页",
        "History": "历史",
        "Tools": "工具",
        "Settings": "设置",
        "OK": "确定",
        "Challenge intelligence. Extend ideas.": "挑战智能，延展观点。",
        "Support Development": "支持开发",
        "All features are free. Donations help keep Rhetorix independent.": "所有功能免费。赞助帮助 Rhetorix 保持独立。",
        "Donate": "赞助",
        "Quick Actions": "快捷操作",
        "New Debate": "新辩论",
        "Start a debate with AI": "与 AI 开始辩论",
        "Face-to-Face": "面对面辩论",
        "Debate on one device": "两人在同一设备辩论",
        "Review debates": "查看辩论记录",
        "Fallacy Detector": "谬误检测",
        "Analyze reasoning": "分析推理问题",
        "Preparation Tools": "准备工具",
        "Argument Graph": "论点图",
        "Rebuttal": "反驳",
        "Fallacy": "谬误",
        "Debates": "辩论",
        "Win Rate": "胜率",
        "Win Streak": "连胜",
        "Search topics...": "搜索辩题...",
        "Trending": "热门",
        "Select Topic": "选择话题",
        "Add Topic": "添加话题",
        "Custom debate topic": "自定义辩题",
        "Custom": "自定义",
        "Edit this topic in a future build.": "后续版本可编辑这个话题。",
        "Choose a Topic": "选择话题",
        "Graph Topic": "论点图话题",
        "Custom graph topic": "自定义论点图话题",
        "Mode": "辩论模式",
        "Format": "辩论形式",
        "Difficulty": "难度",
        "Your Position": "你的立场",
        "AI Provider": "AI 提供方",
        "Start Debate": "开始辩论",
        "Debate Setup": "辩论设置",
        "Thinking...": "思考中...",
        "Type your argument...": "输入你的论点...",
        "AI Turn": "AI 发言",
        "End": "结束",
        "Debate": "辩论",
        "Support": "支持",
        "Oppose": "反对",
        "Turn": "回合",
        "Winner": "胜者",
        "N/A": "暂无",
        "No judgment yet.": "尚未评分。",
        "Transcript": "记录",
        "Debate Result": "辩论结果",
        "turns": "回合",
        "Rebuttal Training": "反驳训练",
        "Score": "得分",
        "Argument Relationship Graph": "论点关系图",
        "Map claims and rebuttals": "梳理论点与反驳",
        "Rebuttal Trainer": "反驳训练",
        "Timed rebuttal practice": "限时反驳练习",
        "Logic Fallacy Detector": "逻辑谬误检测",
        "Find weak reasoning": "发现薄弱推理",
        "AI Hallucination Detector": "AI 幻觉检测",
        "Open GPTZero hallucination detector": "打开 GPTZero 幻觉检测工具",
        "Appearance": "外观",
        "Theme": "主题",
        "Language": "语言",
        "English": "English",
        "中文": "中文",
        "Dark": "深色",
        "Pink White": "粉白浅色",
        "AI Providers": "AI 提供方",
        "Enabled": "已启用",
        "Disabled": "已禁用",
        "Enable": "启用",
        "API Key": "API Key",
        "Model": "模型",
        "Base URL": "Base URL",
        "Save Configuration": "保存配置",
        "Map Mode": "图谱模式",
        "Key": "关键",
        "Preparing node text...": "正在生成节点文本...",
        "AI Prep Text": "AI 备赛文本",
        "Refresh AI Text": "刷新 AI 文本",
        "No graph yet": "暂无论点图",
        "Provider": "提供方",
        "Generate with AI": "用 AI 生成",
        "Generating...": "生成中...",
        "Prep": "准备",
        "Clash": "冲突",
        "Drill": "训练",
        "Use this node to build your constructive speech.": "用这个节点构建你的立论发言。",
        "Use this node to compare which side wins the debate.": "用这个节点比较哪一方更能赢下辩论。",
        "Practice answering this attack out loud before the round.": "赛前用这个节点练习回应攻击。",
        "Analyze for Fallacies": "分析逻辑谬误",
        "Analyzing fallacies...": "正在分析逻辑谬误...",
        "未检出": "未检出",
        "No logical fallacies were detected in this text.": "这段文本中没有检测到明显逻辑谬误。",
        "Topic": "话题",
        "Generate Argument": "生成待反驳观点",
        "Argument to resist": "待反驳观点",
        "Submit Rebuttal": "提交反驳",
        "Thank you for supporting Rhetorix": "感谢支持 Rhetorix",
        "Scan with WeChat or Alipay": "使用微信或支付宝扫码",
        "All features are free. Donations help maintain the app and add new features.": "所有功能免费。赞助会帮助维护应用并添加新功能。",
        "User vs AI": "人机辩论",
        "AI vs AI": "AI 对 AI",
        "Face to Face": "面对面",
        "Structured": "结构化",
        "Free Flow": "自由交流",
        "Easy": "简单",
        "Medium": "中等",
        "Hard": "困难",
        "You": "你",
        "Judge": "裁判",
        "Technology": "科技",
        "Society": "社会",
        "Ethics": "伦理",
        "Economics": "经济",
        "Politics": "政治",
        "Environment": "环境",
        "Work": "工作",
        "Education": "教育"
    ]

    private static let zhCNTopics: [String: String] = [
        "Should AI be regulated by governments?": "政府是否应该监管人工智能？",
        "Is universal basic income a good idea?": "全民基本收入是好主意吗？",
        "Is social media doing more harm than good?": "社交媒体是否弊大于利？",
        "Will AI replace most human jobs?": "AI 会取代大多数人类工作吗？",
        "Should euthanasia be legal?": "安乐死是否应该合法化？",
        "Is cryptocurrency the future of money?": "加密货币是货币的未来吗？"
    ]

    private static let zhCNTopicDetails: [String: String] = [
        "Should AI be regulated by governments?": "讨论政府是否应监管人工智能的发展与使用。",
        "Is universal basic income a good idea?": "比较经济安全、工作激励和公共成本。",
        "Is social media doing more harm than good?": "评估心理健康、公共讨论、错误信息和人际连接。",
        "Will AI replace most human jobs?": "辩论自动化、新工作创造和经济转型。",
        "Should euthanasia be legal?": "讨论自主权、保护机制、痛苦和医疗责任。",
        "Is cryptocurrency the future of money?": "比较去中心化、波动性、监管和采用程度。"
    ]
}
