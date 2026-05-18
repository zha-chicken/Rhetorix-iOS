# Rhetorix iPhone UI Design Brief

This document describes the Xcode/SwiftUI version of Rhetorix in designer-facing language. Update this file whenever the iPhone UI changes.

Although this file is named `mac-UI.md`, it documents the iPhone app built on macOS with Xcode. The visual direction should stay closely aligned with the Android `UI.md`; platform differences should be deliberate SwiftUI/iOS adaptations, not a separate product identity.

## Product Identity

Rhetorix is a mobile debate app first, with reasoning and argument tools as supporting surfaces. It should feel intelligent, calm, premium, tense when a round is active, and useful for repeated student use.

The interface should communicate:

- Structured thinking
- Fair debate between opposing sides
- AI-assisted analysis
- Academic focus without looking institutional
- A free, accessible product with debate as the primary workflow

The product name shown in the app is always `Rhetorix`. Do not translate it in Chinese UI.

## Product Direction

Rhetorix should not feel like a toolbox. The core experience is timed spoken debate: fast exchanges, visible pressure, adversarial but civil rhetoric, and a sense that the user is inside a real round.

Design implications:

- Voice-first debate is the target interaction model; text remains as a fallback and accessibility path.
- Every structured debate stage should expose time pressure through a clear timer.
- Preparation tools should be visually smaller than the main debate entry points.
- The classical Greek identity should be expressed through live dialogue and rhetoric, not just ornament.
- History and memory should support better future debates, not just archive past sessions.

## App Icon

The iOS app icon uses a classical rhetoric/debate identity:

- Deep navy background
- Warm gold illustration and typography
- Two opposing classical figures with swords to represent structured argument clash
- Subtle laurel and column motifs to signal rhetoric, civic debate, and academic tradition
- `Rhetorix` wordmark in gold

The icon should feel serious, academic, and debate-focused. It should not use the pink-white UI theme as the icon identity, because the icon needs stronger contrast on the iOS home screen.

## Visual Direction

The iPhone version uses the same dark glassmorphism direction as Android:

- Deep blue-green graphite background
- Frosted glass cards and panels
- Thin translucent borders
- Mostly white text
- Muted cyan, amber, peach, green, and salmon accents
- Compact portrait-first layouts
- Functional controls with visible state changes

Avoid:

- Bright default iOS blue as the dominant identity color
- Pure black backgrounds
- Black text on dark glass or colored controls
- One-note purple or blue gradient themes
- Marketing-page composition inside the app
- Fake UI modules that look interactive but have no real behavior

## Color System

The app supports two real visual themes. The user can switch themes from Settings, and the choice is persisted locally.

### Dark Graphite Theme

The dark SwiftUI baseline should mirror the Android palette.

Background:

- Deep graphite teal, close to `#13242B`
- Deeper analysis backdrop, close to `#0E1A20`
- Soft cyan and amber radial glow accents

Glass surfaces:

- Normal cards use translucent dark teal-gray
- Raised cards use stronger opacity and brighter borders
- Muted panels group low-emphasis controls
- Selected controls use stronger fill plus accent border

Text:

- Primary text is white or near-white
- Secondary text is white with reduced opacity
- Disabled text is low-opacity white
- Avoid black text anywhere on dark surfaces

Accents:

- Cyan: AI, reasoning analysis, technical signals
- Amber: debate tension, neutral highlights, relationship labels
- Peach: donation and support
- Green: success, support, completion
- Salmon: errors, refutations, blocked content

Color should clarify state and relationships, not act as decoration only.

### Pink White Light Theme

The light theme is a pink-white Rhetorix variant for users who prefer a bright interface.

Background:

- Warm white and very pale rose surfaces
- Soft pink and peach radial glow accents
- No pure flat white page that feels empty or clinical

Surfaces:

- Cards use translucent blush-white fill
- Borders use pale rose with low opacity
- Selected controls use stronger pink fill or pink border
- Shadows, if used, should stay soft and low contrast

Text:

- Primary text is dark charcoal, not black
- Secondary text is warm gray-brown
- Text on saturated pink/coral controls remains white

