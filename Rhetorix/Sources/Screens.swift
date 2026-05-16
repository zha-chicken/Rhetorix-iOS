import SwiftUI
import UIKit
import Speech
import AVFoundation

struct RootView: View {
    @EnvironmentObject private var store: AppStore
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            TabView {
                HomeView(path: $path)
                    .tabItem { Label(store.t("Home"), systemImage: "house.fill") }
                HistoryView(path: $path)
                    .tabItem { Label(store.t("History"), systemImage: "clock") }
                ToolsView(path: $path)
                    .tabItem { Label(store.t("Tools"), systemImage: "square.grid.2x2") }
                SettingsView(path: $path)
                    .tabItem { Label(store.t("Settings"), systemImage: "gearshape") }
            }
            .tint(RhetorixColors.cyan)
            .appScreen()
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .topicSelection:
                    TopicSelectionView(path: $path)
                case .setup(let topic):
                    DebateSetupView(path: $path, topic: topic)
                case .debate(let id):
                    DebateView(path: $path, sessionID: id)
                case .result(let id):
                    ResultView(sessionID: id)
                case .constructiveAnalysis:
                    ConstructiveAnalysisView()
                case .rebuttalTrainer:
                    RebuttalTrainerView()
                case .fallacyDetector:
                    FallacyDetectorView()
                case .donation:
                    DonationView()
                case .provider(let provider):
                    ProviderConfigView(provider: provider)
                }
            }
        }
        .alert("Rhetorix", isPresented: Binding(get: { store.activeError != nil }, set: { if !$0 { store.activeError = nil } })) {
            Button(store.t("OK"), role: .cancel) { store.activeError = nil }
        } message: {
            Text(store.activeError ?? "")
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var path: NavigationPath

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Text("Rhetorix")
                        .font(.largeTitle.bold())
                    Spacer()
                    Button { path.append(AppRoute.donation) } label: {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(RhetorixColors.peach)
                    }
                }

                GlassCard(accent: RhetorixColors.cyan, padding: 20) {
                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(RhetorixColors.textPrimary)
                            .padding(24)
                            .background(Circle().fill(RhetorixColors.glassStrong))
                        Text(store.t("Challenge intelligence. Extend ideas."))
                            .font(.headline)
                            .foregroundStyle(RhetorixColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }

                HStack(spacing: 10) {
                    StatCard(value: "\(store.debateCount)", label: store.t("Debates"), icon: "trophy")
                    StatCard(value: "\(store.winRate)%", label: store.t("Win Rate"), icon: "gearshape")
                    StatCard(value: "\(store.winStreak)", label: store.t("Win Streak"), icon: "flame.fill")
                }

                GlassCard(accent: RhetorixColors.peach) {
                    HStack {
                        Image(systemName: "heart.fill").foregroundStyle(RhetorixColors.peach)
                        VStack(alignment: .leading) {
                            Text(store.t("Support Development")).font(.headline)
                            Text(store.t("All features are free. Donations help keep Rhetorix independent."))
                                .font(.caption)
                                .foregroundStyle(RhetorixColors.textSecondary)
                        }
                        Spacer()
                        Button(store.t("Donate")) { path.append(AppRoute.donation) }
                            .buttonStyle(.bordered)
                    }
                }

                SectionTitle(text: store.t("Quick Actions"))
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    FeatureCard(title: store.t("New Debate"), subtitle: store.t("Start a debate with AI"), icon: "message.fill", accent: RhetorixColors.cyan) {
                        path.append(AppRoute.topicSelection)
                    }
                    FeatureCard(title: store.t("Face-to-Face"), subtitle: store.t("Debate on one device"), icon: "person.2.fill", accent: RhetorixColors.amber) {
                        path.append(AppRoute.setup(store.topics.first ?? AppStore.defaultTopics[0]))
                    }
                    FeatureCard(title: store.t("History"), subtitle: store.t("Review debates"), icon: "clock.fill", accent: RhetorixColors.green) {}
                    FeatureCard(title: store.t("Fallacy Detector"), subtitle: store.t("Analyze reasoning"), icon: "magnifyingglass", accent: RhetorixColors.green) {
                        path.append(AppRoute.fallacyDetector)
                    }
                }

                SectionTitle(text: store.t("Preparation Tools"))
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    FeatureCard(title: store.t("Constructive Analysis"), subtitle: "", icon: "magnifyingglass.circle.fill", accent: RhetorixColors.cyan) {
                        path.append(AppRoute.constructiveAnalysis)
                    }
                    FeatureCard(title: store.t("Rebuttal"), subtitle: "", icon: "timer", accent: RhetorixColors.amber) {
                        path.append(AppRoute.rebuttalTrainer)
                    }
                    FeatureCard(title: store.t("Fallacy"), subtitle: "", icon: "magnifyingglass", accent: RhetorixColors.green) {
                        path.append(AppRoute.fallacyDetector)
                    }
                }
            }
            .padding()
        }
        .appScreen()
    }
}

