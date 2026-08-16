# Rhetorix Real Device Verification Checklist

This file tracks everything that must be verified on a physical iPhone. Simulator build success is not enough for these items.

## Test Setup

- Test at least one iPhone running the current supported iOS version.
- Test with app language set to English.
- Test with app language set to Chinese.
- Test in dark mode.
- Test in the light theme.
- Test with no saved local data after a fresh install.
- Test with existing local data after upgrading from a previous build.

## Permissions

- First launch MBTI sheet appears once and can be skipped.
- Microphone permission request appears before recording.
- Speech recognition permission request appears before transcription.
- Denying microphone permission does not crash the app.
- Denying speech recognition permission does not crash the app.
- Reopening the app after permission denial shows a clear fallback path.

## AI Voice Playback

- AI responses auto-read by default on a fresh install.
- Settings can turn automatic AI reading off.
- When auto-read is off, tapping the speaker button manually reads an AI message.
- Tapping the active speaker button stops current playback.
- Leaving the debate page stops playback.
- Starting another AI message stops the previous playback cleanly.
- English AI responses use an English system voice when available.
- Chinese AI responses use a Chinese system voice when available.
- If the preferred voice is missing, the app falls back without crashing.
- Silent mode behavior is acceptable and documented by observed behavior.
- Playback works through phone speaker.
- Playback works through wired or USB-C headphones if available.
- Playback works through Bluetooth headphones if available.
- Playback does not prevent debate text from rendering.
- Playback does not block judging, history saving, or navigation.

## Voice Input And Transcription

- User vs AI debate microphone button starts recording.
- User vs AI debate microphone button stops recording.
- Live transcript appears in the input field.
- Sending a voice-transcribed argument records the turn as Voice.
- Speech transcript does not overwrite text after the user stops recording and edits manually.
- Recording stops when leaving the debate page.
- Recording does not continue in the background unexpectedly.
- Chinese speech recognition works when app language is Chinese.
- English speech recognition works when app language is English.
- Weak network or offline speech behavior is acceptable and does not crash.

## Constructive Analysis Recording

- Constructive Analysis recording starts on a physical device.
- Live transcript appears.
- Detected segments trigger analysis without waiting for the full recording to end.
- Stopping recording stops microphone use.
- Returning from the page stops recording.
- Repeated recording start/stop does not crash.
- Results render as issue cards, not raw JSON.
- Saved Constructive Analysis issues feed long-term memory after analysis.

## API Provider Configuration

- OpenAI config saves API key, model, base URL, and enabled state.
- Anthropic config saves API key, model, base URL, and enabled state.
- Gemini config saves API key, model, base URL, and enabled state.
- DeepSeek config saves API key, model, base URL, and enabled state.
- Groq config saves API key, model, base URL, and enabled state.
- Voicebox voice config does not crash even if the local server is unavailable.
- Default debate provider uses a configured provider when one exists.
- If multiple providers are configured, one valid configured provider is selected.
- Invalid provider config shows a user-facing error rather than crashing.

## Content Safety

- User text is checked before AI response generation.
- AI output is checked before display/storage.
- OpenAI moderation path works when using OpenAI.
- Non-OpenAI provider safety fallback works when using providers such as DeepSeek.
- Safety timeout blocks content.
- Invalid safety result blocks content.
- Invalid API key during safety check blocks content.
- Blocked content is not inserted into UI.
- Blocked content is not inserted into local storage.
- User-facing warning says: `内容安全检测服务异常，请稍后重试` when the safety service fails.

## Debate Flow

- User vs AI structured debate can be completed.
- User vs AI free-flow debate can be completed.
- AI vs AI structured debate can be completed.
- AI vs AI free-flow debate can be completed.
- Face-to-Face structured debate can be completed.
- Face-to-Face free-flow debate can be completed.
- End button works before full turn limit.
- Ending early generates score and winner.
- AI prompt behaves like a debate opponent, not a generic assistant.
- Prompt injection inside user debate text does not change AI system behavior.
- Debate view does not jump to the top after each new message.
- Latest message remains visible after user or AI turn.
- Stage timer updates once per second.
- Timer warning/overtime state is visible.
- Stage timing is saved into the debate record.

## Result And History

- Completed debate opens result page.
- Winner mapping is correct for User vs AI.
- Winner mapping is correct for Support/Oppose in AI vs AI and Face-to-Face.
- Result summary is readable, not raw JSON.
- Key moments section displays without layout issues.
- History tab opens from bottom navigation.
- History row opens saved debate/result without crashing.
- Unfinished debate can be resumed if supported by current UI.
- Old saved sessions from previous local schema still load.
- Round Memory shows input mode, duration, and stage limit when available.

## Long-Term Memory

- New install starts with learning state.
- After fewer than two engaged debates, no fake recommendation appears.
- After enough real local history, recommendation appears.
- Recommendation uses local debate history, not hardcoded fake popularity.
- MBTI can be selected.
- MBTI can be skipped.
- MBTI can be changed in Settings.
- Profile signals only appear when evidence exists.
- Style signals show evidence snippets.
- Value signals show evidence snippets.
- Weakness signals show evidence snippets.
- Slow rebuttal pacing appears only when actual saved timing supports it.
- Constructive Analysis issue history contributes to practice focus.

## Tools

- Constructive Analysis paste mode works.
- Fallacy Detector shows loading state.
- Fallacy Detector shows `未检出` / no-fallacy state when no fallacy is detected.
- Rebuttal Trainer generates a prompt.
- Rebuttal Trainer scores a response.
- Rebuttal Trainer feedback is saved into long-term memory inputs.

## UI And Accessibility

- No black unreadable text appears in dark mode.
- No white-on-white unreadable text appears in light mode.
- Buttons remain tappable on small iPhone screens.
- Dynamic Island / notch does not cover important controls.
- Keyboard does not permanently hide input controls.
- Rotation behavior is acceptable or locked as intended.
- Chinese text fits in primary controls.
- English text fits in primary controls.
- Speaker, microphone, send, end, and back controls are understandable.

## Storage And Upgrade

- Local JSON store loads after app restart.
- Provider settings persist after app restart.
- Language setting persists after app restart.
- Theme setting persists after app restart.
- Auto-read AI setting persists after app restart.
- Existing store without `autoSpeakAI` defaults to auto-read on.
- Existing store without memory 2.0 fields still loads.
- Existing store without Constructive Analysis history still loads.

## Performance And Stability

- Long AI responses do not freeze scrolling.
- Auto-reading long responses can be stopped.
- Repeated debates do not cause obvious memory growth.
- App remains responsive while AI is thinking.
- App remains responsive while safety check is running.
- App remains responsive while speech recognition is running.
- No crash when network disconnects during AI call.
- No crash when app backgrounds during recording.
- No crash when app backgrounds during speech playback.
- No crash when app backgrounds during API call.

## Distribution Readiness

- Physical-device Debug run succeeds from Xcode.
- Release archive succeeds when distribution is needed.
- Bundle identifier is correct.
- App icon displays correctly on device home screen.
- Required privacy usage descriptions are present and accurate.
- TestFlight notes mention user-provided API keys and local speech features if released.
