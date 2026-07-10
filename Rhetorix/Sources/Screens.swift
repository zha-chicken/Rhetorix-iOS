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
                HomeView(path: $path)
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
                case .guidedPractice:
                    GuidedPracticeView(path: $path)
                case .topicSelection:
                    TopicSelectionView(path: $path)
                case .setup(let topic):
                    DebateSetupView(path: $path, topic: topic)
                case .debate(let id):
                    DebateView(path: $path, sessionID: id)
                case .selfAssessment(let id):
                    DebateSelfAssessmentView(path: $path, sessionID: id)
                case .result(let id):
                    ResultView(path: $path, sessionID: id)
                case .retrySpeech(let sessionID, let turnID):
                    SpeechRetryView(sessionID: sessionID, turnID: turnID)
                case .memoryProfile:
                    MemoryProfileDetailView(path: $path)
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
        .sheet(isPresented: Binding(get: { store.shouldAskLearningProfile }, set: { _ in })) {
            LearningOnboardingView()
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

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Text("Rhetorix")
                        .font(.largeTitle.bold())
                    Spacer()
                }

                GlassCard(accent: RhetorixColors.cyan, padding: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Label(store.t("Today's Practice"), systemImage: store.dailyPracticeSkill.icon)
                                .font(.caption.bold())
                                .foregroundStyle(RhetorixColors.cyan)
                            Spacer()
                            Text("\(store.t("Step")) \((AppStore.skillPath.firstIndex(of: store.dailyPracticeSkill) ?? 0) + 1) / \(AppStore.skillPath.count)")
                                .font(.caption.bold())
                                .foregroundStyle(RhetorixColors.textTertiary)
                        }
                        Text(store.t(store.dailyPracticeSkill.rawValue))
                            .font(.title2.bold())
                            .foregroundStyle(RhetorixColors.textPrimary)
                        Text(store.t(store.dailyPracticeSkill.lessonSummary))
                            .font(.subheadline)
                            .foregroundStyle(RhetorixColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                        Button {
                            path.append(AppRoute.guidedPractice)
                        } label: {
                            PrimaryActionLabel(
                                title: store.t("Start Guided Practice"),
                                detail: "\(store.t(store.dailyPracticeSkill.rawValue)) · \(store.learningProfile.practiceDuration.rawValue) \(store.t("min"))",
                                systemImage: "target"
                            )
                        }
                        .buttonStyle(.rhetorixPrimary)
                        .accessibilityIdentifier("home.todayPractice")
                        .padding(.top, 4)
                        Button {
                            path.append(AppRoute.topicSelection)
                        } label: {
                            Label(store.t("Start Open Debate"), systemImage: "mic.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("home.startVoiceDebate")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                HStack(spacing: 10) {
                    StatCard(value: "\(store.debateCount)", label: store.t("Debates"), icon: "trophy")
                    StatCard(value: "\(store.winRate)%", label: store.t("Win Rate"), icon: "gearshape")
                    StatCard(value: "\(store.winStreak)", label: store.t("Win Streak"), icon: "flame.fill")
                }

                MemoryInsightCard(path: $path)

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
                    Button {
                        path.append(AppRoute.memoryProfile)
                    } label: {
                        Text(store.t("Details"))
                            .font(.caption.bold())
                    }
                    .buttonStyle(.plain)
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
                                Text("\(store.t("Focus")): \(recommendation.focus)")
                                    .font(.caption2.bold())
                                    .foregroundStyle(RhetorixColors.cyan)
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

struct LearningOnboardingView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var goal: LearningGoal = .speakingConfidence
    @State private var experience: DebateExperience = .beginner
    @State private var duration: PracticeDuration = .tenMinutes

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(store.t("What do you want to improve?"))
                    .font(.title.bold())
                    .foregroundStyle(RhetorixColors.textPrimary)
                Text(store.t("Rhetorix will build a short practice plan around your goal. You can change these choices in Settings."))
                    .font(.subheadline)
                    .foregroundStyle(RhetorixColors.textSecondary)

                GlassCard(accent: RhetorixColors.cyan) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(store.t("Primary goal")).font(.headline)
                        RhetorixChoiceList(
                            options: LearningGoal.allCases.map { ($0, store.t($0.rawValue)) },
                            selection: $goal
                        )
                    }
                }

                GlassCard(accent: RhetorixColors.amber) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(store.t("Experience level")).font(.headline)
                        RhetorixChoiceChips(
                            title: nil,
                            options: DebateExperience.allCases.map { ($0, store.t($0.rawValue)) },
                            selection: $experience
                        )

                        Text(store.t("Practice length")).font(.headline)
                        RhetorixChoiceChips(
                            title: nil,
                            options: PracticeDuration.allCases.map { ($0, "\($0.rawValue) \(store.t("min"))") },
                            selection: $duration
                        )
                    }
                }

                Button {
                    store.completeLearningOnboarding(goal: goal, experience: experience, practiceDuration: duration)
                    dismiss()
                } label: {
                    PrimaryActionLabel(
                        title: store.t("Build My Practice Plan"),
                        detail: "\(store.t(goal.rawValue)) · \(duration.rawValue) \(store.t("min"))",
                        systemImage: "sparkles"
                    )
                }
                .buttonStyle(.rhetorixPrimary)
                .accessibilityIdentifier("onboarding.continue")

                Text(store.t("Your learning profile and debate history stay on this device."))
                    .font(.caption)
                    .foregroundStyle(RhetorixColors.textTertiary)
            }
            .padding(24)
        }
        .appScreen()
    }
}