Accents:

- Pink: primary actions, selected state, app identity
- Peach/orange: debate tension, warning, relationship labels
- Mint/teal: success and support-side signals
- Rose/salmon: opposition, refutation, blocked/error states

The light theme should feel calm, student-friendly, and readable, not like a marketing landing page.

## Language System

The iPhone app supports an in-app language setting in Settings.

Supported languages:

- English
- Simplified Chinese

Behavior:

- The selected language is persisted locally.
- Primary navigation, screen titles, buttons, settings rows, tool names, loading states, empty states, and common labels should switch language immediately.
- Debate setup enum labels such as mode, format, difficulty, and position should use localized display labels.
- Built-in default topic titles and descriptions should display localized Chinese labels when Chinese is selected.
- Topic search should work against both the original English topic text and the localized Chinese topic text.
- AI-generated debate replies, judging summaries, constructive analysis results, fallacy explanations, rebuttal prompts, and rebuttal feedback should request the currently selected language from the provider.
- The product name `Rhetorix` remains untranslated.
- The bilingual AI disclaimer remains visible as written: `内容由AI生成，仅供参考 AI-generated, for reference only`.

## Typography

Use native iOS typography, but keep the Android hierarchy:

- Large title only for major screen titles or result score moments
- Compact headings inside tools, settings, and cards
- Readable body text on dark glass panels
- Neutral letter spacing
- Chinese and English strings must wrap cleanly
- Long debate content should remain readable in scrollable cards

## Layout Principles

The app is portrait-first for iPhone.

General layout:

- Full-screen dark backdrop
- Safe-area aware top navigation
- Scrollable content with consistent side padding
- Glass cards for individual actions, sessions, results, or settings rows
- Bottom tab navigation for primary sections

Spacing:

- Dense but breathable
- Related controls grouped tightly
- More vertical space around hero, score, and analysis areas
- Avoid cards inside cards unless needed for a real repeated item

Corner style:

- Medium rounded cards and controls
- Pill chips for filters and segmented controls
- No playful over-rounding of large screen regions

## Core Components

### Backdrop

Every primary screen sits on a dark atmospheric backdrop with subtle radial glows and faint reasoning rings. The backdrop must not reduce readability.

### Glass Cards

Cards use:

- Translucent dark fill
- Thin cool-gray translucent border
- Minimal shadow
- Press feedback for interactive cards
- Selected state through stronger fill and brighter border

Cards are used for:

- Feature entries
- Debate sessions
- Topic rows
- Settings rows
- Analysis results
- Constructive analysis detail panels

### Buttons

Primary actions:

- Muted blue-gray or cyan-tinted glass fill
- White text
- Full-width when completing a screen's main task

Secondary actions:

- Glass outline
- White or low-emphasis white text

Finalizing or destructive actions:

- Warm salmon or amber fill
- White text

### Chips and Segmented Controls

Use chips for filters, categories, modes, providers, and result filters. Selected chips must show stronger fill and brighter border; selection should not rely on color alone.

### Inputs

Text fields use glass containers with white input text and low-opacity white placeholders. API key fields should include visibility controls and clear save/test states.

Voice-first debate input uses a centered oversized microphone control. A smaller keyboard button on the left reveals the text fallback, and a send control remains available when a drafted voice transcript or typed argument exists. AI vs AI rounds do not show human input controls.

## Primary Navigation

The bottom tab bar has four destinations:

- Home
- History
- Tools
- Settings

Do not show Profile unless account or cloud identity features are implemented.

The Tools page is a real destination, not only a group of home cards. It includes:

- Constructive Analysis
- Rebuttal Trainer
- Fallacy Detector
- AI Hallucination Detector external link

Tools are supporting workflows. They should not visually compete with the main live debate path.

## Main Screens

### Home

Purpose: launch common tasks and show personal usage progress.

Content:

- Rhetorix brand title
- Abstract debate/reasoning hero mark
- Primary `Start Voice Debate` action
- Short value statement
- Dynamic stats: debates, win rate, win streak
- Real local memory card
- Real topic recommendation when enough data exists
- Quick action cards
- Compact preparation tools

