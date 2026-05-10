# Rhetorix iOS

Native SwiftUI iPhone implementation of Rhetorix.

This project is a clean iOS port of the Android Rhetorix app. It keeps the same product direction:

- Free debate and reasoning practice
- User-provided AI provider API keys
- No paywall
- Optional donation/support screen
- Fail-closed content safety checks
- AI-generated content disclaimers

## Current Scope

Implemented in this first iOS pass:

- Home dashboard with dynamic debate stats
- Topic selection
- Debate setup
- User vs AI and AI turn debate flow
- Debate result judging
- History
- Tools page
- Argument Relationship Graph generation
- Rebuttal Trainer
- Logic Fallacy Detector
- AI Hallucination Detector external link
- Settings and provider configuration
- Donation screen with bundled QR image
- Provider support for OpenAI, Anthropic, Gemini, DeepSeek, Groq, and Ollama/OpenAI-compatible endpoints

## Safety Behavior

Before a user prompt is sent to a model, and before AI output is displayed or saved, Rhetorix runs a safety check.

If a safety check fails because of timeout, invalid API key, invalid response, or provider error, the content is blocked and the UI shows:

```text
内容安全检测服务异常，请稍后重试
```

Visible AI-generated content includes:

```text
内容由AI生成，仅供参考 AI-generated, for reference only
```

## Build

Open:

```text
Rhetorix.xcodeproj
```

Build target:

```text
Rhetorix
```

The current Mac has Xcode installed, but `xcodebuild` reported that the iOS platform is not installed:

```text
iOS 26.4 is not installed. Please download and install the platform from Xcode > Settings > Components.
```

After installing the iOS platform, run:

```bash
xcodebuild -project Rhetorix.xcodeproj -scheme Rhetorix -destination 'platform=iOS Simulator,name=iPhone 16' build
```

## Verification Done Here

Because the iOS SDK is currently missing, full iOS build could not be completed on this Mac.

The Swift sources were type-checked successfully with the macOS SDK:

```bash
xcrun --sdk macosx swiftc -typecheck Rhetorix/Sources/*.swift
```