struct GuidedPracticeView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var path: NavigationPath
    @State private var selectedSkill: DebateSkill?

    private var skill: DebateSkill { selectedSkill ?? store.dailyPracticeSkill }
    private var topic: DebateTopic? { store.dailyPracticeTopic(for: skill) }
    private var difficulty: DebateDifficulty {
        switch store.learningProfile.experience {
        case .beginner: .easy
        case .intermediate: .medium
        case .advanced: .hard
        }
    }

    private var debateMinutes: Int { store.learningProfile.practiceDuration.rawValue }
    private var totalMinutes: Int { debateMinutes + 4 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                heroCard

                skillPathCard

                PracticeStepHeader(number: 1, title: store.t("Learn the move"), duration: "~2 \(store.t("min"))")
                learnCard

                PracticeStepHeader(number: 2, title: store.t("Debate for real"), duration: "~\(debateMinutes) \(store.t("min"))")
                motionCard

                PracticeStepHeader(number: 3, title: store.t("Get coached"), duration: "~2 \(store.t("min"))")
                coachCard
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) { startButton }
        .navigationTitle(store.t("Guided Practice"))
        .appScreen()
    }

    private var heroCard: some View {
        GlassCard(accent: RhetorixColors.cyan, padding: 18) {
            VStack(alignment: .leading, spacing: 10) {
                Label(store.t("Today's skill"), systemImage: skill.icon)
                    .font(.caption.bold())
                    .foregroundStyle(RhetorixColors.cyan)
                Text(store.t(skill.rawValue))
                    .font(.title2.bold())
                Text(store.t(skill.lessonSummary))
                    .font(.subheadline)
                    .foregroundStyle(RhetorixColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 6) {
                    PracticePlanChip(number: 1, title: store.t("Learn"))
                    planArrow
                    PracticePlanChip(number: 2, title: store.t("Debate"))
                    planArrow
                    PracticePlanChip(number: 3, title: store.t("Review"))
                    Spacer(minLength: 4)
                    Text("~\(totalMinutes) \(store.t("min"))")
                        .font(.caption.bold())
                        .foregroundStyle(RhetorixColors.textTertiary)
                }
                .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var planArrow: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(RhetorixColors.textTertiary)
    }

    private var skillPathCard: some View {
        GlassCard(accent: RhetorixColors.green) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label(store.t("Skill path"), systemImage: "point.topleft.down.to.point.bottomright.curvepath.fill")
                        .font(.caption.bold())
                        .foregroundStyle(RhetorixColors.green)
                    Spacer()
                    Text("\(store.t("Step")) \(currentStepNumber) / \(AppStore.skillPath.count)")
                        .font(.caption.bold())
                        .foregroundStyle(RhetorixColors.textTertiary)
                }
                HStack(spacing: 0) {
                    ForEach(Array(AppStore.skillPath.enumerated()), id: \.offset) { index, pathSkill in
                        if index > 0 {
                            Rectangle()
                                .fill(store.isSkillMastered(pathSkill) ? RhetorixColors.green.opacity(0.5) : RhetorixColors.border)
                                .frame(height: 1.5)
                                .frame(maxWidth: .infinity)
                        }
                        SkillPathNode(
                            skill: pathSkill,
                            isMastered: store.isSkillMastered(pathSkill),
                            isActive: pathSkill == skill,
                            label: store.t(pathSkill.rawValue)
                        ) {
                            selectedSkill = pathSkill
                        }
                    }
                }
                Text(nextUpText)
                    .font(.caption.bold())
                    .foregroundStyle(RhetorixColors.textSecondary)
                Text(store.t("Reach a coach score of 4+ in any judged debate to master a skill. Tap any step to practice it."))
                    .font(.caption2)
                    .foregroundStyle(RhetorixColors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var currentStepNumber: Int {
        (AppStore.skillPath.firstIndex(of: skill) ?? 0) + 1
    }

    private var nextUpText: String {
        let path = AppStore.skillPath
        if let index = path.firstIndex(of: skill), index + 1 < path.count {
            return "\(store.t("Next")): \(store.t(path[index + 1].rawValue))"
        }
        return store.t("Final step of the path")
    }

    private var learnCard: some View {
        GlassCard(accent: RhetorixColors.amber) {
            VStack(alignment: .leading, spacing: 12) {
                Text(store.t(skill.strategy))
                    .font(.headline)
                    .foregroundStyle(RhetorixColors.amber)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12).fill(RhetorixColors.glassStrong))

                VStack(alignment: .leading, spacing: 6) {
                    Label(store.t("Worked example"), systemImage: "lightbulb.fill")
                        .font(.caption.bold())
                        .foregroundStyle(RhetorixColors.green)
                    Text(store.t(skill.example))
                        .font(.subheadline)
                        .foregroundStyle(RhetorixColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Divider().overlay(RhetorixColors.border)

                VStack(alignment: .leading, spacing: 8) {
                    Text(store.t("Before you speak, check"))
                        .font(.caption.bold())
                        .foregroundStyle(RhetorixColors.textTertiary)
                    ForEach(skill.checklist, id: \.self) { item in
                        Label(store.t(item), systemImage: "checkmark.circle")
                            .font(.subheadline)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var motionCard: some View {
        if let topic {
            GlassCard(accent: RhetorixColors.peach) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(store.t("Practice motion"))
                        .font(.caption.bold())
                        .foregroundStyle(RhetorixColors.peach)
                    Text(store.topicTitle(topic))
                        .font(.headline)
                    Text(store.topicDetails(topic))
                        .font(.caption)
                        .foregroundStyle(RhetorixColors.textSecondary)
                    HStack(spacing: 8) {
                        PracticeSetupChip(icon: "person.wave.2.fill", text: "\(store.t("You argue")): \(store.debateSide(.support))")
                        PracticeSetupChip(icon: "dial.medium", text: store.debateDifficulty(difficulty))
                        PracticeSetupChip(icon: "timer", text: "\(debateMinutes) \(store.t("min"))")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            GlassCard(accent: RhetorixColors.peach) {
                Text(store.t("No practice motion available yet."))
                    .font(.subheadline)
                    .foregroundStyle(RhetorixColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var coachCard: some View {
        GlassCard(accent: RhetorixColors.green) {
            VStack(alignment: .leading, spacing: 10) {
                PracticeCoachRow(icon: "person.fill.checkmark", text: store.t("Rate yourself on today's skill"))
                PracticeCoachRow(icon: "list.star", text: store.t("The AI coach scores the same five skills"))
                PracticeCoachRow(icon: "arrow.counterclockwise", text: store.t("Retry one speech and compare"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var startButton: some View {
        Button {
            startPractice()
        } label: {
            PrimaryActionLabel(
                title: store.t("Start Guided Practice"),
                detail: "\(store.t(skill.rawValue)) · \(debateMinutes) \(store.t("min"))",
                systemImage: "mic.fill"
            )
        }
        .buttonStyle(.rhetorixPrimary)
        .disabled(topic == nil)
        .accessibilityIdentifier("practice.start")
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(
            LinearGradient(
                colors: [RhetorixColors.background.opacity(0), RhetorixColors.background],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
        )
    }

    private func startPractice() {
        guard let topic else { return }
        let format: DebateFormat = store.learningProfile.practiceDuration == .fiveMinutes ? .freeFlow : .structured
        let session = store.createSession(
            topic: topic,
            mode: .userVsAi,
            format: format,
            difficulty: difficulty,
            side: .support,
            provider: store.preferredProvider,
            practiceSkill: skill
        )
        path.append(AppRoute.debate(session.id))
    }
}

struct SkillPathNode: View {
    var skill: DebateSkill
    var isMastered: Bool
    var isActive: Bool
    var label: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isActive ? RhetorixColors.glassStrong : RhetorixColors.glass)
                    .frame(width: 42, height: 42)
                    .overlay(
                        Circle().stroke(
                            isActive ? RhetorixColors.cyan : (isMastered ? RhetorixColors.green.opacity(0.6) : RhetorixColors.border),
                            lineWidth: isActive ? 1.8 : 1
                        )
                    )
                if isMastered && isActive == false {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(RhetorixColors.green)
                } else {
                    Image(systemName: skill.icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(isActive ? RhetorixColors.cyan : RhetorixColors.textSecondary)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }
}

struct PracticeStepHeader: View {
    var number: Int
    var title: String
    var duration: String

    var body: some View {
        HStack(spacing: 8) {
            Text("\(number)")
                .font(.caption.bold())
                .foregroundStyle(RhetorixColors.textPrimary)
                .frame(width: 22, height: 22)
                .background(Circle().fill(RhetorixColors.glassStrong))
                .overlay(Circle().stroke(RhetorixColors.cyan.opacity(0.45), lineWidth: 1))
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(RhetorixColors.textPrimary)
            Spacer()
            Text(duration)
                .font(.caption2.bold())
                .foregroundStyle(RhetorixColors.textTertiary)
        }
        .padding(.top, 4)
    }
}

struct PracticePlanChip: View {
    var number: Int
    var title: String

    var body: some View {
        HStack(spacing: 5) {
            Text("\(number)")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(RhetorixColors.cyan)
            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(RhetorixColors.textPrimary)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Capsule().fill(RhetorixColors.glassStrong))
    }
}

struct PracticeSetupChip: View {
    var icon: String
    var text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(RhetorixColors.cyan)
            Text(text)
                .font(.caption2.bold())
                .foregroundStyle(RhetorixColors.textSecondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Capsule().fill(RhetorixColors.glassStrong))
    }
}

struct PracticeCoachRow: View {
    var icon: String
    var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(RhetorixColors.green)
                .frame(width: 22)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(RhetorixColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
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

struct TopicSelectionView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var path: NavigationPath
    @State private var search = ""
    @State private var showCustomTopicDialog = false
    @State private var customTopicTitle = ""
    @State private var customTopicDetails = ""
    @State private var isCreatingCustomTopic = false

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
                let title = customTopicTitle
                let details = customTopicDetails
                Task {
                    isCreatingCustomTopic = true
                    if let topic = await store.addCustomTopicAfterSafetyCheck(title: title, details: details) {
                        path.append(AppRoute.setup(topic))
                    }
                    isCreatingCustomTopic = false
                }
            }
            .disabled(isCreatingCustomTopic || customTopicTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                GlassCard(accent: RhetorixColors.cyan) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(store.topicTitle(topic)).font(.headline)
                        Text(store.topicDetails(topic)).font(.caption).foregroundStyle(RhetorixColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                RhetorixChoiceChips(
                    title: store.t("Mode"),
                    options: DebateMode.allCases.map { ($0, store.debateMode($0)) },
                    selection: $mode
                )
                RhetorixChoiceChips(
                    title: store.t("Format"),
                    options: DebateFormat.allCases.map { ($0, store.debateFormat($0)) },
                    selection: $format
                )
                RhetorixChoiceChips(
                    title: store.t("Difficulty"),
                    options: DebateDifficulty.allCases.map { ($0, store.debateDifficulty($0)) },
                    selection: $difficulty
                )
                if mode == .userVsAi {
                    RhetorixChoiceChips(
                        title: store.t("Your Position"),
                        options: DebateSide.allCases.map { ($0, store.debateSide($0)) },
                        selection: $side
                    )
                }
                Button {
                    let session = store.createSession(topic: topic, mode: mode, format: format, difficulty: difficulty, side: side, provider: store.preferredProvider)
                    path.append(AppRoute.debate(session.id))
                } label: {
                    PrimaryActionLabel(
                        title: store.t("Start Debate"),
                        detail: "\(store.debateMode(mode)) · \(store.debateDifficulty(difficulty))",
                        systemImage: "mic.fill"
                    )
                }
                .buttonStyle(.rhetorixPrimary)
                .accessibilityIdentifier("setup.startDebate")
                .padding(.top, 4)
            }
            .padding()
        }
        .navigationTitle(store.t("Debate Setup"))
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
                            Text(store.topicTitle(session.topic))
                                .font(.title3.bold())
                                .foregroundStyle(RhetorixColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            if let skill = session.practiceSkill {
                                DebatePracticeFocusCard(skill: skill)
                            }
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
                            aiSpeech.speak(
                                last.content,
                                turnID: last.id,
                                usesChinese: store.usesChinese,
                                engine: store.voiceOutputEngine,
                                volcengineConfig: store.volcengineTTSConfig,
                                voiceboxConfig: store.voiceboxTTSConfig
                            )
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
                    .disabled(store.isWorking)
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
        .navigationTitle(store.t("Live Debate"))
        .navigationBarTitleDisplayMode(.inline)
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
        if store.sessions.first(where: { $0.id == sessionID })?.result != nil {
            path.append(AppRoute.selfAssessment(sessionID))
        }
    }
}

struct DebatePracticeFocusCard: View {
    @EnvironmentObject private var store: AppStore
    var skill: DebateSkill

    var body: some View {
        GlassCard(accent: RhetorixColors.cyan) {
            VStack(alignment: .leading, spacing: 8) {
                Label(store.t("Practice focus"), systemImage: skill.icon)
                    .font(.caption.bold())
                    .foregroundStyle(RhetorixColors.cyan)
                Text(store.t(skill.rawValue)).font(.headline)
                Text(store.t(skill.strategy))
                    .font(.subheadline)
                    .foregroundStyle(RhetorixColors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
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
                if session.mode != .aiVsAi {
                    StageTimerView(limit: store.stageTimeLimit(for: session), startedAt: stageStartedAt, now: now)
                }
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
                    .textFieldStyle(.plain)
                    .rhetorixField()
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
                                speechPlayer.speak(
                                    turn.content,
                                    turnID: turn.id,
                                    usesChinese: store.usesChinese,
                                    engine: store.voiceOutputEngine,
                                    volcengineConfig: store.volcengineTTSConfig,
                                    voiceboxConfig: store.voiceboxTTSConfig
                                )
                            }
                        } label: {
                            Image(systemName: speechPlayer.speakingTurnID == turn.id ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(store.t(speechPlayer.speakingTurnID == turn.id ? "Stop AI voice" : "Read AI response"))
                    }
                }
                AIMarkdownText(turn.content).foregroundStyle(RhetorixColors.textPrimary)
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

struct DebateSelfAssessmentView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var path: NavigationPath
    var sessionID: String
    @State private var ratings = Dictionary(uniqueKeysWithValues: DebateSkill.allCases.map { ($0, 3) })
    @State private var reflection = ""

    private var session: DebateSession? {
        store.sessions.first { $0.id == sessionID }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                GlassCard(accent: RhetorixColors.amber) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(store.t("Reflect before seeing the judge"), systemImage: "brain.head.profile")
                            .font(.title3.bold())
                        Text(store.t("Rate the speech you actually gave. The coach scores stay hidden until you finish this reflection."))
                            .font(.subheadline)
                            .foregroundStyle(RhetorixColors.textSecondary)
                    }
                }

                ForEach(DebateSkill.allCases) { skill in
                    GlassCard(accent: skill == session?.practiceSkill ? RhetorixColors.cyan : RhetorixColors.glassStrong) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Label(store.t(skill.rawValue), systemImage: skill.icon)
                                    .font(.headline)
                                Spacer()
                                Text("\(ratings[skill] ?? 3)/5")
                                    .font(.headline.monospacedDigit())
                                    .foregroundStyle(RhetorixColors.amber)
                            }
                            RhetorixChoiceChips(
                                title: nil,
                                options: (1...5).map { ($0, "\($0)") },
                                selection: ratingBinding(for: skill)
                            )
                        }
                    }
                }

                GlassCard(accent: RhetorixColors.green) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(store.t("One thing I would change next time")).font(.headline)
                        TextField(store.t("Optional reflection"), text: $reflection, axis: .vertical)
                            .textFieldStyle(.plain)
                            .lineLimit(3...6)
                            .rhetorixField()
                    }
                }

                Button {
                    store.saveSelfAssessment(sessionID: sessionID, ratings: ratings, reflection: reflection)
                    path.append(AppRoute.result(sessionID))
                } label: {
                    Label(store.t("See Coach Feedback"), systemImage: "chart.bar.doc.horizontal.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityIdentifier("selfAssessment.submit")
            }
            .padding()
        }
        .navigationTitle(store.t("Self-Assessment"))
        .onAppear {
            guard let existing = session?.selfAssessment else { return }
            ratings = existing.ratings
            reflection = existing.reflection
        }
        .navigationBarBackButtonHidden()
        .appScreen()
    }

    private func ratingBinding(for skill: DebateSkill) -> Binding<Int> {
        Binding(
            get: { ratings[skill] ?? 3 },
            set: { ratings[skill] = $0 }
        )
    }
}

struct ResultView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var path: NavigationPath
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
                        AIMarkdownText(session.result?.summary ?? store.t("No judgment yet."))
                            .multilineTextAlignment(.center)
                        AIDisclaimer()
                    }
                }
                .listRowBackground(Color.clear)
                if session.result != nil {
                    if let selfAssessment = session.selfAssessment {
                        SelfAssessmentComparisonSection(selfAssessment: selfAssessment, rubric: session.result?.rubric ?? [])
                            .listRowBackground(Color.clear)
                    }
                    DebateRubricSection(rubric: session.result?.rubric ?? [], focusSkill: session.practiceSkill)
                        .listRowBackground(Color.clear)
                    ResultFeedbackSection(session: session)
                        .listRowBackground(Color.clear)
                    DeepDebateReviewSection(result: session.result!)
                        .listRowBackground(Color.clear)
                    SpeechRetrySection(path: $path, session: session)
                        .listRowBackground(Color.clear)
                }
                Section(store.t("Transcript")) {
                    ForEach(session.turns) { turn in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(store.speaker(turn.role)).font(.caption.bold()).foregroundStyle(turn.role.color)
                            AIMarkdownText(turn.content)
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

struct SelfAssessmentComparisonSection: View {
    @EnvironmentObject private var store: AppStore
    var selfAssessment: DebateSelfAssessment
    var rubric: [DebateRubricScore]

    var body: some View {
        GlassCard(accent: RhetorixColors.amber) {
            VStack(alignment: .leading, spacing: 12) {
                Label(store.t("Your view and the coach's view"), systemImage: "arrow.left.arrow.right.circle.fill")
                    .font(.headline)
                ForEach(DebateSkill.allCases) { skill in
                    let coachScore = rubric.first(where: { $0.skill == skill })?.score
                    HStack {
                        Text(store.t(skill.rawValue))
                            .font(.caption)
                        Spacer()
                        Text("\(store.t("You")) \(selfAssessment.ratings[skill] ?? 3)")
                            .font(.caption.bold())
                            .foregroundStyle(RhetorixColors.cyan)
                        Text("·")
                        Text("\(store.t("Coach")) \(coachScore.map(String.init) ?? "–")")
                            .font(.caption.bold())
                            .foregroundStyle(RhetorixColors.amber)
                    }
                }
                if selfAssessment.reflection.isEmpty == false {
                    Text("“\(selfAssessment.reflection)”")
                        .font(.caption)
                        .foregroundStyle(RhetorixColors.textSecondary)
                }
            }
        }
    }
}

struct DebateRubricSection: View {
    @EnvironmentObject private var store: AppStore
    var rubric: [DebateRubricScore]
    var focusSkill: DebateSkill?

    var body: some View {
        if rubric.isEmpty == false {
            GlassCard(accent: RhetorixColors.cyan) {
                VStack(alignment: .leading, spacing: 14) {
                    Label(store.t("Five-skill coach rubric"), systemImage: "chart.bar.fill")
                        .font(.headline)
                    ForEach(rubric) { item in
                        VStack(alignment: .leading, spacing: 7) {
                            HStack {
                                Label(store.t(item.skill.rawValue), systemImage: item.skill.icon)
                                    .font(.subheadline.bold())
                                if item.skill == focusSkill {
                                    Text(store.t("Practice focus"))
                                        .font(.caption2.bold())
                                        .foregroundStyle(RhetorixColors.cyan)
                                }
                                Spacer()
                                RubricScoreDots(score: item.score)
                            }
                            if item.evidenceQuote.isEmpty == false {
                                Text("“\(item.evidenceQuote)”")
                                    .font(.caption)
                                    .foregroundStyle(RhetorixColors.textTertiary)
                            }
                            if item.strength.isEmpty == false {
                                Label(item.strength, systemImage: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(RhetorixColors.green)
                            }
                            if item.nextStep.isEmpty == false {
                                Label(item.nextStep, systemImage: "arrow.up.right.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(RhetorixColors.textSecondary)
                            }
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 14).fill(RhetorixColors.glassStrong))
                    }
                    AIDisclaimer()
                }
            }
        }
    }
}

struct RubricScoreDots: View {
    var score: Int

    var body: some View {
        HStack(spacing: 3) {
            ForEach(1...5, id: \.self) { value in
                Circle()
                    .fill(value <= score ? RhetorixColors.amber : RhetorixColors.border)
                    .frame(width: 8, height: 8)
            }
        }
        .accessibilityLabel("\(score) out of 5")
    }
}

struct SpeechRetrySection: View {
    @EnvironmentObject private var store: AppStore
    @Binding var path: NavigationPath
    var session: DebateSession

    private var studentTurns: [DebateTurn] {
        session.turns.filter { $0.role == .user }
    }

    var body: some View {
        if studentTurns.isEmpty == false {
            GlassCard(accent: RhetorixColors.green) {
                VStack(alignment: .leading, spacing: 12) {
                    Label(store.t("Improve one speech now"), systemImage: "arrow.clockwise.circle.fill")
                        .font(.headline)
                    Text(store.t("Choose a speech, apply the feedback, and compare the retry with your first attempt."))
                        .font(.caption)
                        .foregroundStyle(RhetorixColors.textSecondary)
                    ForEach(studentTurns) { turn in
                        let turnIndex = session.turns.firstIndex(where: { $0.id == turn.id }) ?? 0
                        let retry = session.speechRetries?.last(where: { $0.originalTurnID == turn.id })
                        VStack(alignment: .leading, spacing: 8) {
                            Text(store.stageTitle(for: session, turnIndex: turnIndex))
                                .font(.caption.bold())
                                .foregroundStyle(RhetorixColors.cyan)
                            Text(turn.content)
                                .font(.caption)
                                .lineLimit(3)
                            if let retry {
                                HStack {
                                    Text("\(retry.beforeScore) → \(retry.afterScore)")
                                        .font(.headline.monospacedDigit())
                                        .foregroundStyle(retry.afterScore > retry.beforeScore ? RhetorixColors.green : RhetorixColors.amber)
                                    AIMarkdownText(retry.feedback)
                                        .font(.caption2)
                                        .foregroundStyle(RhetorixColors.textSecondary)
                                        .lineLimit(2)
                                }
                            }
                            Button {
                                path.append(AppRoute.retrySpeech(session.id, turn.id))
                            } label: {
                                Label(store.t(retry == nil ? "Retry this speech" : "Retry again"), systemImage: "mic.badge.plus")
                            }
                            .buttonStyle(.bordered)
                            .accessibilityIdentifier("result.retrySpeech")
                        }
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 12).fill(RhetorixColors.glassStrong))
                    }
                }
            }
        }
    }
}

struct SpeechRetryView: View {
    @EnvironmentObject private var store: AppStore
    var sessionID: String
    var turnID: String
    @State private var revisedText = ""
    @State private var isSubmitting = false

    private var session: DebateSession? { store.sessions.first { $0.id == sessionID } }
    private var turn: DebateTurn? { session?.turns.first { $0.id == turnID } }
    private var latestRetry: SpeechRetry? { store.speechRetry(sessionID: sessionID, turnID: turnID) }
    private var coachingStep: String? {
        guard let session else { return nil }
        let focus = session.practiceSkill
        return session.result?.rubric.first(where: { $0.skill == focus })?.nextStep
            ?? session.result?.rubric.min(by: { $0.score < $1.score })?.nextStep
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let turn {
                    GlassCard(accent: RhetorixColors.salmon) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(store.t("Original speech")).font(.headline)
                            Text(turn.content).foregroundStyle(RhetorixColors.textSecondary)
                        }
                    }
                }

                if let coachingStep, coachingStep.isEmpty == false {
                    GlassCard(accent: RhetorixColors.amber) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(store.t("Apply this correction")).font(.caption.bold()).foregroundStyle(RhetorixColors.amber)
                            Text(coachingStep).font(.headline)
                        }
                    }
                }

                GlassCard(accent: RhetorixColors.cyan) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(store.t("Your revised speech")).font(.headline)
                        TextEditor(text: $revisedText)
                            .frame(minHeight: 170)
                            .scrollContentBackground(.hidden)
                            .padding(4)
                            .rhetorixField()
                            .accessibilityIdentifier("retry.input")
                    }
                }

                Button {
                    Task { await submitRetry() }
                } label: {
                    HStack {
                        if isSubmitting { ProgressView() }
                        Label(store.t("Compare My Retry"), systemImage: "arrow.left.arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isSubmitting || revisedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("retry.submit")

                if let retry = latestRetry {
                    GlassCard(accent: retry.afterScore > retry.beforeScore ? RhetorixColors.green : RhetorixColors.amber) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(store.t("Retry comparison")).font(.headline)
                                Spacer()
                                Text("\(retry.beforeScore) → \(retry.afterScore)")
                                    .font(.title2.bold().monospacedDigit())
                            }
                            AIMarkdownText(retry.feedback).foregroundStyle(RhetorixColors.textSecondary)
                            if retry.improvedSkills.isEmpty == false {
                                Text(retry.improvedSkills.map { store.t($0.rawValue) }.joined(separator: " · "))
                                    .font(.caption.bold())
                                    .foregroundStyle(RhetorixColors.green)
                            }
                            AIDisclaimer()
                        }
                    }
                    .accessibilityIdentifier("retry.result")
                }
            }
            .padding()
        }
        .navigationTitle(store.t("Retry Speech"))
        .onAppear {
            if revisedText.isEmpty { revisedText = latestRetry?.revisedText ?? turn?.content ?? "" }
        }
        .appScreen()
    }

    private func submitRetry() async {
        isSubmitting = true
        _ = await store.retrySpeech(sessionID: sessionID, turnID: turnID, revisedText: revisedText)
        isSubmitting = false
    }
}

struct DeepDebateReviewSection: View {
    @EnvironmentObject private var store: AppStore
    var result: DebateResult

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if result.judgeRationale.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                GlassCard(accent: RhetorixColors.amber) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(store.t("Why the judge decided"), systemImage: "scale.3d")
                            .font(.headline)
                            .foregroundStyle(RhetorixColors.textPrimary)
                        AIMarkdownText(result.judgeRationale)
                            .font(.body)
                            .foregroundStyle(RhetorixColors.textSecondary)
                        AIDisclaimer()
                    }
                }
            }
            ReviewPointSection(
                title: store.t("Key clashes"),
                icon: "bolt.horizontal.circle.fill",
                accent: RhetorixColors.salmon,
                points: result.keyClashes
            )
            ReviewPointSection(
                title: store.t("Strongest support arguments"),
                icon: "hand.thumbsup.fill",
                accent: RhetorixColors.green,
                points: result.strongestSupportArguments
            )
            ReviewPointSection(
                title: store.t("Strongest oppose arguments"),
                icon: "hand.raised.fill",
                accent: RhetorixColors.peach,
                points: result.strongestOpposeArguments
            )
            ReviewPointSection(
                title: store.t("Improvement actions"),
                icon: "target",
                accent: RhetorixColors.cyan,
                points: result.improvementActions
            )
            if result.nextPracticeFocus.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                GlassCard(accent: RhetorixColors.cyan) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(store.t("Next practice focus"), systemImage: "arrow.forward.circle.fill")
                            .font(.headline)
                            .foregroundStyle(RhetorixColors.textPrimary)
                        AIMarkdownText(result.nextPracticeFocus)
                            .font(.body.weight(.medium))
                            .foregroundStyle(RhetorixColors.textPrimary)
                        AIDisclaimer()
                    }
                }
            }
        }
    }
}

