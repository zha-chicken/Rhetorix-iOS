import SwiftUI
import UIKit
import Speech
import AVFoundation

struct RootView: View {
    @EnvironmentObject private var store: AppStore
    @State private var path = NavigationPath()
    @State private var selectedTab: MainTab = .home

    var body: some View {
        NavigationStack(path: $path) {
            TabView(selection: $selectedTab) {
                HomeView(path: $path, selectedTab: $selectedTab)
                    .tabItem { Label(store.t("Home"), systemImage: "house.fill") }
                    .tag(MainTab.home)
                HistoryView(path: $path)
                    .tabItem { Label(store.t("History"), systemImage: "clock") }
                    .tag(MainTab.history)
                ToolsView(path: $path)
                    .tabItem { Label(store.t("Tools"), systemImage: "square.grid.2x2") }
                    .tag(MainTab.tools)
                SettingsView(path: $path)
                    .tabItem { Label(store.t("Settings"), systemImage: "gearshape") }
                    .tag(MainTab.settings)
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
        .sheet(isPresented: Binding(get: { store.shouldAskMBTI }, set: { if !$0 && store.userProfileMemory.didAskMBTI == false { store.setMBTI(nil) } })) {
            MBTIOnboardingView()
                .environmentObject(store)
                .interactiveDismissDisabled()
        }
    }
}

enum MainTab: Hashable {
    case home
    case history
    case tools
    case settings
}

struct HomeView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var path: NavigationPath
    @Binding var selectedTab: MainTab

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Text("Rhetorix")
                        .font(.largeTitle.bold())
                    Spacer()
                }

                GlassCard(accent: RhetorixColors.cyan, padding: 20) {
                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(RhetorixColors.textPrimary)
                            .padding(24)
                            .background(Circle().fill(RhetorixColors.glassStrong))
                        Text(store.t("Live Debate"))
                            .font(.title.bold())
                            .foregroundStyle(RhetorixColors.textPrimary)
                        Text(store.t("Challenge intelligence. Extend ideas."))
                            .font(.headline)
                            .foregroundStyle(RhetorixColors.textSecondary)
                        Button {
                            path.append(AppRoute.topicSelection)
                        } label: {
                            Label(store.t("Start Voice Debate"), systemImage: "mic.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("home.startVoiceDebate")
                    }
                    .frame(maxWidth: .infinity)
                }

                HStack(spacing: 10) {
                    StatCard(value: "\(store.debateCount)", label: store.t("Debates"), icon: "trophy")
                    StatCard(value: "\(store.winRate)%", label: store.t("Win Rate"), icon: "gearshape")
                    StatCard(value: "\(store.winStreak)", label: store.t("Win Streak"), icon: "flame.fill")
                }

                MemoryInsightCard(path: $path)

                SectionTitle(text: store.t("Quick Actions"))
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    FeatureCard(title: store.t("New Debate"), subtitle: store.t("Start a timed debate"), icon: "message.fill", accent: RhetorixColors.cyan) {
                        path.append(AppRoute.topicSelection)
                    }
                    FeatureCard(title: store.t("History"), subtitle: store.t("Review debates"), icon: "clock.fill", accent: RhetorixColors.green) {
                        selectedTab = .history
                    }
                }

                SectionTitle(text: store.t("Preparation Tools"))
                HStack(spacing: 10) {
                    CompactToolButton(title: store.t("Constructive Analysis"), icon: "magnifyingglass.circle.fill", accent: RhetorixColors.cyan) {
                        path.append(AppRoute.constructiveAnalysis)
                    }
                    CompactToolButton(title: store.t("Rebuttal"), icon: "timer", accent: RhetorixColors.amber) {
                        path.append(AppRoute.rebuttalTrainer)
                    }
                    CompactToolButton(title: store.t("Fallacy"), icon: "magnifyingglass", accent: RhetorixColors.green) {
                        path.append(AppRoute.fallacyDetector)
                    }
                }
            }
            .padding()
        }
        .appScreen()
    }
}

struct MemoryInsightCard: View {
    @EnvironmentObject private var store: AppStore
    @Binding var path: NavigationPath