struct StatCard: View {
    var value: String
    var label: String
    var icon: String
    var body: some View {
        GlassCard(accent: RhetorixColors.cyan, padding: 12) {
            VStack(spacing: 4) {
                Image(systemName: icon).foregroundStyle(RhetorixColors.textSecondary)
                Text(value).font(.title2.bold())
                Text(label).font(.caption2).foregroundStyle(RhetorixColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct FeatureCard: View {
    var title: String
    var subtitle: String
    var icon: String
    var accent: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            GlassCard(accent: accent) {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: icon).font(.title2).foregroundStyle(accent)
                    Text(title).font(.headline).foregroundStyle(RhetorixColors.textPrimary)
                    if subtitle.isEmpty == false {
                        Text(subtitle).font(.caption).foregroundStyle(RhetorixColors.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 76, alignment: .topLeading)
            }
        }
        .buttonStyle(.plain)
    }
}

struct TopicSelectionView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var path: NavigationPath
    @State private var search = ""

    var filtered: [DebateTopic] {
        search.isEmpty ? store.topics : store.topics.filter {
            $0.title.localizedCaseInsensitiveContains(search) ||
            store.topicTitle($0).localizedCaseInsensitiveContains(search) ||
            $0.category.localizedCaseInsensitiveContains(search) ||
            store.category($0.category).localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        List {
            Section {
                TextField(store.t("Search topics..."), text: $search)
            }
            .listRowBackground(RhetorixColors.glass)

            Section(store.t("Trending")) {
                ForEach(filtered) { topic in
                    Button { path.append(AppRoute.setup(topic)) } label: {
                        TopicRow(topic: topic, debateCount: store.debateCount(for: topic))
                    }
                    .listRowBackground(RhetorixColors.glass)
                }
            }
        }
        .navigationTitle(store.t("Select Topic"))
        .toolbar {
            Button(store.t("Add Topic")) {
                let topic = DebateTopic(title: store.t("Custom debate topic"), category: store.t("Custom"), details: store.t("Edit this topic in a future build."))
                store.topics.insert(topic, at: 0)
                path.append(AppRoute.setup(topic))
            }
        }
        .appScreen()
    }
}

struct TopicRow: View {
    @EnvironmentObject private var store: AppStore
    var topic: DebateTopic
    var debateCount: Int
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(store.topicTitle(topic)).foregroundStyle(RhetorixColors.textPrimary)
                Text("\(store.category(topic.category)) · \(store.debateCountText(debateCount))")
                    .font(.caption)
                    .foregroundStyle(RhetorixColors.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(RhetorixColors.textTertiary)
        }
    }
}

struct DebateSetupView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var path: NavigationPath
    var topic: DebateTopic
    @State private var mode: DebateMode = .userVsAi
    @State private var format: DebateFormat = .structured
    @State private var difficulty: DebateDifficulty = .medium
    @State private var side: DebateSide = .support
    @State private var provider: AiProvider = .openAI

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                GlassCard(accent: RhetorixColors.cyan) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(store.topicTitle(topic)).font(.headline)
                        Text(store.topicDetails(topic)).font(.caption).foregroundStyle(RhetorixColors.textSecondary)
                    }
                }
                Picker(store.t("Mode"), selection: $mode) {
                    ForEach(DebateMode.allCases) { Text(store.debateMode($0)).tag($0) }
                }.pickerStyle(.segmented)
                Picker(store.t("Format"), selection: $format) {
                    ForEach(DebateFormat.allCases) { Text(store.debateFormat($0)).tag($0) }
                }.pickerStyle(.segmented)
                Picker(store.t("Difficulty"), selection: $difficulty) {
                    ForEach(DebateDifficulty.allCases) { Text(store.debateDifficulty($0)).tag($0) }
                }.pickerStyle(.segmented)
                Picker(store.t("Your Position"), selection: $side) {
                    ForEach(DebateSide.allCases) { Text(store.debateSide($0)).tag($0) }
                }.pickerStyle(.segmented)
                Picker(store.t("AI Provider"), selection: $provider) {
                    ForEach(AiProvider.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu)
                Button {
                    let session = store.createSession(topic: topic, mode: mode, format: format, difficulty: difficulty, side: side, provider: provider)
                    path.append(AppRoute.debate(session.id))
                } label: {
                    Text(store.t("Start Debate")).frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle(store.t("Debate Setup"))
        .onAppear {
            provider = store.preferredProvider
        }
        .appScreen()
    }
}

