import SwiftUI
import UIKit

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
                case .argumentGraphTopicSelection:
                    ArgumentGraphTopicSelectionView(path: $path)
                case .argumentGraph(let topic):
                    ArgumentGraphView(topic: topic)
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
                    FeatureCard(title: store.t("Argument Graph"), subtitle: "", icon: "point.3.connected.trianglepath.dotted", accent: RhetorixColors.cyan) {
                        path.append(AppRoute.argumentGraphTopicSelection)
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

struct ArgumentGraphTopicSelectionView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var path: NavigationPath
    @State private var search = ""

    private var filtered: [DebateTopic] {
        search.isEmpty ? store.topics : store.topics.filter {
            $0.title.localizedCaseInsensitiveContains(search) ||
            store.topicTitle($0).localizedCaseInsensitiveContains(search) ||
            $0.category.localizedCaseInsensitiveContains(search) ||
            store.category($0.category).localizedCaseInsensitiveContains(search) ||
            $0.details.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        List {
            Section {
                TextField(store.t("Search topics..."), text: $search)
            }
            .listRowBackground(RhetorixColors.glass)

            Section(store.t("Choose a Topic")) {
                ForEach(filtered) { topic in
                    Button {
                        path.append(AppRoute.argumentGraph(topic))
                    } label: {
                        TopicRow(topic: topic, debateCount: store.debateCount(for: topic))
                    }
                    .listRowBackground(RhetorixColors.glass)
                }
            }
        }
        .navigationTitle(store.t("Graph Topic"))
        .toolbar {
            Button(store.t("Add Topic")) {
                let topic = DebateTopic(title: store.t("Custom graph topic"), category: store.t("Custom"), details: store.t("Edit this topic in a future build."))
                store.topics.insert(topic, at: 0)
                path.append(AppRoute.argumentGraph(topic))
            }
        }
        .appScreen()
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
                            ForEach(session.turns) { turn in
                                DebateBubble(turn: turn)
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
                Button {
                    let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
                    input = ""
                    Task { await store.sendUserTurn(sessionID: sessionID, text: text) }
                } label: {
                    Image(systemName: "arrow.up.circle.fill").font(.title2)
                }
                .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || store.isWorking)
            }
            .padding()
            .background(RhetorixColors.backgroundDeep)
        }
        .toolbar {
            Button(store.t("AI Turn")) { Task { await store.advanceAIDebate(sessionID: sessionID) } }
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
                Text("\(session.turns.filter { $0.role == .support || $0.role == .user }.count)").font(.title.bold()).foregroundStyle(RhetorixColors.green)
                Text(store.t("Support"))
                Spacer()
                Text("\(store.t("Turn")) \(session.turns.count) / 12").font(.caption).foregroundStyle(RhetorixColors.textSecondary)
                Spacer()
                Text(store.t("Oppose"))
                Text("\(session.turns.filter { $0.role == .oppose }.count)").font(.title.bold()).foregroundStyle(RhetorixColors.salmon)
            }
        }
    }
}