struct ReviewPointSection: View {
    var title: String
    var icon: String
    var accent: Color
    var points: [DebateReviewPoint]

    var body: some View {
        if points.isEmpty == false {
            GlassCard(accent: accent) {
                VStack(alignment: .leading, spacing: 12) {
                    Label(title, systemImage: icon)
                        .font(.headline)
                        .foregroundStyle(RhetorixColors.textPrimary)
                    ForEach(points) { point in
                        VStack(alignment: .leading, spacing: 6) {
                            if point.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                                Text(point.title)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(accent)
                            }
                            AIMarkdownText(point.detail)
                                .font(.body)
                                .foregroundStyle(RhetorixColors.textSecondary)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RhetorixColors.glassStrong)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    AIDisclaimer()
                }
            }
        }
    }
}

struct ResultFeedbackSection: View {
    @EnvironmentObject private var store: AppStore
    var session: DebateSession
    @State private var pendingSentiment: RecommendationFeedbackSentiment?

    private var savedFeedback: RecommendationFeedback? {
        store.resultFeedback(for: session.id)
    }

    private var dialogTitle: String {
        pendingSentiment == .like
            ? store.t("What do you like about it?")
            : store.t("What do you dislike about it?")
    }

    var body: some View {
        GlassCard(accent: RhetorixColors.cyan) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.t("Help Rhetorix recommend better topics"))
                            .font(.headline)
                        Text(feedbackDescription)
                            .font(.caption)
                            .foregroundStyle(RhetorixColors.textSecondary)
                    }
                    Spacer()
                }
                HStack(spacing: 12) {
                    feedbackButton(
                        sentiment: .like,
                        icon: "hand.thumbsup.fill",
                        title: store.t("Like")
                    )
                    .accessibilityIdentifier("result.feedback.like")
                    feedbackButton(
                        sentiment: .dislike,
                        icon: "hand.thumbsdown.fill",
                        title: store.t("Dislike")
                    )
                    .accessibilityIdentifier("result.feedback.dislike")
                }
            }
        }
        .confirmationDialog(dialogTitle, isPresented: Binding(
            get: { pendingSentiment != nil },
            set: { if $0 == false { pendingSentiment = nil } }
        ), titleVisibility: .visible) {
            Button(store.t("Category")) {
                saveFeedback(reasonType: .category)
            }
            .accessibilityIdentifier("result.feedback.category")
            Button(store.t("Technique")) {
                saveFeedback(reasonType: .technique)
            }
            .accessibilityIdentifier("result.feedback.technique")
            Button(store.t("Cancel"), role: .cancel) {
                pendingSentiment = nil
            }
        }
    }

    private var feedbackDescription: String {
        guard let savedFeedback else {
            return store.t("Category feedback changes future topic recommendations. Technique feedback is recorded but does not change recommendations.")
        }
        return "\(store.t("Saved")): \(store.t(savedFeedback.sentiment.rawValue)) · \(store.t(savedFeedback.reasonType.rawValue))"
    }

    private func feedbackButton(sentiment: RecommendationFeedbackSentiment, icon: String, title: String) -> some View {
        Button {
            pendingSentiment = sentiment
        } label: {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .font(.subheadline.bold())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(savedFeedback?.sentiment == sentiment ? RhetorixColors.cyan.opacity(0.26) : RhetorixColors.glass)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(savedFeedback?.sentiment == sentiment ? RhetorixColors.cyan : RhetorixColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func saveFeedback(reasonType: RecommendationFeedbackReasonType) {
        guard let pendingSentiment else { return }
        store.recordResultFeedback(sessionID: session.id, sentiment: pendingSentiment, reasonType: reasonType)
        self.pendingSentiment = nil
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
            Section(store.t("Learning Plan")) {
                Picker(store.t("Primary goal"), selection: Binding(
                    get: { store.learningProfile.goal },
                    set: { store.setLearningGoal($0) }
                )) {
                    ForEach(LearningGoal.allCases) { goal in
                        Text(store.t(goal.rawValue)).tag(goal)
                    }
                }
                Picker(store.t("Experience level"), selection: Binding(
                    get: { store.learningProfile.experience },
                    set: { store.setDebateExperience($0) }
                )) {
                    ForEach(DebateExperience.allCases) { experience in
                        Text(store.t(experience.rawValue)).tag(experience)
                    }
                }
                Picker(store.t("Practice length"), selection: Binding(
                    get: { store.learningProfile.practiceDuration },
                    set: { store.setPracticeDuration($0) }
                )) {
                    ForEach(PracticeDuration.allCases) { duration in
                        Text("\(duration.rawValue) \(store.t("min"))").tag(duration)
                    }
                }
            }
            .listRowBackground(RhetorixColors.glass)
            Section(store.t("Voice")) {
                Toggle(store.t("Auto-read AI responses"), isOn: Binding(
                    get: { store.autoSpeakAI },
                    set: { store.setAutoSpeakAI($0) }
                ))
                Picker(store.t("Voice Engine"), selection: Binding(
                    get: { store.voiceOutputEngine },
                    set: { store.setVoiceOutputEngine($0) }
                )) {
                    ForEach(VoiceOutputEngine.allCases) { engine in
                        Text(store.t(engine.rawValue)).tag(engine)
                    }
                }
                if store.voiceOutputEngine == .volcengine {
                    TextField(store.t("Volcengine App ID"), text: Binding(
                        get: { store.volcengineTTSConfig.appID },
                        set: {
                            var next = store.volcengineTTSConfig
                            next.appID = $0
                            store.setVolcengineTTSConfig(next)
                        }
                    ))
                    SecureField(store.t("Volcengine Access Token"), text: Binding(
                        get: { store.volcengineTTSConfig.accessToken },
                        set: {
                            var next = store.volcengineTTSConfig
                            next.accessToken = $0
                            store.setVolcengineTTSConfig(next)
                        }
                    ))
                    TextField(store.t("Volcengine Cluster"), text: Binding(
                        get: { store.volcengineTTSConfig.cluster },
                        set: {
                            var next = store.volcengineTTSConfig
                            next.cluster = $0
                            store.setVolcengineTTSConfig(next)
                        }
                    ))
                    TextField(store.t("Volcengine Voice Type"), text: Binding(
                        get: { store.volcengineTTSConfig.voiceType },
                        set: {
                            var next = store.volcengineTTSConfig
                            next.voiceType = $0
                            store.setVolcengineTTSConfig(next)
                        }
                    ))
                    VStack(alignment: .leading) {
                        Text("\(store.t("Voice Speed")) \(store.volcengineTTSConfig.speedRatio, specifier: "%.1f")x")
                            .font(.caption)
                            .foregroundStyle(RhetorixColors.textSecondary)
                        Slider(value: Binding(
                            get: { store.volcengineTTSConfig.speedRatio },
                            set: {
                                var next = store.volcengineTTSConfig
                                next.speedRatio = $0
                                store.setVolcengineTTSConfig(next)
                            }
                        ), in: 0.7...1.3, step: 0.1)
                    }
                }
                if store.voiceOutputEngine == .voicebox {
                    TextField(store.t("Voicebox Server URL"), text: Binding(
                        get: { store.voiceboxTTSConfig.baseURL },
                        set: {
                            var next = store.voiceboxTTSConfig
                            next.baseURL = $0
                            store.setVoiceboxTTSConfig(next)
                        }
                    ))
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    TextField(store.t("Voicebox Profile ID"), text: Binding(
                        get: { store.voiceboxTTSConfig.profileID },
                        set: {
                            var next = store.voiceboxTTSConfig
                            next.profileID = $0
                            store.setVoiceboxTTSConfig(next)
                        }
                    ))
                    .textInputAutocapitalization(.never)
                    Picker(store.t("Voicebox Engine"), selection: Binding(
                        get: { store.voiceboxTTSConfig.engine },
                        set: {
                            var next = store.voiceboxTTSConfig
                            next.engine = $0
                            store.setVoiceboxTTSConfig(next)
                        }
                    )) {
                        ForEach(VoiceboxTTSConfig.engineChoices, id: \.self) { engine in
                            Text(engine).tag(engine)
                        }
                    }
                    Picker(store.t("Voicebox Model Size"), selection: Binding(
                        get: { store.voiceboxTTSConfig.modelSize },
                        set: {
                            var next = store.voiceboxTTSConfig
                            next.modelSize = $0
                            store.setVoiceboxTTSConfig(next)
                        }
                    )) {
                        ForEach(VoiceboxTTSConfig.modelSizeChoices, id: \.self) { size in
                            Text(size).tag(size)
                        }
                    }
                    Text(store.t("Use a LAN or remote Voicebox server URL on a real iPhone. 127.0.0.1 only works when the server runs on the same device or simulator host."))
                        .font(.caption)
                        .foregroundStyle(RhetorixColors.textSecondary)
                }
                Text(store.t("Online voice engines read AI responses when configured. System voice remains the fallback if online speech is unavailable."))
                    .font(.caption)
                    .foregroundStyle(RhetorixColors.textSecondary)
            }
            .listRowBackground(RhetorixColors.glass)
            Section(store.t("Memory Profile")) {
                Button {
                    path.append(AppRoute.memoryProfile)
                } label: {
                    Label(store.t("Open Memory Detail"), systemImage: "brain.head.profile")
                }
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

struct MemoryProfileDetailView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var path: NavigationPath

    var recommendations: [TopicRecommendation] {
        store.topicRecommendations(limit: 3)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                GlassCard(accent: RhetorixColors.amber) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label(store.t("Real local memory"), systemImage: "brain.head.profile")
                                .font(.headline)
                            Spacer()
                            Text(store.userProfileMemory.hasInferenceEvidence ? store.t("Evidence-based") : store.t("Learning"))
                                .font(.caption.bold())
                                .foregroundStyle(RhetorixColors.textSecondary)
                        }
                        Text(store.memorySummaryText())
                            .font(.subheadline)
                            .foregroundStyle(RhetorixColors.textSecondary)
                        HStack(spacing: 8) {
                            MemoryProfilePill(title: store.t("Evidence"), value: "\(store.userProfileMemory.evidenceSessionCount) \(store.t("debates"))")
                            MemoryProfilePill(title: store.t("Turns"), value: "\(store.userProfileMemory.evidenceTurnCount)")
                        }
                        if let mbti = store.userProfileMemory.mbti {
                            MemoryProfilePill(title: store.t("MBTI"), value: mbti.rawValue)
                        }
                    }
                }

                MemoryMetricGrid(profile: store.memoryProfile)

                if recommendations.isEmpty == false {
                    SectionTitle(text: store.t("Recommendation 2.0"))
                    VStack(spacing: 10) {
                        ForEach(recommendations) { recommendation in
                            Button {
                                path.append(AppRoute.setup(recommendation.topic))
                            } label: {
                                RecommendationCard(recommendation: recommendation)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } else {
                    GlassCard(accent: RhetorixColors.cyan) {
                        Text(store.t("Complete two debates to unlock real memory-based recommendations."))
                            .font(.subheadline)
                            .foregroundStyle(RhetorixColors.textSecondary)
                    }
                }

                MemorySignalSection(title: store.t("Debate style"), label: store.t("Style"), signals: store.userProfileMemory.styleSignals)
                MemorySignalSection(title: store.t("Value signal"), label: store.t("Values"), signals: store.userProfileMemory.valueSignals)
                MemorySignalSection(title: store.t("Practice focus"), label: store.t("Focus"), signals: store.userProfileMemory.weaknessSignals)
            }
            .padding()
        }
        .navigationTitle(store.t("Memory Profile"))
        .appScreen()
    }
}

struct MemoryMetricGrid: View {
    @EnvironmentObject private var store: AppStore
    var profile: UserMemoryProfile

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            MetricTile(title: store.t("Completion rate"), value: "\(profile.completionRate)%")
            MetricTile(title: store.t("Average length"), value: "\(profile.averageTurns) \(store.t("turns"))")
            MetricTile(title: store.t("Voice ratio"), value: "\(profile.voiceTurnRatio)%")
            MetricTile(title: store.t("Average stage time"), value: profile.averageStageSeconds.map { store.formatSeconds($0) } ?? store.t("Not enough data"))
        }
    }
}

