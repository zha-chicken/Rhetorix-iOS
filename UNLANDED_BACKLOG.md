# Rhetorix Unlanded Backlog

This file tracks goals that are not fully landed yet. It should be updated when a planned feature moves from backlog to implementation.

## Not Fully Landed

### 1. AI Voice Output

Status: `Implemented baseline`

- Local AI speech playback for AI debate turns has been added through Apple system text-to-speech.
- AI responses auto-read by default for new installs.
- Users can turn off auto-read in Settings and use manual playback on AI message bubbles.
- Online TTS remains out of MVP.
- Remaining work: real device verification across silent mode, Bluetooth/headphones, and Chinese/English voices.

### 2. Rich Single-Debate Review

- Store structured key clashes.
- Store strongest arguments from each side.
- Store concrete user improvement actions.
- Store why the judge thought the winner won.

### 3. Stronger Debate Pressure

- Add clearer warning/overtime states.
- Consider subtle sound or haptic feedback on real devices.
- Consider optional auto-end per stage after timeout.

### 4. Profile Detail Page

Status: `Implemented baseline`

- Dedicated long-term memory detail page exists.
- It shows local evidence counts, profile metrics, inferred signals, confidence, and evidence snippets.
- It connects weaknesses to Recommendation 2.0 topic suggestions.

### 5. Recommendation 2.0

Status: `Implemented baseline`

- Recommendations combine favorite topic category, recent-repeat avoidance, prior debate counts, and the strongest weakness signal.
- If evidence is thin, the app keeps the learning state instead of inventing recommendations.
- Remaining work: tune keyword matching with more real user data.

### 6. Automated Functional Testing

- Add UI automation covering Home, Settings, provider config, debate start, debate finish, history open, constructive analysis, fallacy detector, and rebuttal trainer.
- Keep build checks but do not treat build success as full functional coverage.

### 7. Real Device Verification

Detailed checklist: [REAL_DEVICE_VERIFICATION.md](REAL_DEVICE_VERIFICATION.md)

- Verify microphone permission flow.
- Verify iOS Speech transcription.
- Verify local AI voice playback.
- Verify API moderation and provider calls over real network conditions.

### 8. Distribution Readiness

- Prepare a non-debug iOS archive flow.
- Prepare TestFlight/App Store notes if the project moves toward public iOS testing.
