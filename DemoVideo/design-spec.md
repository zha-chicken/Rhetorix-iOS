# Rhetorix iOS Demo — “Debate Chamber” Design Spec

## Brief

- **Format:** 1920×1080, 30 fps, approximately 54 seconds
- **Source:** `/Users/benjamin/Desktop/Rhetorix-1.1.0.mov` (3:12, 1038×1970, silent H.264 screen recording)
- **Audience:** students who want to practice debate independently
- **Promise:** Rhetorix turns a solo practice session into a deliberate loop: learn, debate, analyze, improve
- **Audio:** licensed electronic/cinematic BGM plus restrained cinematic SFX; no voice-over
- **Data:** use the supplied recording as-is

## Visual language

The film inherits the app’s current product system instead of adding a separate campaign skin.

| Role | Token |
|---|---|
| Background | `#0E1013` |
| Deep background | `#0B0D10` |
| Surface | `#191B20` |
| Raised surface | `#222530` |
| Hairline | `rgba(255,255,255,0.08)` |
| Primary text | `rgba(255,255,255,0.94)` |
| Secondary text | `rgba(255,255,255,0.66)` |
| Brand teal | `#54C2CF` |
| Success | `#6BC799` |
| Type | SF Pro / system sans, bold display with restrained metadata |

Lighting is almost entirely neutral. A restrained teal pool appears only around the day’s-practice hero and the live debate moment. Fine concentric rings act as a recurring “debate chamber / target” motif, never as decoration on every screen.

## Motion personality

- **Brand position:** low-to-medium energy, serious and calm; “professional trust” blended with “calm education.”
- **Primary move:** 36–44 frames with `cubic-bezier(0, 0, 0.2, 1)`.
- **Physical moves:** maximum overshoot `1.02`; no elastic bounce or squash.
- **Phone camera:** slow push, `rotateY` within ±6°, `rotateX` within ±2°, long readable landings.
- **Readability:** every information-heavy screen settles for at least 15 frames; final brand hold is at least 30 frames.
- **Transitions:** one circular shared-element iris, one line-carry transition, and otherwise simple motivated hidden cuts. No glitch language.

## Feature coverage and source map

| Function | Source range | Visual treatment |
|---|---:|---|
| Home, skill path, memory and progress | 00:00–00:02, 02:44–02:48 | Hero spotlight and final recap |
| Provider configuration | 00:02–00:10, 03:10–03:12 | Breadth relay |
| Guided Practice | 00:12–00:16 | Slow page push with learning-loop copy |
| Topic and debate setup | 00:22–00:26 | Segmented-choice interaction hero |
| Live Debate | 00:18–00:20 | Live waveform performance |
| Constructive Analysis | 00:36–01:10 | Speech-to-claims before/after reveal |
| Rebuttal Trainer | 01:14–01:38, 02:12–02:24 | Speed ramp, freeze, then score reveal |
| Fallacy Detector | 02:28–02:42 | Input-trigger interaction and result |
| History, Tools, Voice and Settings | 02:46–03:12 | Word-relay breadth montage |

The unusable black interval at 01:40–02:10 is excluded.

## Storyboard

| # | Time | Shot | Key motion |
|---:|---:|---|---|
| 1 | 00:00–00:03.6 | **Rhetorix / “Practice the point. Prove the case.”** | `letterspace-materialize`: concentric mark traces in, the wordmark resolves with wide tracking, then holds in silence before the first beat. |
| 2 | 00:03.6–00:08.8 | **Today’s move. One clear goal.** | `spotlight-hero-card`: the Home screen enters as a physical phone; light searches, locks onto Today’s Practice, pushes closer, then the hero card lifts and reseats. |
| 3 | 00:08.8–00:13.3 | **Learn it. Debate it. Review it.** | `title-demote-to-label`: the sentence begins as the frame title, demotes to an eyebrow, and gives the real Guided Practice screen the stage. |
| 4 | 00:13.3–00:17.6 | **Choose the motion. Set the pressure.** | `segmented-thumb-hero`: authentic Debate Setup footage is framed around the mode, format and difficulty chips; the selected state glides once, then Start Debate settles. |
| 5 | 00:17.6–00:22.5 | **Your turn.** | `voice-waveform-live`: the live-debate phone pushes forward; a restrained 64-bar waveform performs speak → pause → speak around the real microphone control. |
| 6 | 00:22.5–00:24.3 | **After the speech, the work gets specific.** | Restyled `paper-title-card`: a low-energy breathing frame with a single teal line carrying forward from the live waveform. |
| 7 | 00:24.3–00:29.3 | **Find the claim. Find the clash.** | `before-after-slider-scrub`: the pasted constructive speech sits beneath the “before” side; the divider reveals detected claims, original quote, challenge and rebuttable points. |
| 8 | 00:29.3–00:34.3 | **Build the rebuttal.** | `speed-ramp-freeze`: the generated opposition argument accelerates through its scroll, brakes on the response area and holds on Submit Rebuttal. |
| 9 | 00:34.3–00:38.7 | **Know what landed. Know what to fix.** | `slam-entrance-moves / score-slam`: 87/100 lands once with a controlled impact; the real coach response is already present and readable after the hit. |
| 10 | 00:38.7–00:43.4 | **Catch the weak logic.** | `input-trigger-moves / cursor-performance`: the cursor completes the fallacy example, presses Analyze for Fallacies, and the Begging the Question result rises into view. |
| 11 | 00:43.4–00:48.8 | **Debate. Analyze. Remember. Configure.** | `word-relay-filmstrip`: real History, Tools, Voice, AI Providers and Settings screens step through a measured vertical filmstrip while the active verb changes in place. |
| 12 | 00:48.8–00:54.0 | **Rhetorix / “One round sharper.”** | `outro-group-photo-launch`: representative Home, Live Debate, analysis and coaching surfaces assemble around the wordmark; one impact, one sparkle, then a clean 1.2-second hold. |

## Transition grammar

1. The opening target mark expands into the Home screen’s target icon as the film’s single circular shared-element transition.
2. The Home hero reseats into the Guided Practice page with a motivated phone push; the phone remains the same physical object.
3. Guided Practice, Debate Setup and Live Debate use covered motion in the phone body for hidden cuts, preserving spatial continuity.
4. The live waveform collapses into a horizontal teal line; that line carries the film into the analysis chapter card.
5. Analysis tools use clean cuts on button presses and score impact rather than ornamental transitions.
6. The breadth filmstrip releases its screen cards into the final group-photo assembly.

## Acceptance criteria

- Every listed product function is visibly represented by real source footage.
- No source frame from the black 01:40–02:10 interval appears.
- App text remains sharp at every camera push; no 3D raster blur.
- No decorative glow repeats outside the hero, Live Debate and final impact.
- Each feature shot communicates one new idea and uses one principal motion.
- BGM supports rather than dictates the timeline; SFX land on visual action frames.
- The final wordmark holds for at least one second with no camera drift.