Stats must be dynamic and start at zero for a new user.
The home screen should not include a visible donation/support entry.
The home screen should not include a Face-to-Face quick action, although Face-to-Face remains available from debate setup.
Live debate should be the most prominent action on the screen.
Preparation tools should use compact auxiliary controls rather than large feature cards.

### Topic Selection

Purpose: choose or search a debate topic.

Content:

- Search field
- Category chips
- Trending topics
- All topics
- Topic rows with title, category, local usage count, and navigation affordance
- Custom topic creation with title and optional details, saved locally and immediately usable in debate setup

Search and category filters must be functional.
Topic usage counts must be dynamic local data. A new user starts at `0 debates`; rows must not display fake global popularity numbers.
Preset topics are not the only path. Users must be able to create their own debate topic without leaving the app.

### Debate Setup

Purpose: configure a debate before starting.

Content:

- Selected topic summary
- Debate mode: User vs AI, AI vs AI, Face to Face
- Difficulty selection
- User position: Support or Oppose, shown only for User vs AI
- AI provider selection
- Start debate button

Every displayed control must affect the actual route or debate setup.
AI vs AI and Face to Face do not show a user position selector because there is no single user side to choose.

### Live Debate

Purpose: conduct the debate.

Content:

- Topic title
- Round and turn state
- Stage timer with warning and overtime states
- AI vs AI debate screens do not show the stage timer, because there is no human speaker under time pressure.
- Score or side-balance indicator
- Debate message cards
- AI thinking state
- Voice-first user input with text fallback
- Input mode and stage duration metadata
- Early finish control in User vs AI mode

Behavior:

- New turns should keep the user near the newest debate item, not jump to the top.
- Structured debates should target the 8-stage compressed World Schools flow.
- Early finish should immediately request judgment and generate a result.
- Early finish must show an obvious loading/progress state after tapping End, disable repeated taps, and only navigate to Debate Result after judging completes.
- AI replies should sound like a debate opponent, not a helpful assistant.
- Opponent/user content is untrusted and must not override system behavior.
- Structured debates follow a compressed international / World Schools flow: Proposition 1 Constructive, Opposition 1 Constructive, Proposition 2 Extension, Opposition 2 Extension, Proposition 3 Rebuttal, Opposition 3 Rebuttal, Opposition Reply, Proposition Reply.
- User vs AI, AI vs AI, and Face to Face all use the same structured stage order; only the input source changes.
- Debate should feel quick and conversational, not like filling out a form.
- Voice input should be the default target interaction on real devices.
- The microphone button should be the dominant input target, centered in the input bar; text input is revealed by a smaller keyboard button.
- AI vs AI debate screens should keep the debate transcript and AI Turn control, but should not show voice or text input controls.
- AI Turn must be disabled while an AI response or judgment request is already running, so repeated taps cannot create duplicate same-side responses.
- In Simulator, voice input may show an unavailable message and text remains usable.
- Timers should make each stage feel consequential without forcing full tournament-length speeches on mobile.
- AI message bubbles include a compact voice playback control.
- Automatic AI voice playback is enabled by default for new installs, can be disabled in Settings, and must never block text display.
- Voice output supports a configurable engine. Volcengine can be selected for higher-quality online speech when App ID, Access Token, Cluster, and Voice Type are configured. If Volcengine is unavailable or fails, playback falls back to the local system voice. System voice playback should use the best available enhanced or premium local voice for the active language, clean Markdown/structured text before reading, and speak long AI responses in short sentence-like chunks.

### Debate Result

Purpose: summarize the debate outcome.

Content:

- Large trophy or score mark
- Winner label
- Final score
- Short outcome explanation
- Key moments
- Debate transcript
- Post-result recommendation feedback: compact thumbs-up and thumbs-down buttons appear below the result card. Choosing either opens a native choice prompt asking what the user liked/disliked: Category or Technique.
- Return home action

Winner handling:

