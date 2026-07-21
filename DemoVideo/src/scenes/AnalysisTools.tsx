import React from 'react';
import {Easing, interpolate, useCurrentFrame} from 'remotion';
import {PhoneFrame, ScreenCrop} from '../components/PhoneFrame';
import {CopyBlock, Stage} from '../components/Stage';
import {clamp, easeInOut, tween} from '../lib/motion';
import {COLORS} from '../theme';

export const ConstructiveAnalysis: React.FC = () => {
  const frame = useCurrentFrame();
  const enter = tween(frame, 0, 20);
  const fling = tween(frame, 22, 12);
  const scrub = tween(frame, 34, 48);
  const position = interpolate(fling * 0.25 + scrub * 0.75, [0, 1], [72, 40], clamp);

  return (
    <Stage>
      <div style={{position: 'absolute', left: 115, top: 322, opacity: enter}}>
        <CopyBlock
          eyebrow="Constructive analysis"
          title={<>Find the claim.<br />Find the clash.</>}
          body="Turn a full speech into challengeable claims, original evidence and rebuttable points."
          width={630}
        />
      </div>
      <div style={{position: 'absolute', right: 225, top: 66, width: 458, height: 940, opacity: enter}}>
        <PhoneFrame source={{kind: 'still', file: 'analysis-input.png'}} />
        <div style={{position: 'absolute', inset: 0, clipPath: `inset(0 0 0 ${position}%)`}}>
          <PhoneFrame source={{kind: 'still', file: 'analysis-result.png'}} />
        </div>
        <div
          style={{
            position: 'absolute',
            top: 23,
            bottom: 22,
            left: `${position}%`,
            width: 3,
            background: COLORS.brand,
            boxShadow: '0 0 24px rgba(84,194,207,.48)',
          }}
        >
          <div
            style={{
              position: 'absolute',
              width: 42,
              height: 42,
              borderRadius: '50%',
              left: -20,
              top: 445,
              background: COLORS.brand,
              color: COLORS.deep,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontWeight: 800,
              fontSize: 18,
              boxShadow: '0 8px 22px rgba(0,0,0,.38)',
            }}
          >
            ↔
          </div>
        </div>
        <div style={{position: 'absolute', left: -7, top: 25, color: COLORS.secondary, fontSize: 15, letterSpacing: 2}}>BEFORE</div>
        <div style={{position: 'absolute', right: -30, top: 25, color: COLORS.brand, fontSize: 15, letterSpacing: 2}}>COACHED</div>
      </div>
    </Stage>
  );
};

export const RebuttalBuild: React.FC = () => {
  const frame = useCurrentFrame();
  const enter = tween(frame, 0, 22);
  const sprint = tween(frame, 24, 15);
  const brake = tween(frame, 39, 54, 0, 1, Easing.bezier(0.12, 0.78, 0.2, 1));
  const revealResponse = tween(frame, 82, 12);
  const zoom = interpolate(sprint + brake, [0, 2], [0.94, 1.02], clamp);

  return (
    <Stage>
      <div style={{position: 'absolute', left: 132, top: 350, opacity: enter}}>
        <CopyBlock
          eyebrow="Rebuttal trainer"
          title="Build the rebuttal."
          body="Read the opposition at speed, then stop where your answer begins."
          width={620}
        />
      </div>
      <div
        style={{
          position: 'absolute',
          right: 230,
          top: 64,
          opacity: enter,
          transform: `perspective(1600px) scale(${zoom}) rotateY(${4 - enter * 3}deg)`,
          filter: sprint > 0 && brake < 0.35 ? `blur(${(1 - brake / 0.35) * 1.7}px)` : 'none',
        }}
      >
        <PhoneFrame source={{kind: 'video', startSeconds: 84.6, playbackRate: 2.15}} />
        <div style={{position: 'absolute', inset: 0, opacity: revealResponse}}>
          <PhoneFrame source={{kind: 'still', file: 'rebuttal-response.png'}} />
        </div>
      </div>
    </Stage>
  );
};

export const CoachScore: React.FC = () => {
  const frame = useCurrentFrame();
  const enter = tween(frame, 0, 20);
  const impact = tween(frame, 24, 6, 0, 1, Easing.in(Easing.quad));
  const settle = interpolate(frame, [30, 36, 46], [1.12, 0.985, 1], {...clamp, easing: easeInOut});
  const ring = tween(frame, 24, 18);
  const shake = frame >= 30 && frame < 39 ? Math.sin((frame - 30) * Math.PI) * (1 - (frame - 30) / 9) * 8 : 0;

  return (
    <Stage>
      <div style={{position: 'absolute', left: 120, top: 316, opacity: enter}}>
        <CopyBlock
          eyebrow="Coach feedback"
          title={<>Know what landed.<br />Know what to fix.</>}
          body="A score is useful only when it leads to a precise next move."
          width={660}
        />
      </div>
      <div style={{position: 'absolute', right: 220, top: 67, opacity: enter, transform: `translateX(${shake}px)`}}>
        <PhoneFrame source={{kind: 'still', file: 'coach-score.png'}} />
        <div
          style={{
            position: 'absolute',
            left: -28,
            top: 495,
            padding: '18px 28px',
            borderRadius: 22,
            background: COLORS.brand,
            color: COLORS.deep,
            fontWeight: 840,
            fontSize: 54,
            letterSpacing: -2,
            boxShadow: '0 22px 58px rgba(0,0,0,.46)',
            transform: `scale(${impact ? settle : 0})`,
          }}
        >
          87 / 100
        </div>
        <div
          style={{
            position: 'absolute',
            left: -50 - ring * 70,
            top: 475 - ring * 70,
            width: 320 + ring * 140,
            height: 130 + ring * 140,
            borderRadius: 60,
            border: '2px solid rgba(84,194,207,.65)',
            opacity: impact * (1 - ring),
          }}
        />
      </div>
    </Stage>
  );
};

