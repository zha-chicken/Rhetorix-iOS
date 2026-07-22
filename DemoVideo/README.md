# Rhetorix iOS product demo

A 54-second, 1920×1080 Remotion product film built from the supplied `Rhetorix-1.1.0.mov` simulator recording. The final cut follows the student practice loop from a daily goal through live debate, analysis, rebuttal, scoring, logic review, history and configuration.

## Final deliverable

- `deliverables/Rhetorix-iOS-demo.mp4`
- `deliverables/Rhetorix-iOS-demo-poster.png`
- H.264, 1920×1080, 30 fps
- Stereo AAC mix
- 54.0 seconds

## Rebuild

The 129 MB source recording is deliberately not committed. Prepare it locally, extract the authenticated app frames, and render:

```sh
mkdir -p public/source public/stills
cp /Users/benjamin/Desktop/Rhetorix-1.1.0.mov public/source/rhetorix.mov
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcrun swift scripts/extract-stills.swift \
  /Users/benjamin/Desktop/Rhetorix-1.1.0.mov public/stills
npm install
npm run typecheck
npm run render
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcrun swift scripts/validate-media.swift \
  deliverables/Rhetorix-iOS-demo.mp4
```

The timeline, all sound cues and their shot-relative offsets live in `src/RhetorixDemo.tsx`. Music and licensing notes are in `audio-notes.md`; the approved concept and exact frame map are in `design-spec.md`.