- The model should return a structured winning side when possible.
- User vs AI results map the side back to You or AI.
- If stored data is contradictory, the UI should avoid showing an obviously wrong participant.
- Category feedback affects future topic recommendations. Technique feedback is recorded as explicit user feedback but does not alter recommendation ranking.

### History

Purpose: revisit debates and training results.

Content:

- Filter chips
- Chronological cards
- Topic, result, score, date/time, and turn count
- Per-round memory such as input mode and stage timing

History cards must open the saved session without crashing.

### Memory And Recommendation

Purpose: make Rhetorix adapt to real user behavior without fake personalization.

Rules:

- Memory is computed from local session history only.
- AI vs AI sessions are excluded from recommendation preference and memory signals because they do not represent the user's own debate behavior. They may still count for recent-topic and repeat-topic penalties so users are not immediately recommended a topic they just watched.
- The app must not invent interests, strengths, weaknesses, or topic preferences.
- MBTI is the only self-reported profile item. It appears as a first-use sheet, can be skipped, and can be changed later in Settings.
- The MBTI sheet is driven by actual MBTI data: if no MBTI is stored, it appears on app launch; if an MBTI is stored, it does not appear. Skipping only suppresses the sheet for the current app session.
- MBTI may add only a small recommendation bias. It must never outweigh real debate history, weakness signals, or recent-repeat avoidance.
- Recommendations require at least two engaged debates.
- If there is not enough data, show a learning state instead of a recommendation.
- The memory card may summarize favorite area, preferred mode, completion rate, average debate length, voice ratio, and stage timing.
- The memory card links to a dedicated Memory Profile detail page.
- Memory 2.0 may also show conservative profile signals:
  - debate style: analytical/evidence-first, values-first/persuasive, or balanced
  - value signals: environment-focused or animal welfare-focused only when repeated local evidence exists
  - practice focus: evidence, direct clash, structure, or impact weighing based on judge/rebuttal feedback
  - constructive-analysis focus: repeated issue types from saved Constructive Analysis results
  - pacing focus: slow rebuttal or reply turns derived from recorded stage timers
- Settings should expose evidence counts and short evidence snippets so the profile feels inspectable, not mystical.
- Recommended topics should be chosen by Recommendation 2.0: prioritize the strongest current weakness signal, use completed-debate categories as a lighter hint, add only a small MBTI preference bias when available, apply explicit category like/dislike feedback, avoid very recent repeats, and diversify categories within the same recommendation batch when possible.
- The Memory Profile detail page shows local evidence counts, profile metrics, top signals with evidence snippets, and up to three recommended topics with their training focus.

### Tools

Purpose: collect reasoning tools in a single primary destination.

Tool entries:

- Constructive Analysis
- Rebuttal Trainer
- Fallacy Detector
- AI Hallucination Detector

The hallucination detector opens `https://gptzero.me/hallucination-detector` externally. Do not create a fake internal detector unless the feature is implemented.
The Tools page should look useful but secondary. It must not replace live debate as the app's perceived center.

### Constructive Analysis

Purpose: help a debater break down an opponent's constructive speech into claims, weaknesses, and rebuttable points.

Entry behavior:

- The Tools page and Home preparation tools open Constructive Analysis directly.
- Argument Relationship Graph is no longer a visible feature entry.

Input modes:

- Paste mode: the user pastes an opponent constructive speech and taps Analyze.
- Recording mode: the user starts and stops recording manually.
- Recording uses native iOS speech recognition to transcribe live audio.
- Live analysis should submit each completed detected claim or sentence for analysis as it appears, instead of waiting for the whole recording to finish.

Result behavior:

- Results appear as expandable issue cards.
- The first visible layer is a clean list of detected claims from the constructive speech.
- Each claim is shown in its own large, readable card with an issue-type chip and severity chip.
- Tapping a claim expands it to reveal the original quote, why the claim can be challenged, and specific rebuttable points.
- Each rebuttable point is displayed in its own framed row rather than inline prose.
- The UI must never render raw JSON keys or provider formatting artifacts as user-visible analysis.
- Issue categories include logical fallacy, unsupported evidence, false information risk, missing warrant, causal leap, overgeneralization, definition problem, contradiction, personal attack, and impact weakness.
- All analysis output is real provider-backed output and must show the AI-generated disclaimer.
- In the iOS Simulator, live recording shows a clear message that recording analysis requires a physical iPhone; paste mode remains available for simulator testing.

