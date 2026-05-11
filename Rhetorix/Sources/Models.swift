import Foundation
import SwiftUI

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
    case ollama = "Ollama"

    var id: String { rawValue }

    var defaultBaseURL: String {
        switch self {
        case .openAI: "https://api.openai.com/"
        case .anthropic: "https://api.anthropic.com/"
        case .gemini: "https://generativelanguage.googleapis.com/"
        case .deepSeek: "https://api.deepseek.com/"
        case .groq: "https://api.groq.com/"
        case .ollama: "http://localhost:11434/"
        }
    }

    var defaultModel: String {
        switch self {
        case .openAI: "gpt-4o-mini"
        case .anthropic: "claude-3-haiku-20240307"
        case .gemini: "gemini-1.5-flash"
        case .deepSeek: "deepseek-chat"
        case .groq: "llama-3.1-8b-instant"
        case .ollama: "llama3.1"
        }
    }

    var isOpenAICompatible: Bool {
        self == .openAI || self == .deepSeek || self == .groq || self == .ollama
    }
}

struct ProviderConfig: Identifiable, Codable, Equatable {
    var id: AiProvider { provider }
    var provider: AiProvider
    var apiKey: String = ""
    var modelName: String = ""
    var baseURL: String = ""
    var isEnabled: Bool = false

    var resolvedModel: String { modelName.isEmpty ? provider.defaultModel : modelName }
    var resolvedBaseURL: String { baseURL.isEmpty ? provider.defaultBaseURL : baseURL }
}

struct DebateTopic: Identifiable, Codable, Equatable, Hashable {
    var id: String = UUID().uuidString
    var title: String
    var category: String
    var details: String
    var debateCount: Int = 0
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

struct DebateTurn: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var sessionID: String
    var role: SpeakerRole
    var content: String
    var provider: AiProvider?
    var model: String?
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
    var createdAt: Date = Date()
    var isCompleted: Bool = false
}

struct DebateResult: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var winner: SpeakerRole?
    var score: String
    var summary: String
    var createdAt: Date = Date()
}

enum GraphNodeType: String, Codable {
    case topic
    case support
    case oppose
    case evidence
}

struct GraphNode: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var title: String
    var detail: String
    var type: GraphNodeType
    var x: Double
    var y: Double
}

struct GraphEdge: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var from: String
    var to: String
    var relation: String
}

struct ArgumentGraph: Codable, Equatable {
    var topic: DebateTopic
    var debatePreview: [DebateTurn]
    var nodes: [GraphNode]
    var edges: [GraphEdge]
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

struct ChatMessage: Codable {
    var role: String
    var content: String
}

struct ChatResult {
    var content: String
    var finishReason: String?
}

enum AppRoute: Hashable {
    case topicSelection
    case setup(DebateTopic)
    case debate(String)
    case result(String)
    case argumentGraphTopicSelection
    case argumentGraph(DebateTopic)
    case rebuttalTrainer
    case fallacyDetector
    case donation
    case provider(AiProvider)
}

let aiDisclaimer = "内容由AI生成，仅供参考 AI-generated, for reference only"