struct DebateView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var path: NavigationPath
    var sessionID: String
    @State private var input = ""

    var session: DebateSession? { store.sessions.first { $0.id == sessionID } }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        if let session {
                            DebateStatus(session: session)
                            ForEach(Array(session.turns.enumerated()), id: \.element.id) { index, turn in
                                DebateBubble(turn: turn, stage: store.stageTitle(for: session, turnIndex: index))
                                    .id(turn.id)
                            }
                            if store.isWorking {
                                ProgressView(store.t("Thinking..."))
                                    .padding()
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: session?.turns.count ?? 0) {
                    if let last = session?.turns.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }
            HStack {
                TextField(store.t("Type your argument..."), text: $input, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .disabled(session.map { !store.canHumanType(in: $0) } ?? true)
                Button {
                    let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
                    input = ""
                    Task { await store.sendUserTurn(sessionID: sessionID, text: text) }
                } label: {
                    Image(systemName: "arrow.up.circle.fill").font(.title2)
                }
                .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || store.isWorking || (session.map { !store.canHumanType(in: $0) } ?? true))
            }
            .padding()
            .background(RhetorixColors.backgroundDeep)
        }
        .toolbar {
            if session.map({ store.needsAITurn($0) }) == true {
                Button(store.t("AI Turn")) { Task { await store.advanceAIDebate(sessionID: sessionID) } }
            }
            Button(store.t("End")) { Task { await store.endAndJudge(sessionID: sessionID); path.append(AppRoute.result(sessionID)) } }
        }
        .navigationTitle(session.map { store.topicTitle($0.topic) } ?? store.t("Debate"))
        .appScreen()
    }
}

struct DebateStatus: View {
    @EnvironmentObject private var store: AppStore
    var session: DebateSession
    var body: some View {
        GlassCard(accent: RhetorixColors.amber) {
            HStack {
                Text("\(session.turns.filter { $0.role == .support || ($0.role == .user && session.userSide == .support) }.count)").font(.title.bold()).foregroundStyle(RhetorixColors.green)
                Text(store.t("Support"))
                Spacer()
                VStack(spacing: 2) {
                    Text("\(store.t("Turn")) \(session.turns.count) / \(session.format == .structured ? store.structuredTurnLimit : 12)")
                    Text(store.stageTitle(for: session))
                        .lineLimit(1)
                }
                .font(.caption)
                .foregroundStyle(RhetorixColors.textSecondary)
                Spacer()
                Text(store.t("Oppose"))
                Text("\(session.turns.filter { $0.role == .oppose || ($0.role == .user && session.userSide == .oppose) }.count)").font(.title.bold()).foregroundStyle(RhetorixColors.salmon)
            }
        }
    }
}