    var body: some View {
        GlassCard(accent: RhetorixColors.amber) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label(store.t("Memory"), systemImage: "brain.head.profile")
                        .font(.headline)
                    Spacer()
                    Text(store.memoryProfile.hasEnoughData ? store.t("Real local memory") : store.t("Learning"))
                        .font(.caption.bold())
                        .foregroundStyle(RhetorixColors.textSecondary)
                }
                Text(store.memorySummaryText())
                    .font(.caption)
                    .foregroundStyle(RhetorixColors.textSecondary)
                if store.userProfileMemory.mbti != nil || store.userProfileMemory.hasInferenceEvidence {
                    VStack(alignment: .leading, spacing: 8) {
                        if let mbti = store.userProfileMemory.mbti {
                            MemoryProfilePill(title: store.t("MBTI"), value: mbti.rawValue)
                        }
                        if let style = store.userProfileMemory.styleSignals.first {
                            MemoryProfilePill(title: store.t("Debate style"), value: store.t(style.title))
                        }
                        if let value = store.userProfileMemory.valueSignals.first {
                            MemoryProfilePill(title: store.t("Value signal"), value: store.t(value.title))
                        }
                        if let weakness = store.userProfileMemory.weaknessSignals.first {
                            MemoryProfilePill(title: store.t("Practice focus"), value: store.t(weakness.title))
                        }
                    }
                }
                if let recommendation = store.topicRecommendation {
                    Button {
                        path.append(AppRoute.setup(recommendation.topic))
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(store.t("Recommended topic"))
                                    .font(.caption.bold())
                                    .foregroundStyle(RhetorixColors.amber)
                                Text(store.topicTitle(recommendation.topic))
                                    .font(.subheadline.bold())
                                    .foregroundStyle(RhetorixColors.textPrimary)
                                Text(recommendation.reason)
                                    .font(.caption2)
                                    .foregroundStyle(RhetorixColors.textTertiary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(RhetorixColors.textTertiary)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 12).fill(RhetorixColors.glassStrong))
                }
            }
        }
    }
}

struct MemoryProfilePill: View {
    var title: String
    var value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(RhetorixColors.textTertiary)
            Spacer()
            Text(value)
                .font(.caption.bold())
                .foregroundStyle(RhetorixColors.textPrimary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(RoundedRectangle(cornerRadius: 12).fill(RhetorixColors.glassStrong))
    }
}

struct MBTIOnboardingView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: 74), spacing: 8)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(store.t("Build your debate profile"))
                    .font(.title.bold())
                    .foregroundStyle(RhetorixColors.textPrimary)
                Text(store.t("Choose your MBTI if you want Rhetorix to include it in your local profile. You can skip this."))
                    .font(.subheadline)
                    .foregroundStyle(RhetorixColors.textSecondary)

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(MBTIType.allCases) { type in
                        Button {
                            store.setMBTI(type)
                            dismiss()
                        } label: {
                            Text(type.rawValue)
                                .font(.headline)
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.bordered)
                    }
                }

                Button {
                    store.setMBTI(nil)
                    dismiss()
                } label: {
                    Text(store.t("Skip for now"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("onboarding.skipMBTI")

                Text(store.t("Rhetorix only infers traits from real local debate history. It will not invent a profile when evidence is insufficient."))
                    .font(.caption)
                    .foregroundStyle(RhetorixColors.textTertiary)
            }
            .padding(24)
        }
        .appScreen()
    }
}

struct CompactToolButton: View {
    var title: String
    var icon: String
    var accent: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundStyle(accent)
                Text(title)
                    .font(.caption2.bold())
                    .foregroundStyle(RhetorixColors.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.76)
            }
            .frame(maxWidth: .infinity, minHeight: 62)
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 14).fill(RhetorixColors.glass))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(accent.opacity(0.22), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
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
    @State private var showCustomTopicDialog = false
    @State private var customTopicTitle = ""
    @State private var customTopicDetails = ""

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
                ForEach(Array(filtered.enumerated()), id: \.element.id) { index, topic in
                    Button { path.append(AppRoute.setup(topic)) } label: {
                        TopicRow(topic: topic, debateCount: store.debateCount(for: topic))
                    }
                    .listRowBackground(RhetorixColors.glass)
                    .accessibilityIdentifier("topic.row.\(index)")
                }
            }
        }
        .navigationTitle(store.t("Select Topic"))
        .toolbar {
            Button(store.t("Add Topic")) {
                customTopicTitle = ""
                customTopicDetails = ""
                showCustomTopicDialog = true
            }
        }
        .alert(store.t("Custom Topic"), isPresented: $showCustomTopicDialog) {
            TextField(store.t("Topic title"), text: $customTopicTitle)
                .textInputAutocapitalization(.sentences)
            TextField(store.t("Optional details"), text: $customTopicDetails)
                .textInputAutocapitalization(.sentences)
            Button(store.t("Cancel"), role: .cancel) { }
            Button(store.t("Create Topic")) {
                if let topic = store.addCustomTopic(title: customTopicTitle, details: customTopicDetails) {
                    path.append(AppRoute.setup(topic))
                }
            }
        } message: {
            Text(store.t("Create a debate topic that is saved locally and can be reused."))
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
                if mode == .userVsAi {
                    Picker(store.t("Your Position"), selection: $side) {
                        ForEach(DebateSide.allCases) { Text(store.debateSide($0)).tag($0) }
                    }.pickerStyle(.segmented)
                }
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
                .accessibilityIdentifier("setup.startDebate")
            }
            .padding()
        }
        .navigationTitle(store.t("Debate Setup"))
        .onAppear {
            provider = store.preferredProvider
        }
        .onChange(of: mode) { _, newMode in
            if newMode != .userVsAi {
                side = .support
            }
        }
        .appScreen()
    }
}

