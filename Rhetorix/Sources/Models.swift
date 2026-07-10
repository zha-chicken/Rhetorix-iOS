import Foundation
import SwiftUI

enum AppTheme: String, Codable, CaseIterable, Identifiable {
    case dark = "Dark"
    case light = "Pink White"

    var id: String { rawValue }

    var colorScheme: ColorScheme {
        switch self {
        case .dark: .dark
        case .light: .light
        }
    }
}

enum DebateMode: String, Codable, CaseIterable, Identifiable {
    case userVsAi = "User vs AI"
    case aiVsAi = "AI vs AI"
    case faceToFace = "Face to Face"
    var id: String { rawValue }
}

enum DebateFormat: String, Codable, CaseIterable, Identifiable {
    case structured = "Structured"
    case freeFlow = "Free Flow"
    var id: String { rawValue }
}

enum DebateDifficulty: String, Codable, CaseIterable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    var id: String { rawValue }
}

enum LearningGoal: String, Codable, CaseIterable, Identifiable {
    case debateCompetition = "Debate competition"
    case classroom = "Classroom debates"
    case speakingConfidence = "Speaking confidence"
    case englishSpeaking = "English speaking"
    case criticalThinking = "Critical thinking"

    var id: String { rawValue }
}

enum DebateExperience: String, Codable, CaseIterable, Identifiable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    var id: String { rawValue }
}

enum PracticeDuration: Int, Codable, CaseIterable, Identifiable {
    case fiveMinutes = 5
    case tenMinutes = 10
    case twentyMinutes = 20

    var id: Int { rawValue }
}

struct UserLearningProfile: Codable, Equatable {
    var hasCompletedOnboarding = false
    var goal: LearningGoal = .speakingConfidence
    var experience: DebateExperience = .beginner
    var practiceDuration: PracticeDuration = .tenMinutes
}

enum DebateSkill: String, Codable, CaseIterable, Identifiable, Hashable {
    case argumentStructure = "Argument structure"
    case evidence = "Evidence and examples"
    case directClash = "Direct clash and rebuttal"
    case impactWeighing = "Impact comparison"
    case delivery = "Delivery and clarity"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .argumentStructure: "square.stack.3d.up.fill"
        case .evidence: "doc.text.magnifyingglass"
        case .directClash: "bolt.horizontal.circle.fill"
        case .impactWeighing: "scale.3d"
        case .delivery: "waveform"
        }
    }

    var lessonSummary: String {
        switch self {
        case .argumentStructure:
            "Build every argument as a claim, a warrant, and an impact."
        case .evidence:
            "Use a concrete example, explain its relevance, and avoid unsupported certainty."
        case .directClash:
            "Name the opponent's claim, challenge its weakest link, and explain why that changes the debate."
        case .impactWeighing:
            "Compare probability, scale, timeframe, and reversibility instead of listing impacts."
        case .delivery:
            "Signpost your ideas, finish each sentence, and make the decisive point easy to follow."
        }
    }

    var strategy: String {
        switch self {
        case .argumentStructure: "Claim → Why it is true → Why it matters"
        case .evidence: "Example → Source or basis → Link to the claim"
        case .directClash: "They say → But → Because → Therefore"
        case .impactWeighing: "Even if → Our impact matters more because"
        case .delivery: "Signpost → One idea per sentence → Clear conclusion"
        }
    }

    var example: String {
        switch self {
        case .argumentStructure:
            "Schools should teach AI literacy because students already use these systems without understanding their limits; this reduces misinformation and unsafe reliance."
        case .evidence:
            "A school pilot is useful only if you explain who participated, what changed, and why that result applies to this motion."
        case .directClash:
            "They say regulation stops innovation, but clear safety rules can increase adoption because schools and families trust accountable products."
        case .impactWeighing:
            "Even if compliance creates short-term cost, preventing widespread student harm is larger, harder to reverse, and affects more people."
        case .delivery:
            "First, I will answer their cost argument. Second, I will show why our safety impact decides the debate."
        }
    }

    var checklist: [String] {
        switch self {
        case .argumentStructure:
            ["State one clear claim", "Explain the causal link", "Finish with a concrete impact"]
        case .evidence:
            ["Use a specific example", "Explain why it is credible", "Connect it directly to the motion"]
        case .directClash:
            ["Quote or summarize their claim", "Attack its warrant or evidence", "Explain what the clash changes"]
        case .impactWeighing:
            ["Compare both sides", "Use at least two weighing tests", "State which impact decides the round"]
        case .delivery:
            ["Signpost the speech", "Keep sentences focused", "End with a clear conclusion"]
        }
    }
}