struct MetricTile: View {
    var title: String
    var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundStyle(RhetorixColors.textSecondary)
            Text(value)
                .font(.headline.bold())
                .foregroundStyle(RhetorixColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(RhetorixColors.glass))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(RhetorixColors.border, lineWidth: 1))
    }
}

struct RecommendationCard: View {
    @EnvironmentObject private var store: AppStore
    var recommendation: TopicRecommendation

    var body: some View {
        GlassCard(accent: RhetorixColors.cyan) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "target")
                    .font(.title3)
                    .foregroundStyle(RhetorixColors.cyan)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(RhetorixColors.glassStrong))
                VStack(alignment: .leading, spacing: 5) {
                    Text(store.topicTitle(recommendation.topic))
                        .font(.headline)
                        .foregroundStyle(RhetorixColors.textPrimary)
                    Text(recommendation.reason)
                        .font(.caption)
                        .foregroundStyle(RhetorixColors.textSecondary)
                    Text("\(store.t("Recommended practice focus")): \(recommendation.focus)")
                        .font(.caption.bold())
                        .foregroundStyle(RhetorixColors.amber)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(RhetorixColors.textTertiary)
            }
        }
    }
}

struct MemorySignalSection: View {
    @EnvironmentObject private var store: AppStore
    var title: String
    var label: String
    var signals: [MemorySignal]