struct DebateView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var path: NavigationPath
    var sessionID: String
    @StateObject private var speech = SpeechTranscriber()
    @StateObject private var aiSpeech = AISpeechPlayer()
    @State private var input = ""
    @State private var draftInputMode: DebateInputMode = .text
    @State private var stageStartedAt = Date()
    @State private var now = Date()
    @State private var isEndingDebate = false

    var session: DebateSession? { store.sessions.first { $0.id == sessionID } }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        if let session {
                            DebateStatus(session: session, stageStartedAt: stageStartedAt, now: now)
                            ForEach(Array(session.turns.enumerated()), id: \.element.id) { index, turn in
                                DebateBubble(turn: turn, stage: store.stageTitle(for: session, turnIndex: index), speechPlayer: aiSpeech)
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
                    stageStartedAt = Date()
                    if let last = session?.turns.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        if store.autoSpeakAI, last.inputMode == .ai {
                            aiSpeech.speak(last.content, turnID: last.id, usesChinese: store.usesChinese)
                        }
                    }
                }
            }
            if session?.mode != .aiVsAi {
                DebateInputBar(
                    input: $input,
                    speech: speech,
                    canSpeak: session.map { store.canHumanType(in: $0) } ?? false,
                    isWorking: store.isWorking,
                    usesChinese: store.usesChinese,
                    send: sendInput
                )
            }
        }
        .onAppear { stageStartedAt = Date() }
        .onDisappear {
            speech.stop()
            aiSpeech.stop()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { value in
            now = value
        }
        .onChange(of: speech.transcript) { _, transcript in
            if transcript.isEmpty == false {
                input = transcript
                draftInputMode = .voice
            }
        }
        .toolbar {
            if session.map({ store.needsAITurn($0) }) == true {
                Button(store.t("AI Turn")) { Task { await store.advanceAIDebate(sessionID: sessionID) } }
            }
            Button {
                Task { await endDebate() }
            } label: {
                if isEndingDebate {
                    HStack(spacing: 6) {
                        ProgressView()
                        Text(store.t("Ending..."))
                    }
                } else {
                    Text(store.t("End"))
                }
            }
            .disabled(isEndingDebate || store.isWorking)
            .accessibilityIdentifier("debate.end")
        }
        .navigationTitle(session.map { store.topicTitle($0.topic) } ?? store.t("Debate"))
        .appScreen()
    }

    private func sendInput() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let duration = max(0, Int(Date().timeIntervalSince(stageStartedAt)))
        let mode = draftInputMode
        input = ""
        draftInputMode = .text
        speech.stop()
        Task { await store.sendUserTurn(sessionID: sessionID, text: text, inputMode: mode, stageDurationSeconds: duration) }
    }

    private func endDebate() async {
        isEndingDebate = true
        await store.endAndJudge(sessionID: sessionID)
        isEndingDebate = false
        path.append(AppRoute.result(sessionID))
    }
}

struct DebateStatus: View {
    @EnvironmentObject private var store: AppStore
    var session: DebateSession
    var stageStartedAt: Date
    var now: Date

    var body: some View {
        GlassCard(accent: RhetorixColors.amber) {
            VStack(spacing: 12) {
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
                StageTimerView(limit: store.stageTimeLimit(for: session), startedAt: stageStartedAt, now: now)
            }
        }
    }
}

struct StageTimerView: View {
    @EnvironmentObject private var store: AppStore
    var limit: Int
    var startedAt: Date
    var now: Date

    private var elapsed: Int {
        max(0, Int(now.timeIntervalSince(startedAt)))
    }

    private var remaining: Int {
        limit - elapsed
    }

    private var progress: Double {
        guard limit > 0 else { return 1 }
        return min(1, max(0, Double(elapsed) / Double(limit)))
    }

    private var accent: Color {
        if remaining < 0 { return RhetorixColors.salmon }
        if remaining <= 15 { return RhetorixColors.amber }
        return RhetorixColors.cyan
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Label(store.t("Stage Timer"), systemImage: "timer")
                    .font(.caption.bold())
                    .foregroundStyle(RhetorixColors.textSecondary)
                Spacer()
                Text(displayTime)
                    .font(.title3.monospacedDigit().bold())
                    .foregroundStyle(accent)
            }
            ProgressView(value: progress)
                .tint(accent)
        }
    }

    private var displayTime: String {
        let absolute = abs(remaining)
        let minutes = absolute / 60
        let seconds = absolute % 60
        let prefix = remaining < 0 ? "+" : ""
        return "\(prefix)\(minutes):\(String(format: "%02d", seconds))"
    }
}

