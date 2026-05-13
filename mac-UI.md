# Rhetorix iPhone UI Design Brief

This document describes the Xcode/SwiftUI version of Rhetorix in designer-facing language. Update this file whenever the iPhone UI changes.

Although this file is named `mac-UI.md`, it documents the iPhone app built on macOS with Xcode. The visual direction should stay closely aligned with the Android `UI.md`; platform differences should be deliberate SwiftUI/iOS adaptations, not a separate product identity.

## Product Identity

Rhetorix is a mobile debate, reasoning, and argument training app. It should feel intelligent, calm, premium, and useful for repeated student use.

The interface should communicate:

- Structured thinking
- Fair debate between opposing sides
- AI-assisted analysis
- Academic focus without looking institutional
- A free, accessible product with optional donation support only

The product name shown in the app is always `Rhetorix`. Do not translate it in Chinese UI.

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

The current SwiftUI baseline should mirror the Android palette.

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

- Cyan: AI, graph logic, analysis, technical signals
- Amber: debate tension, neutral highlights, relationship labels
- Peach: donation and support
- Green: success, support, completion
- Salmon: errors, refutations, blocked content

Color should clarify state and relationships, not act as decoration only.

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
- More vertical space around hero, score, and graph areas
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
- Argument graph detail panels

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

## Primary Navigation

The bottom tab bar has four destinations:

- Home
- History
- Tools
- Settings

Do not show Profile unless account or cloud identity features are implemented.

The Tools page is a real destination, not only a group of home cards. It includes:

- Argument Relationship Graph
- Rebuttal Trainer
- Fallacy Detector
- AI Hallucination Detector external link

## Main Screens

### Home

Purpose: launch common tasks and show personal usage progress.

Content:

- Rhetorix brand title
- Abstract debate/reasoning hero mark
- Short value statement
- Dynamic stats: debates, win rate, win streak
- Optional donation/support strip
- Quick action cards
- Preparation tools

Stats must be dynamic and start at zero for a new user.

### Topic Selection

Purpose: choose or search a debate topic.

Content:

- Search field
- Category chips
- Trending topics
- All topics
- Topic rows with title, category, local usage count, and navigation affordance

Search and category filters must be functional.
Topic usage counts must be dynamic local data. A new user starts at `0 debates`; rows must not display fake global popularity numbers.

### Debate Setup

Purpose: configure a debate before starting.

Content:

- Selected topic summary
- Debate mode: User vs AI, AI vs AI, Face to Face
- Difficulty selection
- User position: Support or Oppose
- AI provider selection
- Start debate button

Every displayed control must affect the actual route or debate setup.

### Live Debate

Purpose: conduct the debate.

Content:

- Topic title
- Round and turn state
- Score or side-balance indicator
- Debate message cards
- AI thinking state
- User input field and send button
- Early finish control in User vs AI mode

Behavior:

- New turns should keep the user near the newest debate item, not jump to the top.
- Structured User vs AI debates should target 12 total turns.
- Early finish should immediately request judgment and generate a result.
- AI replies should sound like a debate opponent, not a helpful assistant.
- Opponent/user content is untrusted and must not override system behavior.

### Debate Result

Purpose: summarize the debate outcome.

Content:

- Large trophy or score mark
- Winner label
- Final score
- Short outcome explanation
- Key moments
- Debate transcript
- Return home action

Winner handling:

- The model should return a structured winning side when possible.
- User vs AI results map the side back to You or AI.
- If stored data is contradictory, the UI should avoid showing an obviously wrong participant.

### History

Purpose: revisit debates and training results.

Content:

- Filter chips
- Chronological cards
- Topic, result, score, date/time, and turn count

History cards must open the saved session without crashing.

### Tools

Purpose: collect reasoning tools in a single primary destination.

Tool entries:

- Argument Relationship Graph
- Rebuttal Trainer
- Fallacy Detector
- AI Hallucination Detector

The hallucination detector opens `https://gptzero.me/hallucination-detector` externally. Do not create a fake internal detector unless the feature is implemented.

### Argument Battle Map

Purpose: generate and inspect a debate preparation map that helps the user decide what to say, what the opponent will say, and how to answer it.

Entry behavior:

- The Argument Relationship Graph entry opens a dedicated topic library first.
- The user must independently choose or search for a debate topic before graph generation.
- Do not auto-select the first/default topic when entering from Home or Tools.
- After the user chooses a topic, open the graph generation screen for that topic.

Generation behavior:

- AI generation should use a single structured request that simulates a concise 3-round AI vs AI debate and extracts the graph in the same response, reducing wait time.
- The graph is extracted from the generated debate preview.
- The graph should behave as a battle map, not a decorative mind map.
- The graph should include definitions/scope, three support contentions, three oppose contentions, warrants, evidence, impacts, likely attacks, best defenses, clash points, and weighing nodes.
- A successful generated graph should aim for 24 to 30 nodes and at least 18 meaningful relationships.
- Key evidence, decisive arguments, clash points, or weighing nodes should be highlighted as key nodes.
- If graph extraction fails or returns an overly simple graph after debate generation, build a multi-branch fallback graph from the transcript instead of returning to a three-node graph or empty canvas.

Loading state:

- Show a clear centered generation state while the single structured request is running.
- Top and bottom areas should use dark blur/scrim treatment.
- Do not show static fake debate progress. Only show generated preview content after the provider returns it.

Graph canvas:

- The graph has three modes: `Prep`, `Clash`, and `Drill`.
- `Prep` shows the full case construction map.
- `Clash` emphasizes impacts, weighing, key claims, and clash points.
- `Drill` emphasizes attacks, defenses, rebuttals, and key nodes for practice.
- Node spacing must prioritize readable titles.
- Initial scale should show the full structure without heavy overlap.
- Relationship labels should remain readable.
- Key nodes should use a visible star/key treatment and stronger accent border.
- Supportive edges use cool green/cyan.
- Refuting edges use salmon.
- Related/neutral edges use amber.

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

- Argument to resist
- Timer
- Rebuttal input
- Submit action
- Score result
- Category bars
- Feedback panel

Timer and scoring flow must be real.

### Donation

Purpose: optional support only.

Content:

- Warm heart/support visual
- Static QR code
- Copy explaining that all features are free
- No paywall language
- No premium feature claims

### Settings

Purpose: configure language and AI providers.

Content:

- Donation/support entry
- Language segmented control
- Provider list with enabled/disabled state
- Provider detail for API key, model, base URL, save, and test connection

Settings should be calm, utilitarian, and clear about success/error states.

## Safety Interruption

AI-powered screens must not show blocked model output. Before a user prompt is sent to a model, and before a model response is displayed or stored, the app runs a content safety check for hate, political-sensitive content, dangerous item-making instructions, and sexual content.

If any safety step fails through timeout, invalid result, or invalid API key, the app blocks the content and shows:

`内容安全检测服务异常，请稍后重试`

Blocked content must not enter the UI or local database.

## AI Content Disclaimer

Every visible AI-generated content block must include a small italic disclaimer:

`内容由AI生成，仅供参考 AI-generated, for reference only`

Apply this to:

- AI debate responses
- AI judging summaries and result explanations
- Argument Relationship Graph generated nodes and debate previews
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