struct DebateBubble: View {
    @EnvironmentObject private var store: AppStore
    var turn: DebateTurn
    var isUser: Bool { turn.role == .user }
    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 50) }
            VStack(alignment: .leading, spacing: 6) {
                Text(store.speaker(turn.role)).font(.caption.bold()).foregroundStyle(turn.role.color)
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
                FeatureCard(title: store.t("Argument Relationship Graph"), subtitle: store.t("Map claims and rebuttals"), icon: "point.3.connected.trianglepath.dotted", accent: RhetorixColors.cyan) {
                    path.append(AppRoute.argumentGraphTopicSelection)
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

struct ArgumentGraphView: View {
    @EnvironmentObject private var store: AppStore
    var topic: DebateTopic
    @State private var provider: AiProvider = .openAI
    @State private var graph: ArgumentGraph?
    @State private var selected: GraphNode?
    @State private var mode: BattleMapMode = .prep
    @State private var nodeBriefs: [String: String] = [:]
    @State private var expandingNodeID: String?

    var body: some View {
        ZStack {
            AppBackdrop()
            VStack {
                if let currentGraph = graph {
                    Picker(store.t("Map Mode"), selection: $mode) {
                        ForEach(BattleMapMode.allCases) { item in
                            Text(store.t(item.rawValue)).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    GraphCanvas(
                        graph: Binding(
                            get: { graph ?? currentGraph },
                            set: { graph = $0 }
                        ),
                        mode: mode,
                        selected: $selected
                    )
                    if let selected {
                        GlassCard(accent: accent(for: selected.type)) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(selected.title).font(.headline)
                                    if selected.isKey {
                                        Label(store.t("Key"), systemImage: "star.fill")
                                            .font(.caption.bold())
                                            .foregroundStyle(RhetorixColors.amber)
                                    }
                                    Spacer()
                                    Text(selected.type.rawValue.capitalized)
                                        .font(.caption2.bold())
                                        .foregroundStyle(RhetorixColors.textSecondary)
                                }
                                Text(selected.detail).font(.caption).foregroundStyle(RhetorixColors.textSecondary)
                                if expandingNodeID == selected.id {
                                    HStack(spacing: 8) {
                                        ProgressView()
                                        Text(store.t("Preparing node text..."))
                                            .font(.caption)
                                            .foregroundStyle(RhetorixColors.textSecondary)
                                    }
                                }
                                if let brief = nodeBriefs[selected.id] {
                                    Divider().overlay(.white.opacity(0.14))
                                    Text(store.t("AI Prep Text"))
                                        .font(.caption.bold())
                                        .foregroundStyle(RhetorixColors.textPrimary)
                                    Text(brief)
                                        .font(.caption)
                                        .foregroundStyle(RhetorixColors.textSecondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                if selected.type == .attack || selected.type == .defense || selected.type == .weighing || selected.type == .clash {
                                    Text(store.t(mode.tip))
                                        .font(.caption2)
                                        .foregroundStyle(RhetorixColors.amber)
                                }
                                Button(store.t("Refresh AI Text")) {
                                    requestNodeBrief(force: true)
                                }
                                .font(.caption.bold())
                                .buttonStyle(.bordered)
                                .disabled(expandingNodeID == selected.id)
                                AIDisclaimer()
                            }
                        }
                        .padding()
                    } else {
                        AIDisclaimer().padding()
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "point.3.connected.trianglepath.dotted").font(.largeTitle)
                        Text(store.t("No graph yet")).font(.headline)
                        Picker(store.t("Provider"), selection: $provider) {
                            ForEach(AiProvider.allCases) { Text($0.rawValue).tag($0) }
                        }
                        Button(store.t("Generate with AI")) {
                            Task { graph = await store.generateGraph(topic: topic, provider: provider) }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            if store.isWorking && graph == nil {
                ProgressView(store.t("Generating..."))
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .navigationTitle(store.topicTitle(topic))
        .onAppear {
            provider = store.preferredProvider
        }
        .onChange(of: selected?.id) { _, _ in
            requestNodeBrief(force: false)
        }
    }

    private func accent(for type: GraphNodeType) -> Color {
        switch type {
        case .oppose, .attack: RhetorixColors.salmon
        case .weighing, .clash, .impact: RhetorixColors.amber
        case .defense, .rebuttal: RhetorixColors.peach
        case .support: RhetorixColors.green
        default: RhetorixColors.cyan
        }
    }

    private func requestNodeBrief(force: Bool) {
        guard let node = selected else { return }
        if force == false, nodeBriefs[node.id] != nil { return }
        let nodeID = node.id
        expandingNodeID = nodeID
        Task { @MainActor in
            let brief = await store.expandGraphNode(topic: topic, node: node, provider: provider)
            if brief.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false, selected?.id == nodeID {
                nodeBriefs[nodeID] = brief
            }
            if expandingNodeID == nodeID {
                expandingNodeID = nil
            }
        }
    }
}

enum BattleMapMode: String, CaseIterable, Identifiable {
    case prep = "Prep"
    case clash = "Clash"
    case drill = "Drill"

    var id: String { rawValue }

    var tip: String {
        switch self {
        case .prep: "Use this node to build your constructive speech."
        case .clash: "Use this node to compare which side wins the debate."
        case .drill: "Practice answering this attack out loud before the round."
        }
    }
}

struct GraphCanvas: View {
    @Binding var graph: ArgumentGraph
    var mode: BattleMapMode
    @Binding var selected: GraphNode?
    @State private var dragOrigins: [String: CGPoint] = [:]

    private var visibleNodes: [GraphNode] {
        switch mode {
        case .prep:
            graph.nodes
        case .clash:
            graph.nodes.filter { $0.type == .topic || $0.type == .clash || $0.type == .weighing || $0.type == .impact || $0.isKey }
        case .drill:
            graph.nodes.filter { $0.type == .topic || $0.type == .attack || $0.type == .defense || $0.type == .rebuttal || $0.isKey }
        }
    }

    private var visibleNodeIDs: Set<String> {
        Set(visibleNodes.map(\.id))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(graph.edges) { edge in
                    if visibleNodeIDs.contains(edge.from), visibleNodeIDs.contains(edge.to),
                       let from = graph.nodes.first(where: { $0.id == edge.from }), let to = graph.nodes.first(where: { $0.id == edge.to }) {
                        Path { path in
                            path.move(to: point(from, geo))
                            path.addLine(to: point(to, geo))
                        }
                        .stroke(edgeColor(edge.relation), lineWidth: edge.relation == "refutes" ? 2.4 : 1.8)
                    }
                }
                ForEach(visibleNodes) { node in
                    nodeView(node)
                    .position(point(node, geo))
                    .onTapGesture {
                        selected = currentNode(node.id) ?? node
                    }
                    .gesture(dragGesture(for: node, in: geo))
                }
            }
        }
        .frame(minHeight: 520)
    }

    private func point(_ node: GraphNode, _ geo: GeometryProxy) -> CGPoint {
        let scale = graphScale(geo)
        return CGPoint(x: geo.size.width / 2 + CGFloat(node.x) * scale, y: geo.size.height / 2 + CGFloat(node.y) * scale)
    }

    private func graphScale(_ geo: GeometryProxy) -> CGFloat {
        min(1, max(0.78, min(geo.size.width / 390, geo.size.height / 640)))
    }

    private func nodeView(_ node: GraphNode) -> some View {
        VStack(spacing: 3) {
            if node.isKey {
                Image(systemName: "star.fill")
                    .font(.caption2.bold())
                    .foregroundStyle(RhetorixColors.amber.opacity(0.9))
            }
            Text(node.title)
                .font(.system(size: node.isKey ? 12 : 11, weight: .bold))
                .lineLimit(2)
                .minimumScaleFactor(0.68)
                .multilineTextAlignment(.center)
            Text(shortLabel(node.type))
                .font(.system(size: 7.5, weight: .bold))
                .foregroundStyle(.white.opacity(0.68))
        }
        .frame(width: node.isKey ? 104 : 92, height: node.isKey ? 66 : 58)
        .background(
            RoundedRectangle(cornerRadius: node.isKey ? 16 : 14)
                .fill(color(node.type).opacity(node.isKey ? 0.76 : 0.62))
        )
        .overlay(
            RoundedRectangle(cornerRadius: node.isKey ? 16 : 14)
                .stroke(node.isKey ? RhetorixColors.amber.opacity(0.72) : .white.opacity(0.18), lineWidth: node.isKey ? 1.8 : 1)
        )
        .shadow(color: node.isKey ? RhetorixColors.amber.opacity(0.16) : .clear, radius: 8)
        .foregroundStyle(.white)
        .contentShape(RoundedRectangle(cornerRadius: node.isKey ? 16 : 14))
    }

    private func dragGesture(for node: GraphNode, in geo: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                guard let index = graph.nodes.firstIndex(where: { $0.id == node.id }) else { return }
                let origin = dragOrigins[node.id] ?? CGPoint(x: graph.nodes[index].x, y: graph.nodes[index].y)
                dragOrigins[node.id] = origin
                let scale = graphScale(geo)
                graph.nodes[index].x = Double(origin.x + value.translation.width / scale)
                graph.nodes[index].y = Double(origin.y + value.translation.height / scale)
                selected = graph.nodes[index]
            }
            .onEnded { _ in
                dragOrigins[node.id] = nil
            }
    }

    private func currentNode(_ id: String) -> GraphNode? {
        graph.nodes.first { $0.id == id }
    }

    private func edgeColor(_ relation: String) -> Color {
        switch relation {
        case "refutes": RhetorixColors.salmon.opacity(0.72)
        case "qualifies", "depends_on": RhetorixColors.amber.opacity(0.66)
        default: RhetorixColors.green.opacity(0.66)
        }
    }

    private func shortLabel(_ type: GraphNodeType) -> String {
        switch type {
        case .topic: "TOPIC"
        case .support: "CASE"
        case .oppose: "CASE"
        case .evidence: "EVID"
        case .warrant: "WHY"
        case .impact: "IMPACT"
        case .attack: "ATTACK"
        case .defense: "DEFENSE"
        case .weighing: "WEIGH"
        case .clash: "CLASH"
        case .rebuttal: "REBUT"
        }
    }

    private func color(_ type: GraphNodeType) -> Color {
        switch type {
        case .topic: RhetorixColors.graphTopic
        case .support: RhetorixColors.graphSupport
        case .oppose: RhetorixColors.graphOppose
        case .evidence: RhetorixColors.graphEvidence
        case .warrant: RhetorixColors.graphWarrant
        case .impact: RhetorixColors.graphEvidence
        case .attack: RhetorixColors.graphOppose
        case .defense: RhetorixColors.graphDefense
        case .weighing: RhetorixColors.graphEvidence
        case .clash: RhetorixColors.graphDefense
        case .rebuttal: RhetorixColors.graphDefense
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
