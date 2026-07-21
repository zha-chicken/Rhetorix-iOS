import React from 'react';
import {Audio, interpolate, Sequence, staticFile} from 'remotion';
import {
  BreadthRelay,
  CoachScore,
  ConstructiveAnalysis,
  FallacyDetector,
  RebuttalBuild,
} from './scenes/AnalysisTools';
import {Opening} from './scenes/Opening';
import {Outro} from './scenes/Outro';
import {
  AnalysisTitleCard,
  DebateSetup,
  GuidedPractice,
  HomeHero,
  LiveDebate,
} from './scenes/ProductLoop';
import {clamp} from './lib/motion';

export const SHOTS = {
  opening: {from: 0, duration: 108, component: Opening},
  home: {from: 108, duration: 156, component: HomeHero},
  guided: {from: 264, duration: 135, component: GuidedPractice},
  setup: {from: 399, duration: 129, component: DebateSetup},
  live: {from: 528, duration: 147, component: LiveDebate},
  analysisTitle: {from: 675, duration: 54, component: AnalysisTitleCard},
  analysis: {from: 729, duration: 150, component: ConstructiveAnalysis},
  rebuttal: {from: 879, duration: 150, component: RebuttalBuild},
  score: {from: 1029, duration: 132, component: CoachScore},
  fallacy: {from: 1161, duration: 141, component: FallacyDetector},
  breadth: {from: 1302, duration: 162, component: BreadthRelay},
  outro: {from: 1464, duration: 156, component: Outro},
} as const;

const shots = Object.values(SHOTS);

type SfxCue = {from: number; src: string; volume: number; duration?: number};

// Every cue is pinned relative to a shot start so edits cannot silently desync sound.
const SFX: SfxCue[] = [
  {from: SHOTS.opening.from, src: 'riser-synth.mp3', volume: 0.20, duration: 108},
  {from: SHOTS.opening.from + 54, src: 'bass-hit-futuristic.mp3', volume: 0.32},
  {from: SHOTS.home.from + 8, src: 'air-zoom-vacuum.mp3', volume: 0.26},
  {from: SHOTS.home.from + 58, src: 'drum-impact-subtle.mp3', volume: 0.28},
  {from: SHOTS.guided.from, src: 'sweep-fast-small.mp3', volume: 0.25},
  {from: SHOTS.setup.from + 38, src: 'bass-hit-short.mp3', volume: 0.26},
  {from: SHOTS.live.from + 135, src: 'sweep-metal-quick.mp3', volume: 0.26},
  {from: SHOTS.analysisTitle.from, src: 'sweep-metal-quick.mp3', volume: 0.24},
  {from: SHOTS.analysis.from + 22, src: 'air-zoom-vacuum.mp3', volume: 0.27},
  {from: SHOTS.rebuttal.from + 24, src: 'sweep-scifi-fast.mp3', volume: 0.25},
  {from: SHOTS.rebuttal.from + 88, src: 'drum-impact-subtle.mp3', volume: 0.26},
  {from: SHOTS.score.from, src: 'riser-drama.mp3', volume: 0.22, duration: 90},
  {from: SHOTS.score.from + 24, src: 'impact-zoom-quick.mp3', volume: 0.42},
  {from: SHOTS.fallacy.from + 58, src: 'bass-hit-short.mp3', volume: 0.24},
  {from: SHOTS.fallacy.from + 72, src: 'shimmer-sparkle-sweep.mp3', volume: 0.20},
  {from: SHOTS.breadth.from + 29, src: 'tick-percussion.mp3', volume: 0.22},
  {from: SHOTS.breadth.from + 58, src: 'tick-percussion.mp3', volume: 0.19},
  {from: SHOTS.breadth.from + 87, src: 'tick-percussion.mp3', volume: 0.16},
  {from: SHOTS.breadth.from + 116, src: 'tick-percussion.mp3', volume: 0.13},
  {from: SHOTS.outro.from, src: 'riser-tech-choir.mp3', volume: 0.30, duration: 105},
  {from: SHOTS.outro.from + 60, src: 'impact-epic-trailer.mp3', volume: 0.44},
  {from: SHOTS.outro.from + 91, src: 'shimmer-sparkle-sweep.mp3', volume: 0.25},
];

export const RhetorixDemo: React.FC = () => (
  <>
    <Audio
      src={staticFile('audio/tonight-hiphop.mp3')}
      volume={(frame) => interpolate(frame, [0, 30, 1570, 1620], [0, 0.27, 0.27, 0], clamp)}
    />
    {SFX.map((cue, index) => (
      <Sequence key={`${cue.src}-${index}`} from={cue.from} durationInFrames={cue.duration ?? 90}>
        <Audio src={staticFile(`audio/${cue.src}`)} volume={cue.volume} />
      </Sequence>
    ))}
    {shots.map(({from, duration, component: Component}, index) => (
      <Sequence key={index} from={from} durationInFrames={duration} premountFor={24}>
        <Component />
      </Sequence>
    ))}
  </>
);