struct DebateInputBar: View {
    @EnvironmentObject private var store: AppStore
    @Binding var input: String
    @ObservedObject var speech: SpeechTranscriber
    var canSpeak: Bool
    var isWorking: Bool
    var usesChinese: Bool
    var send: () -> Void
    @State private var isTextInputVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 16) {
                Button {
                    isTextInputVisible.toggle()
                } label: {
                    Image(systemName: isTextInputVisible ? "keyboard.chevron.compact.down" : "keyboard")
                        .font(.system(size: 22, weight: .semibold))
                        .frame(width: 48, height: 48)
                        .background(Circle().fill(RhetorixColors.glassStrong))
                }
                .disabled(!canSpeak || isWorking)
                .accessibilityIdentifier("debate.keyboard")

                Spacer()

                Button {
                    if speech.isRecording {
                        speech.stop()
                    } else {
                        speech.start(localeIdentifier: usesChinese ? "zh_CN" : "en_US")
                    }
                } label: {
                    Image(systemName: speech.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 66, weight: .semibold))
                        .foregroundStyle(speech.isRecording ? RhetorixColors.salmon : RhetorixColors.cyan)
                        .frame(width: 88, height: 88)
                        .background(Circle().fill(RhetorixColors.glassStrong))
                        .overlay(Circle().stroke((speech.isRecording ? RhetorixColors.salmon : RhetorixColors.cyan).opacity(0.36), lineWidth: 1.5))
                }
                .disabled(!canSpeak || isWorking)
                .accessibilityIdentifier("debate.voice")

                Spacer()

                Button(action: send) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 34, weight: .semibold))
                        .frame(width: 48, height: 48)
                }
                .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isWorking || !canSpeak)
                .accessibilityIdentifier("debate.send")
            }

            if isTextInputVisible {
                TextField(store.t("Speak or type your argument..."), text: $input, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .disabled(!canSpeak)
                    .accessibilityIdentifier("debate.input")
            }

            if speech.isRecording {
                Label(store.t("Listening..."), systemImage: "waveform")
                    .font(.caption)
                    .foregroundStyle(RhetorixColors.cyan)
            } else if let error = speech.errorMessage {
                Text(store.t(error))
                    .font(.caption)
                    .foregroundStyle(RhetorixColors.salmon)
            } else {
                Text(store.t(isTextInputVisible ? "Voice is primary. Text remains available." : "Tap the keyboard button to type instead of speaking."))
                    .font(.caption2)
                    .foregroundStyle(RhetorixColors.textTertiary)
            }
        }
        .padding()
        .background(RhetorixColors.backgroundDeep)
    }
}

struct DebateBubble: View {
    @EnvironmentObject private var store: AppStore
    var turn: DebateTurn
    var stage: String
    @ObservedObject var speechPlayer: AISpeechPlayer
    var isUser: Bool { turn.role == .user }
    var canSpeak: Bool { turn.inputMode == .ai || turn.provider != nil }
    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 50) }
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(store.speaker(turn.role)).font(.caption.bold()).foregroundStyle(turn.role.color)
                    Text(stage).font(.caption2).foregroundStyle(RhetorixColors.textTertiary)
                    Spacer(minLength: 8)
                    if canSpeak {
                        Button {
                            if speechPlayer.speakingTurnID == turn.id {
                                speechPlayer.stop()
                            } else {
                                speechPlayer.speak(turn.content, turnID: turn.id, usesChinese: store.usesChinese)
                            }
                        } label: {
                            Image(systemName: speechPlayer.speakingTurnID == turn.id ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(store.t(speechPlayer.speakingTurnID == turn.id ? "Stop AI voice" : "Read AI response"))
                    }
                }
                Text(turn.content).foregroundStyle(RhetorixColors.textPrimary)
                if !isUser { AIDisclaimer(color: RhetorixColors.textTertiary) }
                HStack(spacing: 8) {
                    if let inputMode = turn.inputMode {
                        Label(store.t(inputMode.rawValue), systemImage: icon(for: inputMode))
                    }
                    if let seconds = turn.stageDurationSeconds {
                        Label(store.formatSeconds(seconds), systemImage: "timer")
                    }
                    if let provider = turn.provider {
                        Text("\(provider.rawValue) / \(turn.model ?? "")")
                    }
                }
                .font(.caption2)
                .foregroundStyle(RhetorixColors.textTertiary)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 16).fill(turn.role.color.opacity(0.18)))
            if !isUser { Spacer(minLength: 50) }
        }
    }

    private func icon(for mode: DebateInputMode) -> String {
        switch mode {
        case .text: "keyboard"
        case .voice: "mic.fill"
        case .ai: "sparkles"
        }
    }
}