enum DebateSide: String, Codable, CaseIterable, Identifiable {
    case support = "Support"
    case oppose = "Oppose"
    var id: String { rawValue }
    var opposite: DebateSide { self == .support ? .oppose : .support }
}

enum AiProvider: String, Codable, CaseIterable, Identifiable {
    case openAI = "OpenAI"
    case anthropic = "Anthropic"
    case gemini = "Google Gemini"
    case deepSeek = "DeepSeek"
    case groq = "Groq"

    var id: String { rawValue }

    // Local snapshots may contain removed providers (e.g. "Ollama");
    // map unknown raw values to OpenAI so old data keeps decoding.
    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = AiProvider(rawValue: raw) ?? .openAI
    }

    var defaultBaseURL: String {
        switch self {
        case .openAI: "https://api.openai.com/"
        case .anthropic: "https://api.anthropic.com/"
        case .gemini: "https://generativelanguage.googleapis.com/"
        case .deepSeek: "https://api.deepseek.com/"
        case .groq: "https://api.groq.com/"
        }
    }

    var defaultModel: String {
        switch self {
        case .openAI: "gpt-4o-mini"
        case .anthropic: "claude-3-haiku-20240307"
        case .gemini: "gemini-1.5-flash"
        case .deepSeek: "deepseek-chat"
        case .groq: "llama-3.1-8b-instant"
        }
    }

    var modelChoices: [String] {
        switch self {
        case .openAI:
            ["gpt-4o-mini", "gpt-4.1-mini", "gpt-4.1", "o4-mini"]
        case .anthropic:
            ["claude-3-haiku-20240307", "claude-3-5-haiku-latest", "claude-3-5-sonnet-latest", "claude-3-7-sonnet-latest"]
        case .gemini:
            ["gemini-1.5-flash", "gemini-1.5-pro", "gemini-2.0-flash"]
        case .deepSeek:
            ["deepseek-v4-pro", "deepseek-v4-flash", "deepseek-chat", "deepseek-reasoner"]
        case .groq:
            ["llama-3.1-8b-instant", "llama-3.3-70b-versatile", "mixtral-8x7b-32768"]
        }
    }

    var isOpenAICompatible: Bool {
        self == .openAI || self == .deepSeek || self == .groq
    }
}

struct ProviderConfig: Identifiable, Codable, Equatable {
    var id: AiProvider { provider }
    var provider: AiProvider
    var apiKey: String = ""
    var modelName: String = ""
    var baseURL: String = ""
    var isEnabled: Bool = false

    var resolvedModel: String {
        let trimmed = modelName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? provider.defaultModel : trimmed
    }

    var resolvedBaseURL: String {
        let trimmed = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? provider.defaultBaseURL : trimmed
    }