struct DebateBubble: View {
    @EnvironmentObject private var store: AppStore
    var turn: DebateTurn
    var stage: String
    var isUser: Bool { turn.role == .user }
    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 50) }
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(store.speaker(turn.role)).font(.caption.bold()).foregroundStyle(turn.role.color)
                    Text(stage).font(.caption2).foregroundStyle(RhetorixColors.textTertiary)
                }
                Text(turn.content).foregroundStyle(RhetorixColors.textPrimary)
                if !isUser { AIDisclaimer(color: RhetorixColors.textTertiary) }
                if let provider = turn.provider {
                    Text("\(provider.rawValue) / \(turn.model ?? "")")
                        .font(.caption2)
                        .foregroundStyle(RhetorixColors.textTertiary)
                }
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 16).fill(turn.role.color.opacity(0.18)))
            if !isUser { Spacer(minLength: 50) }
        }
    }
}

struct ResultView: View {
    @EnvironmentObject private var store: AppStore
    var sessionID: String
    var session: DebateSession? { store.sessions.first { $0.id == sessionID } }

    var body: some View {
        List {
            if let session {
                GlassCard(accent: RhetorixColors.amber) {
                    VStack(spacing: 10) {
                        Image(systemName: "trophy.fill").font(.largeTitle).foregroundStyle(RhetorixColors.amber)
                        Text(store.topicTitle(session.topic)).font(.headline).multilineTextAlignment(.center)
                        Text(store.t("Winner")).font(.caption).foregroundStyle(RhetorixColors.textSecondary)
                        Text(session.result?.winner.map { store.speaker($0) } ?? store.t("N/A")).font(.largeTitle.bold()).foregroundStyle(RhetorixColors.green)
                        Text(session.result?.summary ?? store.t("No judgment yet."))
                            .multilineTextAlignment(.center)
                        AIDisclaimer()
                    }
                }
                .listRowBackground(Color.clear)
                Section(store.t("Transcript")) {
                    ForEach(session.turns) { turn in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(store.speaker(turn.role)).font(.caption.bold()).foregroundStyle(turn.role.color)
                            Text(turn.content)
                            if turn.role != .user { AIDisclaimer() }
                        }
                    }
                }
            }
        }
        .navigationTitle(store.t("Debate Result"))
        .appScreen()
    }
}

struct HistoryView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var path: NavigationPath
    var body: some View {
        List {
            ForEach(store.sessions) { session in
                Button {
                    path.append(session.isCompleted ? AppRoute.result(session.id) : AppRoute.debate(session.id))
                } label: {
                    VStack(alignment: .leading) {
                        Text(store.topicTitle(session.topic)).foregroundStyle(RhetorixColors.textPrimary)
                        Text("\(store.debateMode(session.mode)) · \(session.turns.count) \(store.t("turns"))")
                            .font(.caption)
                            .foregroundStyle(RhetorixColors.textSecondary)
                    }
                }
                .listRowBackground(RhetorixColors.glass)
            }
            ForEach(store.rebuttalAttempts) { attempt in
                VStack(alignment: .leading) {
                    Text(store.t("Rebuttal Training")).foregroundStyle(RhetorixColors.textPrimary)
                    Text("\(store.topicTitle(attempt.topic)) · \(store.t("Score")) \(attempt.score)")
                        .font(.caption)
                        .foregroundStyle(RhetorixColors.textSecondary)
                }
                .listRowBackground(RhetorixColors.glass)
            }
        }
        .navigationTitle(store.t("History"))
        .appScreen()
    }
}