    var body: some View {
        if signals.isEmpty == false {
            SectionTitle(text: title)
            VStack(spacing: 10) {
                ForEach(signals) { signal in
                    GlassCard(accent: RhetorixColors.amber) {
                        MemorySignalRow(label: label, signal: signal)
                    }
                }
            }
        }
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
                        .rhetorixField()

                        RhetorixMenuField(
                            title: store.t("Model"),
                            options: provider.modelChoices.map { ($0, $0) } + [(otherModelTag, store.t("Other"))],
                            selection: $selectedModel
                        )
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
                                .textFieldStyle(.plain)
                                .rhetorixField()
                                .onChange(of: customModel) { _, newValue in
                                    config.modelName = newValue
                                }
                        }

                        TextField(store.t("Base URL"), text: $config.baseURL)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .textFieldStyle(.plain)
                            .rhetorixField()
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
    private var audioPlayer: AVAudioPlayer?
    private var onlineSpeechTask: Task<Void, Never>?
    private var pendingUtteranceCount = 0

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(
        _ text: String,
        turnID: String,
        usesChinese: Bool,
        engine: VoiceOutputEngine = .system,
        volcengineConfig: VolcengineTTSConfig = VolcengineTTSConfig(),
        voiceboxConfig: VoiceboxTTSConfig = VoiceboxTTSConfig()
    ) {
        let cleaned = Self.speechReadyText(text)
        guard cleaned.isEmpty == false else { return }

        stop()
        configureAudioSession()

        if engine == .volcengine, volcengineConfig.isConfigured {
            speakingTurnID = turnID
            let chunks = Self.speechChunks(from: cleaned, maxLength: usesChinese ? 220 : 360)
            onlineSpeechTask = Task { [weak self] in
                guard let self else { return }
                do {
                    for chunk in chunks {
                        try Task.checkCancellation()
                        let data = try await Self.fetchVolcengineAudio(text: chunk, config: volcengineConfig)
                        try Task.checkCancellation()
                        try await self.playOnlineAudio(data)
                    }
                    await MainActor.run {
                        self.speakingTurnID = nil
                    }
                } catch is CancellationError {
                    await MainActor.run {
                        self.speakingTurnID = nil
                    }
                } catch {
                    await MainActor.run {
                        self.speakSystem(cleaned, turnID: turnID, usesChinese: usesChinese, shouldStopFirst: false)
                    }
                }
            }
            return
        }

        if engine == .voicebox, voiceboxConfig.isConfigured {
            speakingTurnID = turnID
            let chunks = Self.speechChunks(from: cleaned, maxLength: usesChinese ? 260 : 420)
            onlineSpeechTask = Task { [weak self] in
                guard let self else { return }
                do {
                    for chunk in chunks {
                        try Task.checkCancellation()
                        let data = try await Self.fetchVoiceboxAudio(text: chunk, usesChinese: usesChinese, config: voiceboxConfig)
                        try Task.checkCancellation()
                        try await self.playOnlineAudio(data)
                    }
                    await MainActor.run {
                        self.speakingTurnID = nil
                    }
                } catch is CancellationError {
                    await MainActor.run {
                        self.speakingTurnID = nil
                    }
                } catch {
                    await MainActor.run {
                        self.speakSystem(cleaned, turnID: turnID, usesChinese: usesChinese, shouldStopFirst: false)
                    }
                }
            }
            return
        }

        speakSystem(cleaned, turnID: turnID, usesChinese: usesChinese, shouldStopFirst: false)
    }

