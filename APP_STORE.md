# App Store Submission Kit

Everything needed to take Rhetorix from repo to TestFlight to the App Store. Repo-side prerequisites (privacy manifest, export-compliance key, permission strings, archive script) are already in place; this file is the operator's checklist plus ready-to-paste metadata.

## One-time account setup

1. Enroll in the Apple Developer Program (Individual, $99/year) at developer.apple.com. Requires an Apple ID with two-factor auth; approval is usually within 48 hours.
2. In Xcode > Settings > Accounts, sign in with the enrolled Apple ID.
3. In App Store Connect > Business, sign the **Paid Applications Agreement** and complete banking/tax info now, even before selling anything — it clears asynchronously and unblocks future in-app purchases.
4. In App Store Connect, create the app record: platform iOS, bundle ID `com.rhetorix.ios`, name **Rhetorix** (names are globally unique — if taken, fall back to "Rhetorix — AI Debate Coach").

## Ready-to-paste metadata

**Name:** Rhetorix

**Subtitle (EN):** AI debate sparring and coaching
**Subtitle (zh-Hans):** AI 辩论陪练与教练

**Category:** Education (primary), Productivity (secondary)

**Keywords (EN):** `debate,argument,rhetoric,public speaking,speech,persuasion,rebuttal,critical thinking,coach`
**Keywords (zh-Hans):** `辩论,口才,演讲,思辨,反驳,论证,公共演说,陪练,批判性思维`

**Description (EN):**

> Rhetorix turns your phone into a debate sparring partner.
>
> Pick a motion, take a side, and argue against an AI opponent under real stage timers — then get judged on a five-skill coach rubric: argument structure, evidence, direct clash, impact weighing, and delivery. A guided skill path teaches one micro-skill at a time and tracks your mastery from debate to debate.
>
> - Timed debates in structured (World Schools style) or free-flow format
> - Voice-first: speak your speeches, live transcription, spoken AI replies
> - AI judge with evidence-quoted feedback and a retry mode for your weakest speech
> - Guided practice: learn a move, drill it in a real round, get coached
> - Preparation tools: constructive analysis, fallacy detector, rebuttal trainer
> - Local-first and private: your history stays on your device; bring your own AI provider key (OpenAI, Anthropic, Google, DeepSeek, Groq)
> - Full English and 简体中文 support
>
> Built for debate students, coaches, and anyone who wants to argue better.

**Description (zh-Hans):**

> Rhetorix 把你的手机变成一位辩论陪练。
>
> 选择辩题、选定立场，在真实的阶段计时下与 AI 对手交锋；赛后由 AI 评委按五项能力打分：论证结构、论据、正面交锋、影响比较与表达。技能路径带你逐项练习并跟踪掌握进度。
>
> - 结构化（世界学校辩论制）或自由模式的计时辩论
> - 语音优先：口头发言、实时转写、AI 语音回应
> - AI 评审给出引用证据的反馈，并可针对最弱的一次发言重新演练
> - 引导式练习：学一个技巧，实战演练，获得点评
> - 备赛工具：立论分析、谬误检测、反驳训练
> - 本地优先、注重隐私：历史仅存于设备；自带 AI 服务商密钥（OpenAI、Anthropic、Google、DeepSeek、Groq）
> - 完整中英双语支持

**Support URL:** the GitHub repo. **Privacy Policy URL:** publish `PRIVACY.md` via GitHub Pages (repo Settings > Pages > deploy from branch, then use `https://zha-chicken.github.io/Rhetorix-iOS/PRIVACY`) or link the raw file.

## App Privacy questionnaire

Answer **"Data Not Collected"** for everything. The app has no accounts, analytics, tracking, or servers; user-entered API keys stay in the Keychain, and AI text goes directly to the user's own configured provider. `PrivacyInfo.xcprivacy` in the bundle matches these answers (no tracking, no collected data, no required-reason APIs).

## Age rating

Answer the questionnaire truthfully — all "None" except set **unrestricted web access: No**. Expect a 4+ or 9+ result. Note for AI content: Rhetorix runs a safety check on user prompts and AI output before display/storage and blocks unsafe content; say exactly that if App Review asks about AI-generated content (Guideline 1.2).

## Export compliance

Already handled: `ITSAppUsesNonExemptEncryption = NO` is set in Info.plist (the app uses only standard HTTPS), so no per-build compliance questions.

## Screenshots

Apple requires 6.9" iPhone screenshots (1320×2868, e.g. iPhone 17 Pro Max simulator). Generate them with the screenshot tour:

```bash
# once per theme; add a zh run by switching app language first if desired
TEST_RUNNER_SHOT_DIR=$PWD/build/shots-dark \
xcodebuild -project Rhetorix.xcodeproj -scheme Rhetorix \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  test -only-testing:RhetorixUITests/RhetorixUITests/testScreenshotTour

TEST_RUNNER_SHOT_THEME=light TEST_RUNNER_SHOT_DIR=$PWD/build/shots-light \
xcodebuild -project Rhetorix.xcodeproj -scheme Rhetorix \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  test -only-testing:RhetorixUITests/RhetorixUITests/testScreenshotTour
```

For a clean status bar first run:
`xcrun simctl status_bar booted override --time 9:41 --batteryState charged --batteryLevel 100 --cellularBars 4 --wifiBars 3`

Best storefront picks from the tour: Home (01), Guided Practice (03), Live Debate (05), Debate Setup (07), Settings (10). Screenshots must show the app as shipped — no seeded "UI test fixture" rows; take store shots from a fresh launch after completing onboarding manually, or crop the tour shots that don't show fixture data.

## App Review notes (paste into the review notes field)

> Rhetorix is a bring-your-own-key app: AI features require the reviewer to enter an API key under Settings > AI Providers. A demo key is provided below (limited quota, valid through review):
>
> `OpenAI key: <CREATE A LOW-LIMIT KEY AND PASTE IT HERE>`
>
> Without a key the app still demonstrates navigation, guided practice content, the skill path, history, and settings. Microphone/speech permissions power voice input for debates; all user data is stored on-device only. User prompts and AI output pass a content-safety check before display.

Create that key fresh, set a low monthly limit, and revoke it after approval.

## Ship sequence

1. Real-device pass: work through `REAL_DEVICE_VERIFICATION.md` on a physical iPhone (free provisioning is fine for this).
2. `TEAM_ID=XXXXXXXXXX ./Scripts/archive.sh` → upload the archive via Xcode Organizer.
3. TestFlight: internal testing needs no review; add friends via email, collect a round of feedback.
4. Fill in metadata above, attach screenshots, submit for review. First reviews typically take 1–3 days; rejections are usually fixable metadata issues, not death sentences.
5. Release manually (recommended for v1) so launch timing is yours.