struct ToolsView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var path: NavigationPath
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                FeatureCard(title: store.t("Constructive Analysis"), subtitle: store.t("Analyze opponent constructives"), icon: "magnifyingglass.circle.fill", accent: RhetorixColors.cyan) {
                    path.append(AppRoute.constructiveAnalysis)
                }
                FeatureCard(title: store.t("Rebuttal Trainer"), subtitle: store.t("Timed rebuttal practice"), icon: "timer", accent: RhetorixColors.amber) {
                    path.append(AppRoute.rebuttalTrainer)
                }
                FeatureCard(title: store.t("Logic Fallacy Detector"), subtitle: store.t("Find weak reasoning"), icon: "magnifyingglass", accent: RhetorixColors.green) {
                    path.append(AppRoute.fallacyDetector)
                }
                Link(destination: URL(string: "https://gptzero.me/hallucination-detector")!) {
                    GlassCard(accent: RhetorixColors.peach) {
                        HStack {
                            Image(systemName: "sparkles").foregroundStyle(RhetorixColors.peach)
                            VStack(alignment: .leading) {
                                Text(store.t("AI Hallucination Detector"))
                                Text(store.t("Open GPTZero hallucination detector"))
                                    .font(.caption)
                                    .foregroundStyle(RhetorixColors.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .navigationTitle(store.t("Tools"))
        .appScreen()
    }
}

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var path: NavigationPath
    var body: some View {
        List {
            Section {
                Button { path.append(AppRoute.donation) } label: {
                    Label(store.t("Support Development"), systemImage: "heart.fill")
                }
            }
            .listRowBackground(RhetorixColors.glass)
            Section(store.t("Appearance")) {
                Picker(store.t("Language"), selection: Binding(
                    get: { store.selectedLanguage },
                    set: { store.setLanguage($0) }
                )) {
                    Text(store.t("English")).tag("English")
                    Text(store.t("中文")).tag("中文")
                }
                Picker(store.t("Theme"), selection: Binding(
                    get: { store.appTheme },
                    set: { store.setAppTheme($0) }
                )) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(store.themeName(theme)).tag(theme)
                    }
                }
            }
            .listRowBackground(RhetorixColors.glass)
            Section(store.t("AI Providers")) {
                ForEach(AiProvider.allCases) { provider in
                    Button { path.append(AppRoute.provider(provider)) } label: {
                        HStack {
                            Text(provider.rawValue)
                            Spacer()
                            Text(store.config(for: provider)?.isEnabled == true ? store.t("Enabled") : store.t("Disabled"))
                                .font(.caption)
                                .foregroundStyle(store.config(for: provider)?.isEnabled == true ? RhetorixColors.green : RhetorixColors.salmon)
                        }
                    }
                }
            }
            .listRowBackground(RhetorixColors.glass)
        }
        .navigationTitle(store.t("Settings"))
        .appScreen()
    }
}

struct ProviderConfigView: View {
    @EnvironmentObject private var store: AppStore
    var provider: AiProvider
    @State private var config: ProviderConfig
    @State private var showKey = false

    init(provider: AiProvider) {
        self.provider = provider
        _config = State(initialValue: ProviderConfig(provider: provider, baseURL: provider.defaultBaseURL))
    }

    var body: some View {
        Form {
            Toggle("\(store.t("Enable")) \(provider.rawValue)", isOn: $config.isEnabled)
            TextField(store.t("API Key"), text: $config.apiKey)
                .textContentType(.password)
            TextField(store.t("Model"), text: $config.modelName)
            TextField(store.t("Base URL"), text: $config.baseURL)
            Button(store.t("Save Configuration")) {
                store.saveProvider(config)
            }
        }
        .onAppear {
            config = store.config(for: provider) ?? ProviderConfig(provider: provider, baseURL: provider.defaultBaseURL)
        }
        .navigationTitle(provider.rawValue)
        .appScreen()
    }
}

@MainActor
final class SpeechTranscriber: ObservableObject {
    @Published var transcript = ""
    @Published var isRecording = false
    @Published var errorMessage: String?

    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognizer: SFSpeechRecognizer?
    private var hasInputTap = false

    func start(localeIdentifier: String) {
        Task { await startRecording(localeIdentifier: localeIdentifier) }
    }

    func stop() {
        finishRecording(cancelTask: true)
    }

    private func finishRecording(cancelTask: Bool) {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        if hasInputTap {
            audioEngine.inputNode.removeTap(onBus: 0)
            hasInputTap = false
        }
        recognitionRequest?.endAudio()
        if cancelTask {
            recognitionTask?.cancel()
        }
        recognitionTask = nil
        recognitionRequest = nil
        isRecording = false
    }

