# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Rhetorix is a local-first SwiftUI iPhone app for AI debate training: timed debates against an AI opponent, a five-skill judge rubric, a guided skill-path curriculum, and preparation tools. BYOK (bring your own key) multi-provider AI. Bilingual English / Simplified Chinese.

## Commands

`xcodebuild` requires the full Xcode toolchain; this machine's default developer dir is CommandLineTools, so prefix every invocation with `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`.

```bash
# Build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project Rhetorix.xcodeproj -scheme Rhetorix \
  -destination 'platform=iOS Simulator,name=iPhone 17' build

# Full UI test suite (the only test target; no unit tests)
DEVELOPER_DIR=... xcodebuild -project Rhetorix.xcodeproj -scheme Rhetorix \
  -destination 'platform=iOS Simulator,name=iPhone 17' test

# Single test
... test -only-testing:RhetorixUITests/RhetorixUITests/testDebateHappyPathCreatesJudgment

# Screenshot tour for visual QA (writes PNGs of every key screen; add
# TEST_RUNNER_SHOT_THEME=light for the light theme)
TEST_RUNNER_SHOT_DIR=/path/to/output DEVELOPER_DIR=... xcodebuild ... \
  test -only-testing:RhetorixUITests/RhetorixUITests/testScreenshotTour

# Clean the app's local store after test runs (bundle id is com.rhetorix.ios — NOT .app)
DEVELOPER_DIR=... xcrun simctl get_app_container <SIM_UDID> com.rhetorix.ios data \
  | xargs -I{} rm -f "{}/Documents/rhetorix-store.json"

# App Store archive (needs paid Apple Developer team)
TEAM_ID=XXXXXXXXXX ./Scripts/archive.sh
```

## Workflow (standing instructions from the repo owner)

- **Every change is its own branch off `main`, built, run through the full UI test suite, and opened as a GitHub PR** (`gh pr create`). The owner reviews and merges; do not merge yourself.
- **Update `mac-UI.md` for every UI change.** It is the designer-facing brief and the source of truth for visual/product rules (restraint rules, color roles, per-screen behavior). Despite the name, it documents the iPhone app.
- **Clean the simulator store after test runs.** UI tests and the owner's manual testing share the same simulator app container; leftover seeded fixtures (topic title "UI test fixture — ignore") pollute manual sessions.
- **Verify visual work with the screenshot tour** and actually look at the PNGs before claiming a UI change works. The owner judges by simulator appearance; "mature = restraint" (no accent-colored text labels, one filled-accent control per screen, neutral states stay neutral).

## Architecture

Seven source files, no package dependencies, no backend. Everything routes through one `@MainActor ObservableObject`:

- **`AppStore.swift`** — the single store: all published state, business logic (debate flow, judging, skill-path mastery, memory/recommendation engines), JSON persistence, and UI-test fixture seeding. Injected as `@EnvironmentObject` everywhere.
- **`Screens.swift`** — every view. One `NavigationStack` whose root is the `TabView`; all pushed screens go through the `AppRoute` enum + `navigationDestination`. The root `.tint` is on the NavigationStack so pushed screens inherit it.
- **`Models.swift`** — enums and Codable models. Enum raw values are user-facing English strings that double as persistence values and localization keys.
- **`Theme.swift`** — design system: `RhetorixColors` role tokens (`brand`/`success`/`warning`/`danger`; legacy hue names `cyan`/`amber`/`peach`/`green`/`salmon` are aliases onto the roles), `GlassCard` (neutral border by default, `emphasized:` for the tinted border), `AppBackdrop` (glow only when `isLive`, used by Live Debate), `.rhetorixPrimary` button style, chips/fields/markdown.
- **`AIService.swift`** — stateless provider calls: OpenAI-compatible chat (also covers DeepSeek/Groq), Anthropic, Gemini, plus the content-safety layer (`assertSafe`) that classifies user prompts and AI output before display/storage and blocks on any failure.
- **`Localization.swift`** — hand-rolled localization: `store.t("English string")` looks up a zh-CN dictionary. No system `.strings` files. **Every new user-facing string needs a dictionary entry**, and pluralization/count strings need helpers (see `debateCountText`).
- **`KeychainStore.swift`** — API keys only; everything else lives in the JSON snapshot.

### Persistence — the one dangerous invariant

State persists as a single JSON snapshot (`Documents/rhetorix-store.json`) decoded in `AppStore.load()` **with `try?`** — any decode error silently discards the entire snapshot, i.e. wipes all user data. Consequences:

- **Never rename an enum raw value or remove a case without a tolerant `init(from:)`** mapping legacy/unknown values (see `AiProvider` and `AppTheme` for the pattern).
- New snapshot fields must be optional with defaults applied on load.
- Verify migrations by planting a legacy snapshot in the simulator container and relaunching (check data survives), not just by compiling.

### Theming

- The app pins its own light/dark theme via Settings (`AppTheme` → `preferredColorScheme`) and **ignores the system appearance** — `simctl ui appearance` has no effect; use the `UITEST_THEME_LIGHT` launch arg or the Settings picker.
- Dark is a neutral near-black with solid elevated card panels; light is cool paper-white; single teal brand accent. Exact values and restraint rules live in `mac-UI.md`'s Color System section.
- The asset-catalog `AccentColor` must stay in sync with `RhetorixColors.brand` — it is the fallback tint for anything the explicit tint doesn't reach.

### UI tests

`RhetorixUITests/RhetorixUITests.swift` is the entire test surface. Tests drive the real app with launch arguments handled in `AppStore.init`:

- `UITEST_MODE` — mock AI responses (no network), seeded provider config.
- `UITEST_RESET_DATA` — wipe the store on launch.
- `UITEST_SEED_*` — fixtures for skill-path/memory states (`JUDGED`, `JUDGED_ONCE`, `MASTERED`, `MASTERED_RESUMED`, `GUIDED_MASTERY`, `WEAK_DELIVERY`); all seeded sessions use the unmistakable topic "UI test fixture — ignore".
- `UITEST_THEME_LIGHT` — start in the light theme.

When product-logic rules change (mastery, gating, rotation), pin them with a seeded UI test; when fixing a bug found by review, verify the test fails on the pre-fix code (mutation check) before trusting it.

### Domain rules worth knowing before touching logic

- Skill path: `AppStore.skillPath` order; mastery = coach score ≥4 in two judged debates (`masteryConfirmations`) or one guided practice focused on that skill; path position derives only from mastery, never from manual node selection; post-completion review rotates by judging time (`result.createdAt`), not session creation order.
- Memory: inferred signals unlock at `hasInferenceEvidence` (2 completed debates or 4 user turns) — every surface must show the same locked/unlocked state; recommendations additionally require `memoryProfile.hasEnoughData` (2 sessions). AI-vs-AI sessions are excluded from preference signals.
- Safety: all AI-bound and AI-produced text goes through `assertSafe`; blocked or failed checks must never render or persist, and the user-facing failure string is fixed (`内容安全检测服务异常，请稍后重试`).

## Other docs

`README.md` (Chinese, product + build), `PRODUCT_PLAN.md`, `UNLANDED_BACKLOG.md` (update statuses when landing backlog work), `REAL_DEVICE_VERIFICATION.md` (physical-device checklist), `APP_STORE.md` (submission kit), `PRIVACY.md`.