    var resolvedAPIKey: String {
        apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum VoiceOutputEngine: String, Codable, CaseIterable, Identifiable {
    case system = "System Voice"
    case volcengine = "Volcengine"
    case voicebox = "Voicebox"

    var id: String { rawValue }
}

struct VolcengineTTSConfig: Codable, Equatable {
    var appID: String = ""
    var accessToken: String = ""
    var cluster: String = "volcano_tts"
    var voiceType: String = "zh_female_meilinvyou_emo_v2_mars_bigtts"
    var speedRatio: Double = 1.0

    var isConfigured: Bool {
        appID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
        accessToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
        cluster.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
        voiceType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
}

struct VoiceboxTTSConfig: Codable, Equatable {
    var baseURL: String = "http://127.0.0.1:17493"
    var profileID: String = ""
    var engine: String = "qwen"
    var modelSize: String = "1.7B"

    static let engineChoices = ["qwen", "qwen_custom_voice", "luxtts", "chatterbox", "chatterbox_turbo", "tada", "kokoro"]
    static let modelSizeChoices = ["1.7B", "0.6B", "1B", "3B"]

    var isConfigured: Bool {
        baseURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
        profileID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
}

enum DebateTrainingTag: String, Codable, CaseIterable, Hashable {
    case evidenceHeavy = "evidence-heavy"
    case definitionHeavy = "definition-heavy"
    case impactWeighing = "impact-weighing"
    case policyMechanism = "policy-mechanism"
    case valueClash = "value-clash"
    case rightsAutonomy = "rights-autonomy"
    case stakeholderAnalysis = "stakeholder-analysis"
    case causalReasoning = "causal-reasoning"
    case comparativeWeighing = "comparative-weighing"
    case feasibility = "feasibility"
    case directClash = "direct-clash"
    case structureBurden = "structure-burden"
}

struct DebateTopic: Identifiable, Codable, Equatable, Hashable {
    var id: String = UUID().uuidString
    var title: String
    var category: String
    var details: String
    var debateCount: Int = 0
    var trainingTags: [DebateTrainingTag] = []

    init(
        id: String = UUID().uuidString,
        title: String,
        category: String,
        details: String,
        debateCount: Int = 0,
        trainingTags: [DebateTrainingTag] = []
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.details = details
        self.debateCount = debateCount
        self.trainingTags = trainingTags
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case category
        case details
        case debateCount
        case trainingTags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        title = try container.decode(String.self, forKey: .title)
        category = try container.decode(String.self, forKey: .category)
        details = try container.decode(String.self, forKey: .details)
        debateCount = try container.decodeIfPresent(Int.self, forKey: .debateCount) ?? 0
        if let decodedTags = try? container.decodeIfPresent([DebateTrainingTag].self, forKey: .trainingTags) {
            trainingTags = decodedTags ?? []
        } else {
            let rawTags = (try? container.decodeIfPresent([String].self, forKey: .trainingTags)) ?? []
            trainingTags = rawTags.compactMap(DebateTrainingTag.init(rawValue:))
        }
    }
}

enum SpeakerRole: String, Codable {
    case user = "You"
    case support = "Support"
    case oppose = "Oppose"
    case judge = "Judge"

    var color: Color {
        switch self {
        case .user: RhetorixColors.cyan
        case .support: RhetorixColors.green
        case .oppose: RhetorixColors.salmon
        case .judge: RhetorixColors.amber
        }
    }
}

enum DebateInputMode: String, Codable {
    case text = "Text"
    case voice = "Voice"
    case ai = "AI"
}

enum MBTIType: String, Codable, CaseIterable, Identifiable {
    case intj = "INTJ"
    case intp = "INTP"
    case entj = "ENTJ"
    case entp = "ENTP"
    case infj = "INFJ"
    case infp = "INFP"
    case enfj = "ENFJ"
    case enfp = "ENFP"
    case istj = "ISTJ"
    case isfj = "ISFJ"
    case estj = "ESTJ"
    case esfj = "ESFJ"
    case istp = "ISTP"
    case isfp = "ISFP"
    case estp = "ESTP"
    case esfp = "ESFP"

    var id: String { rawValue }
}

struct DebateTurn: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var sessionID: String
    var role: SpeakerRole
    var content: String
    var provider: AiProvider?
    var model: String?
    var inputMode: DebateInputMode?
    var stageDurationSeconds: Int?
    var stageLimitSeconds: Int?
    var createdAt: Date = Date()
}

struct DebateSession: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var topic: DebateTopic
    var mode: DebateMode
    var format: DebateFormat
    var difficulty: DebateDifficulty
    var userSide: DebateSide
    var provider: AiProvider
    var turns: [DebateTurn] = []
    var result: DebateResult?
    var practiceSkill: DebateSkill?
    var selfAssessment: DebateSelfAssessment?
    var speechRetries: [SpeechRetry]?
    var createdAt: Date = Date()
    var isCompleted: Bool = false
}

struct DebateSelfAssessment: Codable, Equatable {
    var ratings: [DebateSkill: Int]
    var reflection: String
    var createdAt: Date = Date()
}

struct SpeechRetry: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var originalTurnID: String
    var originalText: String
    var revisedText: String
    var beforeScore: Int
    var afterScore: Int
    var feedback: String
    var improvedSkills: [DebateSkill]
    var createdAt: Date = Date()
}

struct DebateRubricScore: Identifiable, Codable, Equatable {
    var id: DebateSkill { skill }
    var skill: DebateSkill
    var score: Int
    var evidenceQuote: String
    var strength: String
    var nextStep: String
}

struct DebateResult: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var winner: SpeakerRole?
    var score: String
    var summary: String
    var judgeRationale: String = ""
    var keyClashes: [DebateReviewPoint] = []
    var strongestSupportArguments: [DebateReviewPoint] = []
    var strongestOpposeArguments: [DebateReviewPoint] = []
    var improvementActions: [DebateReviewPoint] = []
    var nextPracticeFocus: String = ""
    var rubric: [DebateRubricScore] = []
    var createdAt: Date = Date()