    private func startRecording(localeIdentifier: String) async {
        stop()
        errorMessage = nil
        transcript = ""

        let speechStatus = await requestSpeechAuthorization()
        guard speechStatus == .authorized else {
            errorMessage = "Speech recognition permission was denied."
            return
        }
        let micAllowed = await requestMicrophonePermission()
        guard micAllowed else {
            errorMessage = "Microphone permission was denied."
            return
        }

        recognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))
        guard let recognizer, recognizer.isAvailable else {
            errorMessage = "Speech recognizer is not available."
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)

            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            recognitionRequest = request

            let inputNode = audioEngine.inputNode
            let format = inputNode.outputFormat(forBus: 0)
            guard format.sampleRate > 0, format.channelCount > 0 else {
                errorMessage = "No valid microphone input is available."
                finishRecording(cancelTask: true)
                return
            }
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                request.append(buffer)
            }
            hasInputTap = true
            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true

            recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
                Task { @MainActor in
                    if let result {
                        self?.transcript = result.bestTranscription.formattedString
                    }
                    if error != nil || result?.isFinal == true {
                        self?.finishRecording(cancelTask: false)
                    }
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            finishRecording(cancelTask: true)
        }
    }

    private func requestSpeechAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }

    private func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission { allowed in
                    continuation.resume(returning: allowed)
                }
            } else {
                AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                    continuation.resume(returning: allowed)
                }
            }
        }
    }
}

struct ConstructiveAnalysisView: View {
    @EnvironmentObject private var store: AppStore
    @StateObject private var speech = SpeechTranscriber()
    @State private var provider: AiProvider = .openAI
    @State private var inputText = ""
    @State private var issues: [ConstructiveAnalysisIssue] = []
    @State private var selectedIssueID: String?
    @State private var isAnalyzingPaste = false
    @State private var pendingLiveSegments: Set<String> = []
    @State private var analyzedLiveSegments: Set<String> = []

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Picker(store.t("Provider"), selection: $provider) {
                    ForEach(AiProvider.allCases) { Text($0.rawValue).tag($0) }
                }

