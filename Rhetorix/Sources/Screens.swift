import SwiftUI
import UIKit

struct RootView: View {
    @EnvironmentObject private var store: AppStore
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            TabView {
                HomeView(path: $path)
                    .tabItem { Label("Home", systemImage: "house.fill") }
                HistoryView(path: $path)
                    .tabItem { Label("History", systemImage: "clock") }
                ToolsView(path: $path)
                    .tabItem { Label("Tools", systemImage: "square.grid.2x2") }
                SettingsView(path: $path)
                    .tabItem { Label("Settings", systemImage: "gearshape") }
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
            Button("OK", role: .cancel) { store.activeError = nil }
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
                        Text("Challenge intelligence. Extend ideas.")
                            .font(.headline)
                            .foregroundStyle(RhetorixColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }

                HStack(spacing: 10) {
                    StatCard(value: "\(store.debateCount)", label: "Debates", icon: "trophy")
                    StatCard(value: "\(store.winRate)%", label: "Win Rate", icon: "gearshape")
                    StatCard(value: "\(store.winStreak)", label: "Win Streak", icon: "flame.fill")
                }

                GlassCard(accent: RhetorixColors.peach) {
                    HStack {
                        Image(systemName: "heart.fill").foregroundStyle(RhetorixColors.peach)
                        VStack(alignment: .leading) {
                            Text("Support Development").font(.headline)
                            Text("All features are free. Donations help keep Rhetorix independent.")
                                .font(.caption)
                                .foregroundStyle(RhetorixColors.textSecondary)
                        }
                        Spacer()
                        Button("Donate") { path.append(AppRoute.donation) }
                            .buttonStyle(.bordered)
                    }
                }

                SectionTitle(text: "Quick Actions")
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    FeatureCard(title: "New Debate", subtitle: "Start a debate with AI", icon: "message.fill", accent: RhetorixColors.cyan) {
                        path.append(AppRoute.topicSelection)
                    }
                    FeatureCard(title: "Face-to-Face", subtitle: "Debate on one device", icon: "person.2.fill", accent: RhetorixColors.amber) {
                        path.append(AppRoute.setup(store.topics.first ?? AppStore.defaultTopics[0]))
                    }
                    FeatureCard(title: "History", subtitle: "Review debates", icon: "clock.fill", accent: RhetorixColors.green) {}
                    FeatureCard(title: "Fallacy Detector", subtitle: "Analyze reasoning", icon: "magnifyingglass", accent: RhetorixColors.green) {
                        path.append(AppRoute.fallacyDetector)
                    }
                }

