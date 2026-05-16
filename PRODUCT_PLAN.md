# Rhetorix Product Plan

Rhetorix is becoming a debate-first app, not a toolbox. Tools still exist, but they should support the central experience: a fast, tense, voice-led debate that feels like an actual conversation with pressure, timing, turn-taking, and memory.

## Updated Product Direction

The app should feel closer to a real debate chamber than a list of utilities.

Core principles:

- Debate is the main product; analysis tools are secondary.
- Voice should become the default interaction mode, while text remains available.
- Each debate stage should have a visible timer and a sense of urgency.
- Conversations should be quick, responsive, and adversarial enough to feel alive.
- The classical Greek identity should come through as spoken rhetoric and dialogue, not only visual decoration.
- The app should help users sit down and actually talk through a topic, rather than merely run isolated tools.

## Near-Term Implementation Plan

### 1. Debate-First Home

Current issue: Home still gives preparation tools too much visual weight.

Plan:

- Make `Start Debate` / `Voice Debate` the primary hero action.
- Keep stats visible but secondary.
- Shrink preparation tools into a compact row or secondary section.
- Avoid making Tools feel like the app's main destination.
- Keep History available because it supports memory and progress.

### 2. Voice-First Debate

Current issue: live debate is text-first.

Plan:

- Add a microphone-first input control in live debate.
- Keep text input available as a fallback.
- Use iOS Speech on real devices for user speech-to-text.
- In Simulator, keep paste/text input and show a clear message if voice is unavailable.
- For User vs AI, the user should be able to speak, see a transcript, and send quickly.
- Later, add speech playback for AI responses if quality and latency are acceptable.

### 3. Timed Debate Stages

Current issue: stages exist, but time pressure is weak.

Plan:

- Add a stage timer to every structured debate stage.
- Timer should be visible in the live debate header.
- Timer states:
  - ready
  - active
  - warning
  - overtime
  - ended
- Use shorter default mobile practice limits, not full formal tournament times.
- Allow early submit/end so mobile sessions remain practical.

Suggested default mobile timing:

- Constructive: 90 seconds
- Extension/Rebuttal: 75 seconds
- Reply/Summary: 45 seconds
- Free Flow turn: 30 seconds

These are practice defaults, not official tournament limits.

### 4. Faster, More Real Debate Rhythm

Current issue: AI can feel like a slow assistant instead of a live opponent.

Plan:

- Tighten prompts so AI gives concise, opponent-like speeches.
- Prefer shorter turns and faster back-and-forth in Free Flow mode.
- Make AI thinking state feel like a short turn transition, not a tool loading state.
- Keep the user close to the newest message.
- Make End / Judge feel like a formal debate conclusion.

### 5. Tool Hierarchy Reduction

Current issue: tools risk defining the app.

Plan:

- Tools remain in a tab, but Home should not visually over-emphasize them.
- Constructive Analysis, Fallacy Detector, and Rebuttal Trainer support debate prep and review.
- They should not compete with live debate as the primary action.
- Tool UI should be compact, serious, and connected back to debate workflows.

## Long-Term Memory Plan

Rhetorix should develop memory in two layers.

### Layer 1: Single-Debate Memory

This already partly exists through `DebateSession`, turns, results, and history.

Needs improvement:

- Save stage timing details.
- Save whether a turn was spoken or typed.
- Save key clashes, strongest arguments, and judge feedback in structured form.
- Make history useful for resuming and reviewing, not only listing sessions.

### Layer 2: Long-Term User Pattern Memory

This should be inferred by the app, not manually selected by the user.

Goal:

- The app observes user behavior over many sessions and recommends topics that the user is likely to actually sit down and discuss.

Signals to infer locally:

- Topics the user starts repeatedly.
- Topics the user finishes rather than abandons.
- Debate categories with longer engagement time.
- User side preference.
- Difficulty level that produces completed sessions.
- Common weaknesses from judge feedback and constructive analysis.
- Whether the user prefers ethical, political, technical, social, or personal-interest topics.
- Self-reported MBTI, if the user chooses to provide it during onboarding or Settings.
- Inferred style signals such as analytical/evidence-first, values-first/persuasive, or balanced reasoning.
- Inferred value signals such as environment-focused or animal welfare-focused, only when repeated local evidence exists.

Recommendation behavior:

- The app should suggest a small number of likely-good topics.
- Suggestions should feel like invitations to talk, not algorithmic feeds.
- Ask only one optional onboarding question: MBTI. The user can skip it, and the app must continue normally.
- Keep all memory local unless a future cloud feature is intentionally added.

## Product Positioning

One-sentence direction:

Rhetorix is a voice-first AI debate partner that helps students practice real-time argument, timed speeches, rebuttal pressure, and long-term rhetorical growth.

Do not position it as:

- A generic AI chatbot
- A collection of unrelated reasoning tools
- A static argument map app
- A paywalled debate platform

## Implementation Priority

1. Make debate visually and behaviorally dominant on Home. `Implemented baseline`
2. Add stage timers to live debate. `Implemented baseline`
3. Add voice-first user input to live debate. `Implemented baseline`
4. Tighten live debate AI prompts and turn rhythm. `Implemented baseline`
5. Reduce visual prominence of tools. `Implemented baseline`
6. Add structured per-debate memory fields. `Implemented baseline`
7. Add local long-term preference inference and topic recommendations. `Implemented baseline`
8. Add optional MBTI onboarding plus evidence-based profile signals. `Implemented baseline`

## Memory Integrity Rule

Long-term memory must be real. It is computed from local usage data only:

- completed and started debate sessions
- topic categories
- completion rate
- selected mode, side, and difficulty
- number of turns
- recorded input mode
- recorded stage duration
- user-provided MBTI, if explicitly selected
- local judge summaries and rebuttal trainer feedback
- saved Constructive Analysis issue history
- repeated words/topics from the user's own User vs AI turns
- real stage timing, including slow rebuttal/reply pacing

The app must not invent a user profile or present a recommendation before there is enough real session data. MBTI is the only user-selected profile attribute and is optional/skippable. Inferred labels must remain evidence-based, local, and conservative. If fewer than two engaged debates exist, the UI shows that memory is still learning instead of recommending a topic.

Memory 2.0 is now a local baseline:

- MBTI prompt appears once on first use and can be skipped.
- Home shows the strongest profile signals when evidence exists.
- Settings shows MBTI, evidence counts, style signals, value signals, weakness signals, confidence, and sample evidence.
- Weakness signals include judge/rebuttal feedback, recurring Constructive Analysis issue types, clearer-definition needs, and slow rebuttal pacing from actual timers.
- Profile refresh runs after completed judging and rebuttal scoring, without blocking the debate flow.