                GlassCard(accent: RhetorixColors.cyan) {
                    VStack(alignment: .leading, spacing: 10) {
                        Label(store.t("Paste constructive speech"), systemImage: "doc.text")
                            .font(.headline)
                        TextEditor(text: $inputText)
                            .frame(minHeight: 150)
                            .scrollContentBackground(.hidden)
                            .background(RhetorixColors.glass)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        Button {
                            Task {
                                isAnalyzingPaste = true
                                issues = await store.analyzeConstructive(text: inputText, provider: provider)
                                selectedIssueID = issues.first?.id
                                isAnalyzingPaste = false
                            }
                        } label: {
                            if isAnalyzingPaste {
                                ProgressView()
                            } else {
                                Text(store.t("Analyze"))
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isAnalyzingPaste || inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }

                GlassCard(accent: RhetorixColors.amber) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Label(store.t("Live recording analysis"), systemImage: speech.isRecording ? "waveform.circle.fill" : "mic.circle.fill")
                                .font(.headline)
                            Spacer()
                            Button(speech.isRecording ? store.t("Stop Recording") : store.t("Start Recording")) {
                                if speech.isRecording {
                                    speech.stop()
                                } else {
                                    issues = []
                                    pendingLiveSegments = []
                                    analyzedLiveSegments = []
                                    speech.start(localeIdentifier: store.usesChinese ? "zh_CN" : "en_US")
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                        if speech.transcript.isEmpty {
                            Text(store.t("Turn on recording to transcribe and analyze each detected claim."))
                                .font(.caption)
                                .foregroundStyle(RhetorixColors.textSecondary)
                        } else {
                            Text(speech.transcript)
                                .font(.subheadline)
                                .foregroundStyle(RhetorixColors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        if pendingLiveSegments.isEmpty == false {
                            HStack(spacing: 8) {
                                ProgressView()
                                Text(store.t("Analyzing new claim..."))
                                    .font(.caption)
                                    .foregroundStyle(RhetorixColors.textSecondary)
                            }
                        }
                        if let error = speech.errorMessage {
                            Text(error).font(.caption).foregroundStyle(RhetorixColors.salmon)
                        }
                    }
                }

                if issues.isEmpty {
                    GlassCard(accent: RhetorixColors.green) {
                        Text(store.t("No constructive analysis yet."))
                            .font(.subheadline)
                            .foregroundStyle(RhetorixColors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    ForEach(issues) { issue in
                        ConstructiveIssueCard(issue: issue, isExpanded: selectedIssueID == issue.id) {
                            selectedIssueID = selectedIssueID == issue.id ? nil : issue.id
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(store.t("Constructive Analysis"))
        .onAppear {
            provider = store.preferredProvider
        }
        .onDisappear {
            speech.stop()
        }
        .onChange(of: speech.transcript) { _, newValue in
            analyzeLiveSegments(from: newValue)
        }
        .appScreen()
    }

    private func analyzeLiveSegments(from transcript: String) {
        let segments = completedSegments(from: transcript)
        for segment in segments where analyzedLiveSegments.contains(segment) == false && pendingLiveSegments.contains(segment) == false {
            pendingLiveSegments.insert(segment)
            Task { @MainActor in
                let newIssues = await store.analyzeConstructive(text: segment, provider: provider, setWorking: false)
                for issue in newIssues where issues.contains(where: { $0.claim == issue.claim && $0.explanation == issue.explanation }) == false {
                    issues.append(issue)
                }
                analyzedLiveSegments.insert(segment)
                pendingLiveSegments.remove(segment)
                if selectedIssueID == nil {
                    selectedIssueID = issues.first?.id
                }
            }
        }
    }

    private func completedSegments(from transcript: String) -> [String] {
        let separators = CharacterSet(charactersIn: ".!?。！？\n")
        return transcript
            .components(separatedBy: separators)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count >= 28 }
    }
}

struct ConstructiveIssueCard: View {
    @EnvironmentObject private var store: AppStore
    var issue: ConstructiveAnalysisIssue
    var isExpanded: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            GlassCard(accent: accent) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(issue.issueType)
                                .font(.caption.bold())
                                .foregroundStyle(accent)
                            Text(issue.claim)
                                .font(.headline)
                                .foregroundStyle(RhetorixColors.textPrimary)
                        }
                        Spacer()
                        Text(store.t(issue.severity))
                            .font(.caption2.bold())
                            .foregroundStyle(RhetorixColors.textSecondary)
                    }
                    if issue.quote.isEmpty == false {
                        Text("\"\(issue.quote)\"")
                            .font(.caption)
                            .foregroundStyle(RhetorixColors.amber)
                    }
                    if isExpanded {
                        Text(issue.explanation)
                            .font(.subheadline)
                            .foregroundStyle(RhetorixColors.textSecondary)
                        if issue.rebuttalPoints.isEmpty == false {
                            Text(store.t("Rebuttable points"))
                                .font(.caption.bold())
                                .foregroundStyle(RhetorixColors.textPrimary)
                            ForEach(issue.rebuttalPoints, id: \.self) { point in
                                Label(point, systemImage: "arrow.turn.down.right")
                                    .font(.caption)
                                    .foregroundStyle(RhetorixColors.textSecondary)
                            }
                        }
                        AIDisclaimer()
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var accent: Color {
        switch issue.severity.lowercased() {
        case "high": RhetorixColors.salmon
        case "low": RhetorixColors.green
        default: RhetorixColors.amber
        }
    }
}

struct FallacyDetectorView: View {
    @EnvironmentObject private var store: AppStore
    @State private var text = ""
    @State private var provider: AiProvider = .openAI
    @State private var results: [FallacyFinding] = []
    @State private var isAnalyzing = false
    @State private var hasAnalyzed = false

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                TextEditor(text: $text)
                    .frame(minHeight: 160)
                    .scrollContentBackground(.hidden)
                    .background(RhetorixColors.glass)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Picker(store.t("Provider"), selection: $provider) {
                    ForEach(AiProvider.allCases) { Text($0.rawValue).tag($0) }
                }
                Button(store.t("Analyze for Fallacies")) {
                    Task {
                        hasAnalyzed = false
                        isAnalyzing = true
                        results = await store.generateFallacies(text: text, provider: provider)
                        isAnalyzing = false
                        hasAnalyzed = store.activeError == nil
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isAnalyzing || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                if isAnalyzing {
                    GlassCard(accent: RhetorixColors.cyan) {
                        HStack(spacing: 12) {
                            ProgressView()
                            Text(store.t("Analyzing fallacies..."))
                                .font(.subheadline)
                                .foregroundStyle(RhetorixColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else if hasAnalyzed && results.isEmpty {
                    GlassCard(accent: RhetorixColors.green) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(store.t("未检出"))
                                .font(.headline)
                            Text(store.t("No logical fallacies were detected in this text."))
                                .font(.subheadline)
                                .foregroundStyle(RhetorixColors.textSecondary)
                            AIDisclaimer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                ForEach(results) { result in
                    GlassCard(accent: RhetorixColors.salmon) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(result.name).font(.headline)
                            if result.quote.isEmpty == false { Text("\"\(result.quote)\"").font(.caption).foregroundStyle(RhetorixColors.amber) }
                            Text(result.explanation).font(.subheadline)
                            AIDisclaimer()
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(store.t("Fallacy Detector"))
        .onAppear {
            provider = store.preferredProvider
        }
        .onChange(of: text) {
            hasAnalyzed = false
            results = []
        }
        .appScreen()
    }
}

struct RebuttalTrainerView: View {
    @EnvironmentObject private var store: AppStore
    @State private var topic = AppStore.defaultTopics[0]
    @State private var provider: AiProvider = .openAI
    @State private var prompt = ""
    @State private var response = ""
    @State private var attempt: RebuttalAttempt?

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Picker(store.t("Topic"), selection: $topic) {
                    ForEach(store.topics) { Text(store.topicTitle($0)).tag($0) }
                }
                Picker(store.t("Provider"), selection: $provider) {
                    ForEach(AiProvider.allCases) { Text($0.rawValue).tag($0) }
                }
                Button(store.t("Generate Argument")) {
                    Task { prompt = await store.generateRebuttalPrompt(topic: topic, side: .oppose, provider: provider) }
                }
                .buttonStyle(.borderedProminent)
                if prompt.isEmpty == false {
                    GlassCard(accent: RhetorixColors.amber) {
                        VStack(alignment: .leading) {
                            Text(store.t("Argument to resist")).font(.headline)
                            Text(prompt)
                            AIDisclaimer()
                        }
                    }
                    TextEditor(text: $response)
                        .frame(height: 160)
                        .scrollContentBackground(.hidden)
                        .background(RhetorixColors.glass)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    Button(store.t("Submit Rebuttal")) {
                        Task { attempt = await store.scoreRebuttal(topic: topic, prompt: prompt, response: response, provider: provider) }
                    }
                    .buttonStyle(.borderedProminent)
                }
                if let attempt {
                    GlassCard(accent: RhetorixColors.green) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(attempt.score) / 100").font(.largeTitle.bold())
                            Text(attempt.feedback)
                            AIDisclaimer()
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(store.t("Rebuttal Trainer"))
        .onAppear {
            provider = store.preferredProvider
        }
        .appScreen()
    }
}

struct DonationView: View {
    @EnvironmentObject private var store: AppStore
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(systemName: "heart.fill").font(.system(size: 64)).foregroundStyle(RhetorixColors.peach)
                Text(store.t("Thank you for supporting Rhetorix")).font(.title2.bold()).multilineTextAlignment(.center)
                GlassCard(accent: RhetorixColors.peach) {
                    VStack(spacing: 8) {
                        if let url = Bundle.main.url(forResource: "qrcode_donation", withExtension: "jpg"),
                           let image = UIImage(contentsOfFile: url.path) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 240)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            Image(systemName: "qrcode")
                                .font(.system(size: 96))
                                .foregroundStyle(RhetorixColors.textSecondary)
                                .frame(width: 220, height: 220)
                        }
                        Text(store.t("Scan with WeChat or Alipay"))
                            .font(.caption)
                            .foregroundStyle(RhetorixColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                Text(store.t("All features are free. Donations help maintain the app and add new features."))
                    .font(.footnote)
                    .foregroundStyle(RhetorixColors.textSecondary)
            }
            .padding()
        }
        .navigationTitle(store.t("Support Development"))
        .appScreen()
    }
}