export const FallacyDetector: React.FC = () => {
  const frame = useCurrentFrame();
  const enter = tween(frame, 0, 20);
  const cursor = tween(frame, 20, 34);
  const press = interpolate(frame, [58, 62, 70], [0, 1, 0], clamp);
  const result = tween(frame, 72, 18);
  const zoom = interpolate(frame, [22, 58, 72, 112], [1, 1.4, 1.4, 1], clamp);
  const cursorX = interpolate(cursor, [0, 1], [330, 238], clamp);
  const cursorY = interpolate(cursor, [0, 1], [690, 462], clamp);

  return (
    <Stage>
      <div style={{position: 'absolute', left: 132, top: 354, opacity: enter}}>
        <CopyBlock
          eyebrow="Logic fallacy detector"
          title="Catch the weak logic."
          body="Analyze circular reasoning and get the flaw explained in plain language."
          width={600}
        />
      </div>
      <div
        style={{
          position: 'absolute',
          right: 235,
          top: 67,
          opacity: enter,
          transform: `scale(${zoom})`,
          transformOrigin: '63% 50%',
        }}
      >
        <PhoneFrame source={{kind: 'still', file: 'fallacy-input.png'}} />
        <div style={{position: 'absolute', inset: 0, opacity: result}}>
          <PhoneFrame source={{kind: 'still', file: 'fallacy-result.png'}} />
        </div>
        <div
          style={{
            position: 'absolute',
            left: cursorX,
            top: cursorY,
            fontSize: 34,
            color: '#fff',
            textShadow: '0 3px 10px #000',
            opacity: 1 - result,
            transform: `scale(${1 - press * 0.15})`,
          }}
        >
          ↖
        </div>
        <div
          style={{
            position: 'absolute',
            left: 223,
            top: 450,
            width: 80 + press * 48,
            height: 80 + press * 48,
            borderRadius: '50%',
            border: '2px solid rgba(84,194,207,.85)',
            opacity: press,
            transform: 'translate(-50%,-50%)',
          }}
        />
      </div>
    </Stage>
  );
};

const relay = [
  {word: 'Debate.', file: 'history.png', label: 'History'},
  {word: 'Analyze.', file: 'tools.png', label: 'Tools'},
  {word: 'Remember.', file: 'settings.png', label: 'Learning memory'},
  {word: 'Speak.', file: 'voice.png', label: 'Voice'},
  {word: 'Configure.', file: 'providers.png', label: 'AI providers'},
];

export const BreadthRelay: React.FC = () => {
  const frame = useCurrentFrame();
  const enter = tween(frame, 0, 18);
  const stepFrames = [0, 29, 58, 87, 116];
  const cardHeight = 570;
  let offset = 0;
  for (let index = 1; index < stepFrames.length; index++) {
    offset += tween(frame, stepFrames[index], 12, 0, cardHeight, easeInOut);
  }
  const active = Math.min(4, Math.max(0, Math.floor((frame + 4) / 29)));

  return (
    <Stage>
      <div style={{position: 'absolute', left: 142, top: 290, width: 610, opacity: enter}}>
        <div style={{fontSize: 22, color: COLORS.secondary, letterSpacing: 3, textTransform: 'uppercase', fontWeight: 740}}>One training system</div>
        <div style={{position: 'relative', height: 100, marginTop: 24}}>
          {relay.map((item, index) => {
            const local = tween(frame, stepFrames[index], 10);
            const leave = index < 4 ? tween(frame, stepFrames[index + 1] - 5, 5) : 0;
            return (
              <div
                key={item.word}
                style={{
                  position: 'absolute',
                  left: 0,
                  top: 0,
                  fontSize: 78,
                  fontWeight: 780,
                  letterSpacing: -3,
                  color: index === active ? COLORS.text : COLORS.brand,
                  opacity: local * (1 - leave),
                  transform: `translateY(${(1 - local) * 20 - leave * 18}px)`,
                }}
              >
                {item.word}
              </div>
            );
          })}
        </div>
        <div style={{color: COLORS.secondary, fontSize: 28, lineHeight: 1.42, width: 540}}>
          Every round becomes evidence for what to practice next.
        </div>
      </div>
      <div style={{position: 'absolute', right: 135, top: 255, width: 780, height: 600, overflow: 'hidden', opacity: enter}}>
        <div style={{transform: `translateY(${15 - offset}px)`}}>
          {relay.map((item, index) => (
            <div key={item.file} style={{height: cardHeight, display: 'flex', alignItems: 'center', justifyContent: 'center'}}>
              <div style={{position: 'relative'}}>
                <ScreenCrop file={item.file} width={710} height={500} />
                <div
                  style={{
                    position: 'absolute',
                    left: 24,
                    bottom: 22,
                    padding: '10px 16px',
                    borderRadius: 12,
                    background: 'rgba(14,16,19,.86)',
                    color: index === active ? COLORS.brand : COLORS.secondary,
                    fontSize: 17,
                    fontWeight: 720,
                    letterSpacing: 1,
                    textTransform: 'uppercase',
                  }}
                >
                  {item.label}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </Stage>
  );
};