struct DebateMemorySection: View {
    @EnvironmentObject private var store: AppStore
    var session: DebateSession

    var body: some View {
        Section(store.t("Round Memory")) {
            let timedTurns = session.turns.filter { $0.stageDurationSeconds != nil || $0.inputMode != nil }
            if timedTurns.isEmpty {
                Text(store.t("No timing memory recorded for this debate yet."))
                    .foregroundStyle(RhetorixColors.textSecondary)
            } else {
                ForEach(timedTurns) { turn in
                    let turnIndex = session.turns.firstIndex(where: { $0.id == turn.id }) ?? 0
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(store.stageTitle(for: session, turnIndex: turnIndex)) · \(store.speaker(turn.role))")
                            .font(.caption.bold())
                            .foregroundStyle(turn.role.color)
                        HStack {
                            if let inputMode = turn.inputMode {
                                Text(store.t(inputMode.rawValue))
                            }
                            if let seconds = turn.stageDurationSeconds {
                                Text(store.formatSeconds(seconds))
                            }
                            if let limit = turn.stageLimitSeconds {
                                Text("/ \(store.formatSeconds(limit))")
                            }
                        }
                        .font(.caption2)
                        .foregroundStyle(RhetorixColors.textTertiary)
                    }
                }
            }
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
                DebateMemorySection(session: session)
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
                        Text("\(store.debateMode(session.mode)) · \(session.turns.count) \(store.t("turns")) · \(session.turns.compactMap(\.stageDurationSeconds).isEmpty ? store.t("No timing") : store.t("Timed"))")
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
            VStack(alignment: .leading, spacing: 14) {
                Text(store.t("Tools support your debates. Live debate remains the main workflow."))
                    .font(.caption)
                    .foregroundStyle(RhetorixColors.textSecondary)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    CompactToolButton(title: store.t("Constructive Analysis"), icon: "magnifyingglass.circle.fill", accent: RhetorixColors.cyan) {
                        path.append(AppRoute.constructiveAnalysis)
                    }
                    .accessibilityIdentifier("tools.constructiveAnalysis")
                    CompactToolButton(title: store.t("Rebuttal Trainer"), icon: "timer", accent: RhetorixColors.amber) {
                        path.append(AppRoute.rebuttalTrainer)
                    }
                    CompactToolButton(title: store.t("Logic Fallacy Detector"), icon: "magnifyingglass", accent: RhetorixColors.green) {
                        path.append(AppRoute.fallacyDetector)
                    }
                    .accessibilityIdentifier("tools.fallacyDetector")
                    Link(destination: URL(string: "https://gptzero.me/hallucination-detector")!) {
                        VStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.headline)
                                .foregroundStyle(RhetorixColors.peach)
                            Text(store.t("AI Hallucination Detector"))
                                .font(.caption2.bold())
                                .foregroundStyle(RhetorixColors.textSecondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.76)
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundStyle(RhetorixColors.textTertiary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 62)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 14).fill(RhetorixColors.glass))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(RhetorixColors.peach.opacity(0.22), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
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
            Section(store.t("Voice")) {
                Toggle(store.t("Auto-read AI responses"), isOn: Binding(
                    get: { store.autoSpeakAI },
                    set: { store.setAutoSpeakAI($0) }
                ))
                Text(store.t("Uses the iPhone system voice. If speech is unavailable, debate text still works normally."))
                    .font(.caption)
                    .foregroundStyle(RhetorixColors.textSecondary)
            }
            .listRowBackground(RhetorixColors.glass)
            Section(store.t("Memory Profile")) {
                Picker(store.t("MBTI"), selection: Binding<MBTIType?>(
                    get: { store.userProfileMemory.mbti },
                    set: { store.setMBTI($0) }
                )) {
                    Text(store.t("Not set")).tag(Optional<MBTIType>.none)
                    ForEach(MBTIType.allCases) { type in
                        Text(type.rawValue).tag(Optional(type))
                    }
                }
                HStack {
                    Text(store.t("Evidence"))
                    Spacer()
                    Text("\(store.userProfileMemory.evidenceSessionCount) \(store.t("debates")) · \(store.userProfileMemory.evidenceTurnCount) \(store.t("turns"))")
                        .foregroundStyle(RhetorixColors.textSecondary)
                }
                if store.userProfileMemory.hasInferenceEvidence == false {
                    Text(store.t("Complete more debates to unlock reliable inferred profile signals."))
                        .font(.caption)
                        .foregroundStyle(RhetorixColors.textSecondary)
                }
                ForEach(store.userProfileMemory.styleSignals) { signal in
                    MemorySignalRow(label: store.t("Style"), signal: signal)
                }
                ForEach(store.userProfileMemory.valueSignals) { signal in
                    MemorySignalRow(label: store.t("Values"), signal: signal)
                }
                ForEach(store.userProfileMemory.weaknessSignals) { signal in
                    MemorySignalRow(label: store.t("Focus"), signal: signal)
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

struct MemorySignalRow: View {
    @EnvironmentObject private var store: AppStore
    var label: String
    var signal: MemorySignal

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(label)
                    .font(.caption.bold())
                    .foregroundStyle(RhetorixColors.amber)
                Spacer()
                Text("\(signal.confidence)%")
                    .font(.caption2)
                    .foregroundStyle(RhetorixColors.textTertiary)
            }
            Text(store.t(signal.title))
                .font(.subheadline.bold())
                .foregroundStyle(RhetorixColors.textPrimary)
            Text(store.memorySignalDetail(signal))
                .font(.caption)
                .foregroundStyle(RhetorixColors.textSecondary)
            if let firstEvidence = signal.evidence.first {
                Text("“\(firstEvidence)”")
                    .font(.caption2)
                    .foregroundStyle(RhetorixColors.textTertiary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ProviderConfigView: View {
    @EnvironmentObject private var store: AppStore
    var provider: AiProvider
    @State private var config: ProviderConfig
    @State private var showKey = false
    @State private var selectedModel = ""
    @State private var customModel = ""
    @State private var isTestingConnection = false
    @State private var connectionMessage: String?
    @State private var connectionSucceeded: Bool?

    private let otherModelTag = "__other_model__"

    init(provider: AiProvider) {
        self.provider = provider
        _config = State(initialValue: ProviderConfig(provider: provider, baseURL: provider.defaultBaseURL))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                GlassCard(accent: RhetorixColors.cyan) {
                    Toggle("\(store.t("Enable")) \(provider.rawValue)", isOn: $config.isEnabled)
                }

                GlassCard(accent: RhetorixColors.amber) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(store.t("API Configuration"))
                            .font(.headline)
                        HStack {
                            Group {
                                if showKey {
                                    TextField(store.t("API Key"), text: $config.apiKey)
                                } else {
                                    SecureField(store.t("API Key"), text: $config.apiKey)
                                }
                            }
                            .textContentType(.password)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            Button {
                                showKey.toggle()
                            } label: {
                                Image(systemName: showKey ? "eye.slash" : "eye")
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(12)
                        .background(RhetorixColors.glassStrong)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        Picker(store.t("Model"), selection: $selectedModel) {
                            ForEach(provider.modelChoices, id: \.self) { model in
                                Text(model).tag(model)
                            }
                            Text(store.t("Other")).tag(otherModelTag)
                        }
                        .pickerStyle(.menu)
                        .onChange(of: selectedModel) { _, newValue in
                            if newValue == otherModelTag {
                                config.modelName = customModel
                            } else {
                                config.modelName = newValue
                                customModel = ""
                            }
                        }

                        if selectedModel == otherModelTag {
                            TextField(store.t("Custom Model"), text: $customModel)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: customModel) { _, newValue in
                                    config.modelName = newValue
                                }
                        }

                        TextField(store.t("Base URL"), text: $config.baseURL)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .textFieldStyle(.roundedBorder)
                    }
                }

                GlassCard(accent: connectionSucceeded == true ? RhetorixColors.green : RhetorixColors.salmon) {
                    VStack(alignment: .leading, spacing: 10) {
                        Button {
                            Task { await testConnection() }
                        } label: {
                            HStack {
                                if isTestingConnection {
                                    ProgressView()
                                } else {
                                    Image(systemName: "antenna.radiowaves.left.and.right")
                                }
                                Text(store.t("Test Connection"))
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(isTestingConnection)

                        if let connectionMessage {
                            Text(connectionMessage)
                                .font(.caption)
                                .foregroundStyle(connectionSucceeded == true ? RhetorixColors.green : RhetorixColors.salmon)
                        } else {
                            Text(store.t("Test whether this provider and model can respond before saving."))
                                .font(.caption)
                                .foregroundStyle(RhetorixColors.textSecondary)
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            config = store.config(for: provider) ?? ProviderConfig(provider: provider, baseURL: provider.defaultBaseURL)
            syncModelSelection()
        }
        .navigationTitle(provider.rawValue)
        .safeAreaInset(edge: .bottom) {
            Button {
                normalizeModelBeforeSave()
                store.saveProvider(config)
                connectionMessage = store.t("Configuration saved.")
                connectionSucceeded = true
            } label: {
                Label(store.t("Save Configuration"), systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
        }
        .appScreen()
    }

    private func syncModelSelection() {
        let resolved = config.resolvedModel
        if provider.modelChoices.contains(resolved) {
            selectedModel = resolved
            customModel = ""
        } else {
            selectedModel = otherModelTag
            customModel = config.modelName
        }
    }

    private func normalizeModelBeforeSave() {
        if selectedModel == otherModelTag {
            config.modelName = customModel.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            config.modelName = selectedModel
        }
    }

    private func testConnection() async {
        normalizeModelBeforeSave()
        var testConfig = config
        testConfig.isEnabled = true
        testConfig.apiKey = testConfig.apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        testConfig.modelName = testConfig.modelName.trimmingCharacters(in: .whitespacesAndNewlines)
        testConfig.baseURL = testConfig.baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        isTestingConnection = true
        connectionMessage = nil
        connectionSucceeded = nil
        let result = await store.testProviderConnection(testConfig)
        switch result {
        case .success(let reply):
            connectionSucceeded = true
            connectionMessage = "\(store.t("Connection successful.")) \(reply)"
        case .failure(let error):
            connectionSucceeded = false
            connectionMessage = "\(store.t("Connection failed.")) \(error.localizedDescription)"
        }
        isTestingConnection = false
    }
}

@MainActor
final class AISpeechPlayer: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published private(set) var speakingTurnID: String?

    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String, turnID: String, usesChinese: Bool) {
        let cleaned = text
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleaned.isEmpty == false else { return }

        stop()
        configureAudioSession()

        let utterance = AVSpeechUtterance(string: cleaned)
        utterance.voice = preferredVoice(usesChinese: usesChinese)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        speakingTurnID = turnID
        synthesizer.speak(utterance)
    }

    func stop() {
        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }
        speakingTurnID = nil
    }

    private func preferredVoice(usesChinese: Bool) -> AVSpeechSynthesisVoice? {
        let primary = usesChinese ? "zh-CN" : "en-US"
        return AVSpeechSynthesisVoice(language: primary)
            ?? AVSpeechSynthesisVoice(language: usesChinese ? "zh-Hans" : "en-GB")
            ?? AVSpeechSynthesisVoice.speechVoices().first
    }

    private func configureAudioSession() {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true, options: [])
        } catch {
            // Speech synthesis can still work in many environments without an explicit audio session.
        }
        #endif
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.speakingTurnID = nil
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.speakingTurnID = nil
        }
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
        #if targetEnvironment(simulator)
        errorMessage = "Live recording requires a physical iPhone. Paste text to test in Simulator."
        isRecording = false
        return
        #else
        Task { await startRecording(localeIdentifier: localeIdentifier) }
        #endif
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
                            .accessibilityIdentifier("constructive.input")
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
                        .accessibilityIdentifier("constructive.analyze")
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
                            Text(store.t(error)).font(.caption).foregroundStyle(RhetorixColors.salmon)
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
                    Text(store.t("Detected claims"))
                        .font(.title3.bold())
                        .foregroundStyle(RhetorixColors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Text(store.t(issue.issueType))
                                    .font(.subheadline.bold())
                                    .foregroundStyle(accent)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(accent.opacity(0.16))
                                    .clipShape(Capsule())
                                Text(store.t("Tap to view rebuttal points"))
                                    .font(.caption)
                                    .foregroundStyle(RhetorixColors.textSecondary)
                            }
                            Text(issue.claim)
                                .font(.title3.bold())
                                .foregroundStyle(RhetorixColors.textPrimary)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                        Text(store.t(issue.severity))
                            .font(.caption.bold())
                            .foregroundStyle(RhetorixColors.textSecondary)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(RhetorixColors.glass)
                            .clipShape(Capsule())
                    }
                    if isExpanded {
                        if issue.quote.isEmpty == false {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(store.t("Original quote"))
                                    .font(.caption.bold())
                                    .foregroundStyle(RhetorixColors.textSecondary)
                                Text("\"\(issue.quote)\"")
                                    .font(.body)
                                    .foregroundStyle(RhetorixColors.amber)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RhetorixColors.glassStrong)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        if issue.explanation.isEmpty == false {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(store.t("Why this can be challenged"))
                                    .font(.subheadline.bold())
                                    .foregroundStyle(RhetorixColors.textPrimary)
                                Text(issue.explanation)
                                    .font(.body)
                                    .foregroundStyle(RhetorixColors.textSecondary)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RhetorixColors.glassStrong)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        if issue.rebuttalPoints.isEmpty == false {
                            Text(store.t("Rebuttable points"))
                                .font(.headline)
                                .foregroundStyle(RhetorixColors.textPrimary)
                            ForEach(issue.rebuttalPoints, id: \.self) { point in
                                RebuttalPointFrame(text: point, accent: accent)
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

struct RebuttalPointFrame: View {
    var text: String
    var accent: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "arrow.turn.down.right")
                .font(.body.weight(.semibold))
                .foregroundStyle(accent)
                .frame(width: 20)
            Text(text)
                .font(.body)
                .foregroundStyle(RhetorixColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RhetorixColors.glassStrong)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(accent.opacity(0.24), lineWidth: 1)
        )
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
                    .accessibilityIdentifier("fallacy.input")
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
                .accessibilityIdentifier("fallacy.analyze")
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
    @State private var topic: DebateTopic?
    @State private var provider: AiProvider = .openAI
    @State private var customTopicTitle = ""
    @State private var customTopicDetails = ""
    @State private var prompt = ""
    @State private var response = ""
    @State private var attempt: RebuttalAttempt?
    @State private var isGeneratingPrompt = false
    @State private var isScoring = false
    @State private var startedAt: Date?
    @State private var now = Date()

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                GlassCard(accent: RhetorixColors.cyan) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(store.t("Choose a topic before generating a practice argument."))
                            .font(.headline)
                            .foregroundStyle(RhetorixColors.textPrimary)
                        Picker(store.t("Topic"), selection: $topic) {
                            Text(store.t("Choose a Topic")).tag(Optional<DebateTopic>.none)
                            ForEach(store.topics) { Text(store.topicTitle($0)).tag(Optional($0)) }
                        }
                        Divider().overlay(RhetorixColors.textTertiary.opacity(0.35))
                        Text(store.t("Use a custom topic"))
                            .font(.subheadline.bold())
                            .foregroundStyle(RhetorixColors.textPrimary)
                        TextField(store.t("Topic title"), text: $customTopicTitle)
                            .textInputAutocapitalization(.sentences)
                            .autocorrectionDisabled(false)
                            .textFieldStyle(.roundedBorder)
                        TextField(store.t("Optional details"), text: $customTopicDetails)
                            .textInputAutocapitalization(.sentences)
                            .autocorrectionDisabled(false)
                            .textFieldStyle(.roundedBorder)
                        Button {
                            addCustomRebuttalTopic()
                        } label: {
                            Label(store.t("Add Custom Topic"), systemImage: "plus.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(customTopicTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        Picker(store.t("Provider"), selection: $provider) {
                            ForEach(AiProvider.allCases) { Text($0.rawValue).tag($0) }
                        }
                    }
                }

                Button {
                    Task { await generateArgument() }
                } label: {
                    HStack {
                        if isGeneratingPrompt {
                            ProgressView()
                        } else {
                            Image(systemName: "sparkles")
                        }
                        Text(isGeneratingPrompt ? store.t("Generating...") : store.t("Generate Argument"))
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(topic == nil || isGeneratingPrompt)

                if prompt.isEmpty == false {
                    if let startedAt {
                        GlassCard(accent: RhetorixColors.salmon) {
                            StageTimerView(limit: 150, startedAt: startedAt, now: now)
                        }
                    }
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
                    Button {
                        Task { await submitRebuttal() }
                    } label: {
                        HStack {
                            if isScoring {
                                ProgressView()
                            } else {
                                Image(systemName: "checkmark.seal.fill")
                            }
                            Text(isScoring ? store.t("Scoring...") : store.t("Submit Rebuttal"))
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isScoring || response.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                } else if topic != nil {
                    GlassCard(accent: RhetorixColors.amber) {
                        Text(store.t("Generate an opponent argument to start the 2.5-minute rebuttal timer."))
                            .font(.subheadline)
                            .foregroundStyle(RhetorixColors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
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
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            provider = store.preferredProvider
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { value in
            now = value
        }
        .appScreen()
    }

    private func generateArgument() async {
        guard let topic else { return }
        isGeneratingPrompt = true
        attempt = nil
        response = ""
        prompt = await store.generateRebuttalPrompt(topic: topic, side: .oppose, provider: provider)
        startedAt = prompt.isEmpty ? nil : Date()
        isGeneratingPrompt = false
    }

    private func addCustomRebuttalTopic() {
        guard let created = store.addCustomTopic(title: customTopicTitle, details: customTopicDetails) else { return }
        topic = created
        prompt = ""
        response = ""
        attempt = nil
        startedAt = nil
        customTopicTitle = ""
        customTopicDetails = ""
    }

    private func submitRebuttal() async {
        guard let topic else { return }
        isScoring = true
        attempt = await store.scoreRebuttal(topic: topic, prompt: prompt, response: response, provider: provider)
        isScoring = false
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
