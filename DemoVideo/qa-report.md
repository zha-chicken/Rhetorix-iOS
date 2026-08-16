# Final QA report

## Automated and media checks

- TypeScript: `npm run typecheck` passed.
- Remotion master render: 1620 / 1620 frames encoded successfully.
- Media validation: AVFoundation analyzed the movie with 0 errors.
- Video: H.264, 1920×1080, 30.000 fps, 54.000 seconds.
- Audio: stereo AAC, 48 kHz, 54.059 seconds.
- Source exclusion: no frame from the unusable 01:40–02:10 black interval is referenced.
- Visual audit: two checkpoints from each of the 12 shots were rendered and inspected; exact transition and artifact frames were re-rendered after both corrective passes.
- Independent clean-context review: passed after a dense 10 fps inspection of all 11 transitions; no flashes, gaps, source leaks, test fixtures or unintended cursor artifacts remain.

## Aesthetic-rules audit

- R1 ✓ Opening and final wordmarks each hold for more than 30 static frames.
- R2 ✓ Relay steps and all arrivals use eased acceleration; the outro settles before its final hold.
- R3 ✓ Product interactions receive readable holds; the central phone arcs run longer than three seconds.
- Q1 ✓ Every product page comes from the supplied real simulator recording; campaign-only titles and marks are code-native.
- Q2 ✓ UI sources are rasterized above their display size and downsampled; inspected labels remain sharp.
- Q3 ✓ No handheld shake is used; the only score shake is a six-frame narrative impact.
- Q4 ✓ Colored atmosphere is limited to Home, Live Debate and the outro; no repeated card glints.
- Q5 ✓ The opening has one target/wordmark lockup and one complete materialization arc.
- Q6 ✓ Information-heavy screens remain nearly front-on; perspective is restrained to ±5°.
- Q7 ✓ No separate asset-orbit shot is used; the nearest object treatment is the stable physical phone presentation.
- Q8 ✓ Four representative product surfaces assemble around the final wordmark at the film’s energy peak.
- Q9 ✓ Every animated UI state lands inside the phone or a defined filmstrip/card slot.
- Q10 ✓ All document-like analysis and coaching screens use the app’s authentic, fully populated layouts.
- S1 ✓ A verified Mixkit hip-hop/electronic bed and cinematic SFX vocabulary replace game-style UI sounds.
- S2 ✓ Every SFX is centrally declared with a shot-relative frame, source and volume; relay ticks step down in volume.
- S3 ✓ Sound was added after the 1620-frame visual timeline was locked; no duration changed afterward.
- S4 ✓ Distinctive actions receive matching movement/impact cues and every long cue is sequence-trimmed.
- C1 ✓ All silent animation passages carry short on-screen copy; the brand outro remains deliberately clean.
- C2 ✓ Copy names concrete functions and outcomes: Guided Practice, setup, live debate, analysis, rebuttal, score and fallacy detection.
- C3 ✓ No free-floating annotation is composited over a 3D UI surface; captions occupy the stable stage plane.
- P1 ✓ 24 required checkpoints plus exact corrected transition/artifact frames were inspected before delivery.
- P2 ✓ Each selected motion recipe was mapped to one suitable shot; unsuitable glitch and high-energy motifs were omitted.
- P3 ✓ The approved direction and storyboard are documented in their own commit before production work.
- P4 ✓ Every requested function has one dedicated narrative beat; no UI motion technique serves as the primary device twice.

## Corrections made during QA

1. Repositioned the Guided Practice demoted title to prevent left-edge clipping.
2. Slowed the Live Debate source so it remains on the live screen through the cut.
3. Moved the rebuttal checkpoint from 132s to 134s to show the completed response.
4. Replaced the score background’s intermediate “Scoring…” frame with the completed coach result.
5. Tightened filmstrip/outro crops to remove Simulator chrome.
6. Delayed the outro sparkle to 25 frames after its impact, matching the final riser → impact → sparkle sound phrase.
7. Replaced contaminated moving-source segments in Live Debate and Rebuttal Trainer with clean frames from the same recording plus restrained code-native motion.
8. Removed source cursor/ring artifacts from the live screen, constructive analysis, rebuttal action and final card wall.
9. Cropped History to show only authentic debate rows, excluding automated test fixtures.
10. Rebuilt the final card wall with clean approved app surfaces and rechecked its static brand hold.