                SectionTitle(text: "Preparation Tools")
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    FeatureCard(title: "Argument Graph", subtitle: "", icon: "point.3.connected.trianglepath.dotted", accent: RhetorixColors.cyan) {
                        path.append(AppRoute.argumentGraphTopicSelection)
                    }
                    FeatureCard(title: "Rebuttal", subtitle: "", icon: "timer", accent: RhetorixColors.amber) {
                        path.append(AppRoute.rebuttalTrainer)
                    }
                    FeatureCard(title: "Fallacy", subtitle: "", icon: "magnifyingglass", accent: RhetorixColors.green) {
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
        search.isEmpty ? store.topics : store.topics.filter { $0.title.localizedCaseInsensitiveContains(search) || $0.category.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        List {
            Section {
                TextField("Search topics...", text: $search)
            }
            .listRowBackground(RhetorixColors.glass)

            Section("Trending") {
                ForEach(filtered) { topic in
                    Button { path.append(AppRoute.setup(topic)) } label: {
                        TopicRow(topic: topic, debateCount: store.debateCount(for: topic))
                    }
                    .listRowBackground(RhetorixColors.glass)
                }
            }
        }
        .navigationTitle("Select Topic")
        .toolbar {
            Button("Add Topic") {
                let topic = DebateTopic(title: "Custom debate topic", category: "Custom", details: "Edit this topic in a future build.")
                store.topics.insert(topic, at: 0)
                path.append(AppRoute.setup(topic))
            }
        }
        .appScreen()
    }
}

struct TopicRow: View {
    var topic: DebateTopic
    var debateCount: Int
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(topic.title).foregroundStyle(RhetorixColors.textPrimary)
                Text("\(topic.category) · \(debateCount) \(debateCount == 1 ? "debate" : "debates")")
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
            $0.category.localizedCaseInsensitiveContains(search) ||
            $0.details.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        List {
            Section {
                TextField("Search topics...", text: $search)
            }
            .listRowBackground(RhetorixColors.glass)

            Section("Choose a Topic") {
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
        .navigationTitle("Graph Topic")
        .toolbar {
            Button("Add Topic") {
                let topic = DebateTopic(title: "Custom graph topic", category: "Custom", details: "Edit this topic in a future build.")
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
                        Text(topic.title).font(.headline)
                        Text(topic.details).font(.caption).foregroundStyle(RhetorixColors.textSecondary)
                    }
                }
                Picker("Mode", selection: $mode) {
                    ForEach(DebateMode.allCases) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented)
                Picker("Format", selection: $format) {
                    ForEach(DebateFormat.allCases) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented)
                Picker("Difficulty", selection: $difficulty) {
                    ForEach(DebateDifficulty.allCases) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented)
                Picker("Your Position", selection: $side) {
                    ForEach(DebateSide.allCases) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented)
                Picker("AI Provider", selection: $provider) {
                    ForEach(AiProvider.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu)
                Button {
                    let session = store.createSession(topic: topic, mode: mode, format: format, difficulty: difficulty, side: side, provider: provider)
                    path.append(AppRoute.debate(session.id))
                } label: {
                    Text("Start Debate").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Debate Setup")
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
                                ProgressView("Thinking...")
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
                TextField("Type your argument...", text: $input, axis: .vertical)
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
            Button("AI Turn") { Task { await store.advanceAIDebate(sessionID: sessionID) } }
            Button("End") { Task { await store.endAndJudge(sessionID: sessionID); path.append(AppRoute.result(sessionID)) } }
        }
        .navigationTitle(session?.topic.title ?? "Debate")
        .appScreen()
    }
}

struct DebateStatus: View {
    var session: DebateSession
    var body: some View {
        GlassCard(accent: RhetorixColors.amber) {
            HStack {
                Text("\(session.turns.filter { $0.role == .support || $0.role == .user }.count)").font(.title.bold()).foregroundStyle(RhetorixColors.green)
                Text("Support")
                Spacer()
                Text("Turn \(session.turns.count) / 12").font(.caption).foregroundStyle(RhetorixColors.textSecondary)
                Spacer()
                Text("Oppose")
                Text("\(session.turns.filter { $0.role == .oppose }.count)").font(.title.bold()).foregroundStyle(RhetorixColors.salmon)
            }
        }
    }
}

struct DebateBubble: View {
    var turn: DebateTurn
    var isUser: Bool { turn.role == .user }
    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 50) }
            VStack(alignment: .leading, spacing: 6) {
                Text(turn.role.rawValue).font(.caption.bold()).foregroundStyle(turn.role.color)
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
                        Text(session.topic.title).font(.headline).multilineTextAlignment(.center)
                        Text("Winner").font(.caption).foregroundStyle(RhetorixColors.textSecondary)
                        Text(session.result?.winner?.rawValue ?? "N/A").font(.largeTitle.bold()).foregroundStyle(RhetorixColors.green)
                        Text(session.result?.summary ?? "No judgment yet.")
                            .multilineTextAlignment(.center)
                        AIDisclaimer()
                    }
                }
                .listRowBackground(Color.clear)
                Section("Transcript") {
                    ForEach(session.turns) { turn in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(turn.role.rawValue).font(.caption.bold()).foregroundStyle(turn.role.color)
                            Text(turn.content)
                            if turn.role != .user { AIDisclaimer() }
                        }
                    }
                }
            }
        }
        .navigationTitle("Debate Result")
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
                        Text(session.topic.title).foregroundStyle(RhetorixColors.textPrimary)
                        Text("\(session.mode.rawValue) · \(session.turns.count) turns")
                            .font(.caption)
                            .foregroundStyle(RhetorixColors.textSecondary)
                    }
                }
                .listRowBackground(RhetorixColors.glass)
            }
            ForEach(store.rebuttalAttempts) { attempt in
                VStack(alignment: .leading) {
                    Text("Rebuttal Training").foregroundStyle(RhetorixColors.textPrimary)
                    Text("\(attempt.topic.title) · Score \(attempt.score)")
                        .font(.caption)
                        .foregroundStyle(RhetorixColors.textSecondary)
                }
                .listRowBackground(RhetorixColors.glass)
            }
        }
        .navigationTitle("History")
        .appScreen()
    }
}