    init(
        id: String = UUID().uuidString,
        winner: SpeakerRole?,
        score: String,
        summary: String,
        judgeRationale: String = "",
        keyClashes: [DebateReviewPoint] = [],
        strongestSupportArguments: [DebateReviewPoint] = [],
        strongestOpposeArguments: [DebateReviewPoint] = [],
        improvementActions: [DebateReviewPoint] = [],
        nextPracticeFocus: String = "",
        rubric: [DebateRubricScore] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.winner = winner
        self.score = score
        self.summary = summary
        self.judgeRationale = judgeRationale
        self.keyClashes = keyClashes
        self.strongestSupportArguments = strongestSupportArguments
        self.strongestOpposeArguments = strongestOpposeArguments
        self.improvementActions = improvementActions
        self.nextPracticeFocus = nextPracticeFocus
        self.rubric = rubric
        self.createdAt = createdAt
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case winner
        case score
        case summary
        case judgeRationale
        case keyClashes
        case strongestSupportArguments
        case strongestOpposeArguments
        case improvementActions
        case nextPracticeFocus
        case rubric
        case createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        winner = try container.decodeIfPresent(SpeakerRole.self, forKey: .winner)
        score = try container.decodeIfPresent(String.self, forKey: .score) ?? "N/A"
        summary = try container.decodeIfPresent(String.self, forKey: .summary) ?? ""
        judgeRationale = try container.decodeIfPresent(String.self, forKey: .judgeRationale) ?? ""
        keyClashes = try container.decodeIfPresent([DebateReviewPoint].self, forKey: .keyClashes) ?? []
        strongestSupportArguments = try container.decodeIfPresent([DebateReviewPoint].self, forKey: .strongestSupportArguments) ?? []
        strongestOpposeArguments = try container.decodeIfPresent([DebateReviewPoint].self, forKey: .strongestOpposeArguments) ?? []
        improvementActions = try container.decodeIfPresent([DebateReviewPoint].self, forKey: .improvementActions) ?? []
        nextPracticeFocus = try container.decodeIfPresent(String.self, forKey: .nextPracticeFocus) ?? ""
        rubric = try container.decodeIfPresent([DebateRubricScore].self, forKey: .rubric) ?? []
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
    }
}