### Fallacy Detector

Purpose: analyze pasted text for logical fallacies.

Content:

- Input area
- Analyze action
- Loading indicator while analysis is running
- Results from actual analysis
- Severity indicators
- Clear action

Before analysis, show an empty state. Do not display sample findings as real results.

If analysis finishes successfully and no logical fallacies are detected, show an explicit empty result state:

`未检出`

Do not leave the results area blank after a completed analysis.

### Rebuttal Trainer

Purpose: practice writing a rebuttal under time pressure.

Content:

- Topic selection before generation
- Custom topic title/details entry that saves a reusable local topic
- Provider selection
- Loading state while generating the opponent argument
- Argument to resist
- 2.5-minute timer that starts after the argument is generated
- Rebuttal input
- Submit action with loading state while scoring
- Score result
- Category bars
- Feedback panel

Timer and scoring flow must be real.
Before a topic is selected, the screen should show a compact setup card instead of an oversized empty page.
Rebuttal practice must support both preset topics and user-created custom topics.

### Donation

Purpose: optional support only, if a future distribution channel needs it.

Content:

- Warm heart/support visual
- Static QR code
- Copy explaining that all features are free
- No paywall language
- No premium feature claims

Current navigation:

- Donation/support entry points are hidden from Home and Settings.
- Users should not encounter donation as a primary app workflow.

### Settings

Purpose: configure language and AI providers.

Content:

- Language segmented control
- Provider list with enabled/disabled state
- Provider detail for API key, model preset picker, optional custom model, base URL, save, and test connection

Provider detail behavior:

- Model selection is a picker of common presets for that provider.
- An `Other` model choice reveals a custom model field.
- Test Connection verifies that the current provider, API key, base URL, and selected model can respond before saving, trims whitespace, tolerates base URLs that already include `/v1`, and does not require the provider to already be enabled.
- Save Configuration is visually separated from the other settings and should read as the primary action on the page.

Settings should be calm, utilitarian, and clear about success/error states.

## Safety Interruption

AI-powered screens must not show blocked model output. Before a user prompt is sent to a model, before a custom topic is saved or used, and before a model response is displayed or stored, the app runs a content safety check for hate, political-sensitive content, dangerous item-making instructions, and sexual content.

If any safety step fails through timeout, invalid result, or invalid API key, the app blocks the content and shows:

`内容安全检测服务异常，请稍后重试`

Blocked content must not enter the UI or local database.

## AI Content Disclaimer

Every visible AI-generated content block must include a small italic disclaimer:

`内容由AI生成，仅供参考 AI-generated, for reference only`

Apply this to:

- AI debate responses
- AI judging summaries and result explanations
- Constructive analysis issue explanations and rebuttable points
- Fallacy detection explanations
- Rebuttal trainer prompts, scores, feedback, and advice

The disclaimer should use low-emphasis white text and should not compete with primary content.

## Accessibility and Practical Constraints

Requirements:

- Primary text has strong contrast
- Tap targets are comfortable for touch
- Important actions remain visible around the keyboard when possible
- Long Chinese and English text wraps cleanly
- External links are identifiable before opening
- No black text on dark glass surfaces

## Launcher Icon Direction

The launcher icon should stay consistent with Android:

- Dark rounded square glass base
- White central speech bubble or reasoning symbol
- Opposing warm amber and cool cyan arcs
- Subtle reasoning path dots
- No text

## Maintenance Rule

Whenever the iPhone UI changes, update this file in the same commit.

Examples that require an update:

- New screen
- Removed screen
- Changed navigation structure
- New visual style, color, typography, or component pattern
- Changed tool behavior visible to users
- New icon direction
- Added or removed user-facing feature card

Small copy-only fixes do not need an update unless they change the meaning, hierarchy, or visible behavior of a screen.