    private func speakSystem(_ cleaned: String, turnID: String, usesChinese: Bool, shouldStopFirst: Bool = true) {
        if shouldStopFirst {
            stop()
            configureAudioSession()
        }

        let voice = preferredVoice(usesChinese: usesChinese)
        let chunks = Self.speechChunks(from: cleaned, maxLength: usesChinese ? 130 : 210)
        guard chunks.isEmpty == false else { return }

        speakingTurnID = turnID
        pendingUtteranceCount = chunks.count

        for (index, chunk) in chunks.enumerated() {
            let utterance = AVSpeechUtterance(string: chunk)
            utterance.voice = voice
            utterance.rate = usesChinese ? AVSpeechUtteranceDefaultSpeechRate * 0.82 : AVSpeechUtteranceDefaultSpeechRate * 0.88
            utterance.pitchMultiplier = 0.96
            utterance.volume = 1.0
            utterance.preUtteranceDelay = index == 0 ? 0 : 0.06
            utterance.postUtteranceDelay = Self.postDelay(for: chunk)
            synthesizer.speak(utterance)
        }
    }

    func stop() {
        onlineSpeechTask?.cancel()
        onlineSpeechTask = nil
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
        }
        audioPlayer = nil
        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }
        pendingUtteranceCount = 0
        speakingTurnID = nil
    }

    private func preferredVoice(usesChinese: Bool) -> AVSpeechSynthesisVoice? {
        let preferredLanguages = usesChinese ? ["zh-CN", "zh-Hans", "zh-Hant"] : ["en-US", "en-GB", "en-AU"]
        let voices = AVSpeechSynthesisVoice.speechVoices()
        if let best = voices
            .filter({ voice in preferredLanguages.contains { languageMatches(voice.language, preferred: $0) } })
            .max(by: { voiceScore($0, preferredLanguages: preferredLanguages) < voiceScore($1, preferredLanguages: preferredLanguages) }) {
            return best
        }
        return AVSpeechSynthesisVoice(language: preferredLanguages[0])
            ?? voices.first
    }

    private func languageMatches(_ language: String, preferred: String) -> Bool {
        language == preferred || language.hasPrefix(preferred.split(separator: "-").first.map(String.init) ?? preferred)
    }

    private func voiceScore(_ voice: AVSpeechSynthesisVoice, preferredLanguages: [String]) -> Int {
        var score = 0
        if voice.language == preferredLanguages.first {
            score += 60
        } else if preferredLanguages.contains(voice.language) {
            score += 42
        } else if preferredLanguages.contains(where: { languageMatches(voice.language, preferred: $0) }) {
            score += 24
        }

        switch voice.quality {
        case .premium:
            score += 45
        case .enhanced:
            score += 30
        default:
            score += 5
        }

        let loweredIdentifier = voice.identifier.lowercased()
        if loweredIdentifier.contains("compact") {
            score -= 24
        }
        if loweredIdentifier.contains("premium") || loweredIdentifier.contains("enhanced") {
            score += 8
        }
        if voice.name.lowercased().contains("siri") {
            score += 6
        }
        return score
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

    private static func speechReadyText(_ text: String) -> String {
        text
            .replacingOccurrences(of: #"```[\s\S]*?```"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #"`([^`]+)`"#, with: "$1", options: .regularExpression)
            .replacingOccurrences(of: #"\*\*([^*]+)\*\*"#, with: "$1", options: .regularExpression)
            .replacingOccurrences(of: #"__([^_]+)__"#, with: "$1", options: .regularExpression)
            .replacingOccurrences(of: #"\[([^\]]+)\]\([^)]+\)"#, with: "$1", options: .regularExpression)
            .replacingOccurrences(of: #"(?m)^\s{0,3}[-*+]\s+"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"(?m)^\s{0,3}\d+[.)]\s+"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"[{}\[\]\"|<>]"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func speechChunks(from text: String, maxLength: Int) -> [String] {
        let separators = CharacterSet(charactersIn: ".!?。！？；;\n")
        var chunks: [String] = []
        var current = ""

        for scalar in text.unicodeScalars {
            current.append(Character(scalar))
            if separators.contains(scalar) || current.count >= maxLength {
                let trimmed = current.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty == false {
                    chunks.append(trimmed)
                }
                current = ""
            }
        }

        let remaining = current.trimmingCharacters(in: .whitespacesAndNewlines)
        if remaining.isEmpty == false {
            chunks.append(remaining)
        }
        return chunks
    }

    private static func postDelay(for chunk: String) -> TimeInterval {
        if chunk.hasSuffix("。") || chunk.hasSuffix(".") || chunk.hasSuffix("!") || chunk.hasSuffix("?") || chunk.hasSuffix("！") || chunk.hasSuffix("？") {
            return 0.12
        }
        if chunk.hasSuffix("；") || chunk.hasSuffix(";") {
            return 0.09
        }
        return 0.05
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.pendingUtteranceCount = max(0, self.pendingUtteranceCount - 1)
            if self.pendingUtteranceCount == 0 {
                self.speakingTurnID = nil
            }
        }
    }

    private func playOnlineAudio(_ data: Data) async throws {
        try await MainActor.run {
            let player = try AVAudioPlayer(data: data)
            player.prepareToPlay()
            player.play()
            audioPlayer = player
        }

        while true {
            try Task.checkCancellation()
            let isPlaying = await MainActor.run { audioPlayer?.isPlaying == true }
            if isPlaying == false {
                break
            }
            try await Task.sleep(nanoseconds: 150_000_000)
        }
    }

    private static func fetchVolcengineAudio(text: String, config: VolcengineTTSConfig) async throws -> Data {
        var request = URLRequest(url: URL(string: "https://openspeech.bytedance.com/api/v1/tts")!)
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer;\(config.accessToken.trimmingCharacters(in: .whitespacesAndNewlines))", forHTTPHeaderField: "Authorization")

        let payload = VolcengineTTSRequest(
            app: VolcengineTTSRequest.App(
                appid: config.appID.trimmingCharacters(in: .whitespacesAndNewlines),
                token: config.accessToken.trimmingCharacters(in: .whitespacesAndNewlines),
                cluster: config.cluster.trimmingCharacters(in: .whitespacesAndNewlines)
            ),
            user: VolcengineTTSRequest.User(uid: "rhetorix-ios"),
            audio: VolcengineTTSRequest.Audio(
                voice_type: config.voiceType.trimmingCharacters(in: .whitespacesAndNewlines),
                encoding: "mp3",
                speed_ratio: config.speedRatio,
                volume_ratio: 1.0,
                pitch_ratio: 1.0
            ),
            request: VolcengineTTSRequest.Request(
                reqid: UUID().uuidString,
                text: text,
                text_type: "plain",
                operation: "query"
            )
        )
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let decoded = try JSONDecoder().decode(VolcengineTTSResponse.self, from: data)
        guard let audio = decoded.data, let audioData = Data(base64Encoded: audio), audioData.isEmpty == false else {
            throw NSError(domain: "VolcengineTTS", code: decoded.code ?? -1, userInfo: [NSLocalizedDescriptionKey: decoded.message ?? "Volcengine returned no audio data."])
        }
        return audioData
    }

    private static func fetchVoiceboxAudio(text: String, usesChinese: Bool, config: VoiceboxTTSConfig) async throws -> Data {
        let base = config.baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard var components = URLComponents(string: base) else {
            throw URLError(.badURL)
        }
        let basePath = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        components.path = "/" + ([basePath, "generate", "stream"].filter { $0.isEmpty == false }.joined(separator: "/"))
        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("audio/wav", forHTTPHeaderField: "Accept")

        let payload = VoiceboxTTSRequest(
            profile_id: config.profileID.trimmingCharacters(in: .whitespacesAndNewlines),
            text: text,
            language: usesChinese ? "zh" : "en",
            model_size: config.modelSize,
            engine: config.engine,
            normalize: true
        )
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        guard data.isEmpty == false else {
            throw URLError(.zeroByteResource)
        }
        return data
    }

    private struct VolcengineTTSRequest: Encodable {
        var app: App
        var user: User
        var audio: Audio
        var request: Request

        struct App: Encodable {
            var appid: String
            var token: String
            var cluster: String
        }

        struct User: Encodable {
            var uid: String
        }

        struct Audio: Encodable {
            var voice_type: String
            var encoding: String
            var speed_ratio: Double
            var volume_ratio: Double
            var pitch_ratio: Double
        }

        struct Request: Encodable {
            var reqid: String
            var text: String
            var text_type: String
            var operation: String
        }
    }

    private struct VolcengineTTSResponse: Decodable {
        var code: Int?
        var message: String?
        var data: String?
    }

    private struct VoiceboxTTSRequest: Encodable {
        var profile_id: String
        var text: String
        var language: String
        var model_size: String
        var engine: String
        var normalize: Bool
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.pendingUtteranceCount = 0
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
    @State private var inputText = ""
    @State private var issues: [ConstructiveAnalysisIssue] = []
    @State private var selectedIssueID: String?
    @State private var isAnalyzingPaste = false
    @State private var pendingLiveSegments: Set<String> = []
    @State private var analyzedLiveSegments: Set<String> = []

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                GlassCard(accent: RhetorixColors.cyan) {
                    VStack(alignment: .leading, spacing: 10) {
                        Label(store.t("Paste constructive speech"), systemImage: "doc.text")
                            .font(.headline)
                        TextEditor(text: $inputText)
                            .frame(minHeight: 150)
                            .scrollContentBackground(.hidden)
                            .padding(4)
                            .rhetorixField()
                            .accessibilityIdentifier("constructive.input")
                        Button {
                            Task {
                                isAnalyzingPaste = true
                                issues = await store.analyzeConstructive(text: inputText, provider: store.preferredProvider)
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
                let newIssues = await store.analyzeConstructive(text: segment, provider: store.preferredProvider, setWorking: false)
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
    @State private var results: [FallacyFinding] = []
    @State private var isAnalyzing = false
    @State private var hasAnalyzed = false

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                TextEditor(text: $text)
                    .frame(minHeight: 160)
                    .scrollContentBackground(.hidden)
                    .padding(4)
                    .rhetorixField()
                    .accessibilityIdentifier("fallacy.input")
                Button(store.t("Analyze for Fallacies")) {
                    Task {
                        hasAnalyzed = false
                        isAnalyzing = true
                        results = await store.generateFallacies(text: text, provider: store.preferredProvider)
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
    @State private var customTopicTitle = ""
    @State private var customTopicDetails = ""
    @State private var prompt = ""
    @State private var response = ""
    @State private var attempt: RebuttalAttempt?
    @State private var isGeneratingPrompt = false
    @State private var isScoring = false
    @State private var isAddingCustomTopic = false
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
                        RhetorixMenuField(
                            title: store.t("Topic"),
                            options: [(Optional<DebateTopic>.none, store.t("Choose a Topic"))]
                                + store.topics.map { (Optional($0), store.topicTitle($0)) },
                            selection: $topic
                        )
                        Divider().overlay(RhetorixColors.textTertiary.opacity(0.35))
                        Text(store.t("Use a custom topic"))
                            .font(.subheadline.bold())
                            .foregroundStyle(RhetorixColors.textPrimary)
                        TextField(store.t("Topic title"), text: $customTopicTitle)
                            .textInputAutocapitalization(.sentences)
                            .autocorrectionDisabled(false)
                            .textFieldStyle(.plain)
                            .rhetorixField()
                        TextField(store.t("Optional details"), text: $customTopicDetails)
                            .textInputAutocapitalization(.sentences)
                            .autocorrectionDisabled(false)
                            .textFieldStyle(.plain)
                            .rhetorixField()
                        Button {
                            Task { await addCustomRebuttalTopic() }
                        } label: {
                            HStack {
                                if isAddingCustomTopic {
                                    ProgressView()
                                } else {
                                    Image(systemName: "plus.circle.fill")
                                }
                                Text(isAddingCustomTopic ? store.t("Checking...") : store.t("Add Custom Topic"))
                            }
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(isAddingCustomTopic || customTopicTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
                            AIMarkdownText(prompt)
                            AIDisclaimer()
                        }
                    }
                    TextEditor(text: $response)
                        .frame(height: 160)
                        .scrollContentBackground(.hidden)
                        .padding(4)
                        .rhetorixField()
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
                            AIMarkdownText(attempt.feedback)
                            AIDisclaimer()
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(store.t("Rebuttal Trainer"))
        .navigationBarTitleDisplayMode(.inline)
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
        prompt = await store.generateRebuttalPrompt(topic: topic, side: .oppose, provider: store.preferredProvider)
        startedAt = prompt.isEmpty ? nil : Date()
        isGeneratingPrompt = false
    }

    private func addCustomRebuttalTopic() async {
        isAddingCustomTopic = true
        defer { isAddingCustomTopic = false }
        guard let created = await store.addCustomTopicAfterSafetyCheck(title: customTopicTitle, details: customTopicDetails) else { return }
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
        attempt = await store.scoreRebuttal(topic: topic, prompt: prompt, response: response, provider: store.preferredProvider)
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