struct DebateReviewPoint: Identifiable, Codable, Equatable, Hashable {
    var id: String = UUID().uuidString
    var title: String
    var detail: String

    init(id: String = UUID().uuidString, title: String, detail: String) {
        self.id = id
        self.title = title
        self.detail = detail
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case detail
    }

    init(from decoder: Decoder) throws {
        if let single = try? decoder.singleValueContainer(), let text = try? single.decode(String.self) {
            id = UUID().uuidString
            title = String(text.prefix(64))
            detail = text
            return
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        detail = try container.decodeIfPresent(String.self, forKey: .detail) ?? ""
    }
}

struct UserMemoryProfile {
    var sampleSize: Int
    var completedCount: Int
    var favoriteCategory: String?
    var preferredMode: DebateMode?
    var preferredDifficulty: DebateDifficulty?
    var preferredSide: DebateSide?
    var completionRate: Int
    var averageTurns: Int
    var voiceTurnRatio: Int
    var averageStageSeconds: Int?

    var hasEnoughData: Bool {
        sampleSize >= 2
    }
}

struct UserProfileMemory: Codable, Equatable {
    var didAskMBTI: Bool = false
    var mbti: MBTIType?
    var styleSignals: [MemorySignal] = []
    var valueSignals: [MemorySignal] = []
    var weaknessSignals: [MemorySignal] = []
    var recommendationFeedback: [RecommendationFeedback]?
    var evidenceSessionCount: Int = 0
    var evidenceTurnCount: Int = 0
    var updatedAt: Date = Date()

    var hasInferenceEvidence: Bool {
        evidenceSessionCount >= 2 || evidenceTurnCount >= 4
    }
}

enum RecommendationFeedbackSentiment: String, Codable, Equatable {
    case like = "Like"
    case dislike = "Dislike"
}

enum RecommendationFeedbackReasonType: String, Codable, Equatable {
    case category = "Category"
    case technique = "Technique"
}

struct RecommendationFeedback: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var sessionID: String
    var topicTitle: String
    var category: String
    var sentiment: RecommendationFeedbackSentiment
    var reasonType: RecommendationFeedbackReasonType
    var createdAt: Date = Date()
}

struct MemorySignal: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var title: String
    var detail: String
    var score: Int
    var evidenceCount: Int
    var evidence: [String]
    var updatedAt: Date = Date()

    var confidence: Int {
        min(95, max(5, evidenceCount * 18 + min(score, 20)))
    }
}

struct TopicRecommendation: Identifiable {
    var id: String { topic.id }
    var topic: DebateTopic
    var reason: String
    var focus: String
    var matchedSignal: String?
}

struct FallacyFinding: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var name: String
    var quote: String
    var explanation: String
    var severity: String
}

struct RebuttalAttempt: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var topic: DebateTopic
    var promptArgument: String
    var userResponse: String
    var score: Int
    var feedback: String
    var createdAt: Date = Date()
}

struct ConstructiveAnalysisIssue: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var claim: String
    var issueType: String
    var quote: String
    var explanation: String
    var rebuttalPoints: [String]
    var severity: String
    var createdAt: Date = Date()
}

struct ChatMessage: Codable {
    var role: String
    var content: String
}

struct ChatResult {
    var content: String
    var finishReason: String?
}

enum AppRoute: Hashable {
    case guidedPractice
    case topicSelection
    case setup(DebateTopic)
    case debate(String)
    case selfAssessment(String)
    case result(String)
    case retrySpeech(String, String)
    case memoryProfile
    case constructiveAnalysis
    case rebuttalTrainer
    case fallacyDetector
    case donation
    case provider(AiProvider)
}

let aiDisclaimer = "内容由AI生成，仅供参考 AI-generated, for reference only"