struct ToolsView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var path: NavigationPath
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                FeatureCard(title: "Argument Relationship Graph", subtitle: "Map claims and rebuttals", icon: "point.3.connected.trianglepath.dotted", accent: RhetorixColors.cyan) {
                    path.append(AppRoute.argumentGraphTopicSelection)
                }
                FeatureCard(title: "Rebuttal Trainer", subtitle: "Timed rebuttal practice", icon: "timer", accent: RhetorixColors.amber) {
                    path.append(AppRoute.rebuttalTrainer)
                }
                FeatureCard(title: "Logic Fallacy Detector", subtitle: "Find weak reasoning", icon: "magnifyingglass", accent: RhetorixColors.green) {
                    path.append(AppRoute.fallacyDetector)
                }
                Link(destination: URL(string: "https://gptzero.me/hallucination-detector")!) {
                    GlassCard(accent: RhetorixColors.peach) {
                        HStack {
                            Image(systemName: "sparkles").foregroundStyle(RhetorixColors.peach)
                            VStack(alignment: .leading) {
                                Text("AI Hallucination Detector")
                                Text("Open GPTZero hallucination detector")
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
        .navigationTitle("Tools")
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
                    Label("Support Development", systemImage: "heart.fill")
                }
            }
            .listRowBackground(RhetorixColors.glass)
            Section("AI Providers") {
                ForEach(AiProvider.allCases) { provider in
                    Button { path.append(AppRoute.provider(provider)) } label: {
                        HStack {
                            Text(provider.rawValue)
                            Spacer()
                            Text(store.config(for: provider)?.isEnabled == true ? "Enabled" : "Disabled")
                                .font(.caption)
                                .foregroundStyle(store.config(for: provider)?.isEnabled == true ? RhetorixColors.green : RhetorixColors.salmon)
                        }
                    }
                }
            }
            .listRowBackground(RhetorixColors.glass)
        }
        .navigationTitle("Settings")
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
            Toggle("Enable \(provider.rawValue)", isOn: $config.isEnabled)
            TextField("API Key", text: $config.apiKey)
                .textContentType(.password)
            TextField("Model", text: $config.modelName)
            TextField("Base URL", text: $config.baseURL)
            Button("Save Configuration") {
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

    var body: some View {
        ZStack {
            AppBackdrop()
            VStack {
                if let graph {
                    GraphCanvas(graph: graph, selected: $selected)
                    if let selected {
                        GlassCard(accent: selected.type == .oppose ? RhetorixColors.salmon : RhetorixColors.cyan) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(selected.title).font(.headline)
                                    if selected.isKey {
                                        Label("Key", systemImage: "star.fill")
                                            .font(.caption.bold())
                                            .foregroundStyle(RhetorixColors.amber)
                                    }
                                }
                                Text(selected.detail).font(.caption).foregroundStyle(RhetorixColors.textSecondary)
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
                        Text("No graph yet").font(.headline)
                        Picker("Provider", selection: $provider) {
                            ForEach(AiProvider.allCases) { Text($0.rawValue).tag($0) }
                        }
                        Button("Generate with AI") {
                            Task { graph = await store.generateGraph(topic: topic, provider: provider) }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            if store.isWorking { ProgressView("Generating...").padding().background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 12)) }
        }
        .navigationTitle(topic.title)
        .onAppear {
            provider = store.preferredProvider
        }
    }
}

struct GraphCanvas: View {
    var graph: ArgumentGraph
    @Binding var selected: GraphNode?
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(graph.edges) { edge in
                    if let from = graph.nodes.first(where: { $0.id == edge.from }), let to = graph.nodes.first(where: { $0.id == edge.to }) {
                        Path { path in
                            path.move(to: point(from, geo))
                            path.addLine(to: point(to, geo))
                        }
                        .stroke(edge.relation == "refutes" ? RhetorixColors.salmon : RhetorixColors.green, lineWidth: 2)
                    }
                }
                ForEach(graph.nodes) { node in
                    Button { selected = node } label: {
                        VStack(spacing: 3) {
                            if node.isKey {
                                Image(systemName: "star.fill")
                                    .font(.caption2.bold())
                                    .foregroundStyle(RhetorixColors.amber)
                            }
                            Text(node.title)
                                .font(.caption.bold())
                                .lineLimit(2)
                                .minimumScaleFactor(0.7)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: node.isKey ? 116 : 102, height: node.isKey ? 78 : 68)
                        .background(
                            RoundedRectangle(cornerRadius: node.isKey ? 18 : 16)
                                .fill(color(node.type).opacity(node.isKey ? 0.94 : 0.78))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: node.isKey ? 18 : 16)
                                .stroke(node.isKey ? RhetorixColors.amber : .white.opacity(0.25), lineWidth: node.isKey ? 2.5 : 1)
                        )
                        .shadow(color: node.isKey ? RhetorixColors.amber.opacity(0.35) : .clear, radius: 12)
                        .foregroundStyle(.white)
                    }
                    .position(point(node, geo))
                }
            }
        }
    }

    private func point(_ node: GraphNode, _ geo: GeometryProxy) -> CGPoint {
        CGPoint(x: geo.size.width / 2 + node.x, y: geo.size.height / 2 + node.y)
    }

    private func color(_ type: GraphNodeType) -> Color {
        switch type {
        case .topic: RhetorixColors.cyan
        case .support: RhetorixColors.green
        case .oppose: RhetorixColors.salmon
        case .evidence: RhetorixColors.amber
        case .rebuttal: RhetorixColors.peach
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
                Picker("Provider", selection: $provider) {
                    ForEach(AiProvider.allCases) { Text($0.rawValue).tag($0) }
                }
                Button("Analyze for Fallacies") {
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
                            Text("Analyzing fallacies...")
                                .font(.subheadline)
                                .foregroundStyle(RhetorixColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else if hasAnalyzed && results.isEmpty {
                    GlassCard(accent: RhetorixColors.green) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("未检出")
                                .font(.headline)
                            Text("No logical fallacies were detected in this text.")
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
        .navigationTitle("Fallacy Detector")
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
                Picker("Topic", selection: $topic) {
                    ForEach(store.topics) { Text($0.title).tag($0) }
                }
                Picker("Provider", selection: $provider) {
                    ForEach(AiProvider.allCases) { Text($0.rawValue).tag($0) }
                }
                Button("Generate Argument") {
                    Task { prompt = await store.generateRebuttalPrompt(topic: topic, side: .oppose, provider: provider) }
                }
                .buttonStyle(.borderedProminent)
                if prompt.isEmpty == false {
                    GlassCard(accent: RhetorixColors.amber) {
                        VStack(alignment: .leading) {
                            Text("Argument to resist").font(.headline)
                            Text(prompt)
                            AIDisclaimer()
                        }
                    }
                    TextEditor(text: $response)
                        .frame(height: 160)
                        .scrollContentBackground(.hidden)
                        .background(RhetorixColors.glass)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    Button("Submit Rebuttal") {
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
        .navigationTitle("Rebuttal Trainer")
        .onAppear {
            provider = store.preferredProvider
        }
        .appScreen()
    }
}

struct DonationView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(systemName: "heart.fill").font(.system(size: 64)).foregroundStyle(RhetorixColors.peach)
                Text("Thank you for supporting Rhetorix").font(.title2.bold()).multilineTextAlignment(.center)
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
                        Text("Scan with WeChat or Alipay")
                            .font(.caption)
                            .foregroundStyle(RhetorixColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                Text("All features are free. Donations help maintain the app and add new features.")
                    .font(.footnote)
                    .foregroundStyle(RhetorixColors.textSecondary)
            }
            .padding()
        }
        .navigationTitle("Support Development")
        .appScreen()
    }
}
