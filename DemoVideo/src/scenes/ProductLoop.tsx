import React from 'react';
import {Easing, interpolate, useCurrentFrame} from 'remotion';
import {PhoneFrame} from '../components/PhoneFrame';
import {CopyBlock, Eyebrow, Stage} from '../components/Stage';
import {clamp, deterministic, easeInOut, tween} from '../lib/motion';
import {COLORS} from '../theme';

export const HomeHero: React.FC = () => {
  const frame = useCurrentFrame();
  const reveal = tween(frame, 0, 14);
  const phoneIn = tween(frame, 8, 30);
  const search = tween(frame, 34, 24, 0.35, 1);
  const lift = interpolate(frame, [58, 68, 82], [0, -9, 0], {...clamp, easing: easeInOut});
  const push = tween(frame, 18, 95, 0.93, 1.02);
  const outline = interpolate(frame, [36, 74, 112], [0.25, 1, 0.45], clamp);

  return (
    <Stage glow rings>
      <div style={{position: 'absolute', left: 150, top: 314, opacity: tween(frame, 18, 26)}}>
        <CopyBlock
          eyebrow="Today’s practice"
          title={<>One clear goal.<br />One sharper round.</>}
          body="Rhetorix turns independent practice into a focused daily habit."
        />
      </div>
      <div
        style={{
          position: 'absolute',
          right: 242,
          top: 68,
          transform: `perspective(1700px) scale(${push}) rotateY(${-4 + phoneIn * 4}deg) translateY(${(1 - phoneIn) * 76 + lift}px)`,
          opacity: phoneIn,
        }}
      >
        <PhoneFrame
          source={{kind: 'still', file: 'home.png'}}
          focusRect={{left: 18, top: 120, width: 384, height: 236, opacity: outline * search}}
        />
      </div>
      <div
        style={{
          position: 'absolute',
          left: 1296,
          top: 246,
          width: 94 + reveal * 8,
          height: 94 + reveal * 8,
          borderRadius: '50%',
          border: `1px solid rgba(84,194,207,${0.2 * reveal})`,
        }}
      />
    </Stage>
  );
};

export const GuidedPractice: React.FC = () => {
  const frame = useCurrentFrame();
  const title = tween(frame, 0, 12);
  const demote = tween(frame, 30, 20);
  const content = tween(frame, 42, 24);
  const titleScale = interpolate(demote, [0, 1], [1, 0.30], clamp);
  const titleX = interpolate(demote, [0, 1], [0, -76], clamp);
  const titleY = interpolate(demote, [0, 1], [0, -260], clamp);

  return (
    <Stage>
      <div
        style={{
          position: 'absolute',
          left: 220,
          top: 445,
          fontSize: 74,
          fontWeight: 760,
          letterSpacing: -3.2,
          transformOrigin: 'left center',
          transform: `translate(${titleX}px, ${titleY}px) scale(${titleScale})`,
          opacity: title,
          whiteSpace: 'nowrap',
        }}
      >
        Learn it. Debate it. Review it.
      </div>
      <div style={{position: 'absolute', left: 144, top: 304, opacity: content, transform: `translateY(${(1 - content) * 24}px)`}}>
        <div style={{fontSize: 31, color: COLORS.secondary, lineHeight: 1.48, width: 510}}>
          Learn a move, put it under pressure, then retry with precise coaching.
        </div>
      </div>
      <div
        style={{
          position: 'absolute',
          right: 260,
          top: 76,
          opacity: content,
          transform: `perspective(1600px) translateX(${(1 - content) * 110}px) rotateY(${-5 + content * 3}deg)`,
        }}
      >
        <PhoneFrame source={{kind: 'video', startSeconds: 12.2, playbackRate: 0.58}} />
      </div>
    </Stage>
  );
};

export const DebateSetup: React.FC = () => {
  const frame = useCurrentFrame();
  const enter = tween(frame, 0, 24);
  const move = tween(frame, 38, 8);
  const cursor = tween(frame, 12, 24);
  const press = interpolate(frame, [42, 46, 52], [0, 1, 0], clamp);
  const hold = tween(frame, 52, 22);

  return (
    <Stage>
      <div style={{position: 'absolute', left: 124, top: 318, opacity: enter}}>
        <CopyBlock
          eyebrow="Debate setup"
          title={<>Choose the motion.<br />Set the pressure.</>}
          body="Mode, format and difficulty stay explicit before the clock starts."
          width={650}
        />
      </div>
      <div
        style={{
          position: 'absolute',
          right: 235,
          top: 68,
          opacity: enter,
          transform: `perspective(1600px) translateX(${(1 - enter) * 80}px) rotateY(${4 - enter * 3}deg)`,
        }}
      >
        <PhoneFrame
          source={{kind: 'still', file: 'setup.png'}}
          screenOverlay={(
            <>
              <div
                style={{
                  position: 'absolute',
                  left: interpolate(move, [0, 1], [132, 30]),
                  top: 379,
                  width: 180,
                  height: 42,
                  borderRadius: 22,
                  border: `2px solid rgba(84,194,207,${0.3 + hold * 0.6})`,
                  background: 'rgba(84,194,207,.08)',
                  boxShadow: `0 0 ${24 * hold}px rgba(84,194,207,.18)`,
                }}
              />
              <div
                style={{
                  position: 'absolute',
                  left: interpolate(cursor, [0, 1], [370, 165]),
                  top: interpolate(cursor, [0, 1], [575, 402]),
                  fontSize: 31,
                  color: '#fff',
                  textShadow: '0 2px 8px #000',
                  transform: `scale(${1 - press * 0.12})`,
                }}
              >
                ↖
              </div>
              <div
                style={{
                  position: 'absolute',
                  left: 137,
                  top: 375,
                  width: 68 + press * 40,
                  height: 68 + press * 40,
                  borderRadius: '50%',
                  border: '2px solid rgba(84,194,207,.72)',
                  opacity: press,
                  transform: 'translate(-50%,-50%)',
                }}
              />
            </>
          )}
        />
      </div>
    </Stage>
  );
};

export const LiveDebate: React.FC = () => {
  const frame = useCurrentFrame();
  const enter = tween(frame, 0, 24);
  const collapse = tween(frame, 135, 12);
  const bars = Array.from({length: 64}, (_, index) => {
    const noise = deterministic(index, 6);
    const speaking1 = interpolate(frame, [20, 36, 60, 73], [0, 1, 1, 0.18], clamp);
    const speaking2 = interpolate(frame, [77, 94, 123, 135], [0.18, 1, 0.82, 0.12], clamp);
    const energy = Math.max(speaking1, speaking2);
    return 7 + energy * (22 + noise * 78) * (1 - collapse) + collapse * 2;
  });

  return (
    <Stage glow rings>
      <div style={{position: 'absolute', left: 165, top: 302, opacity: enter}}>
        <CopyBlock
          eyebrow="Live debate"
          title="Your turn."
          body="Speak naturally. The stage, side and timer stay visible while you make the case."
          width={570}
        />
        <div style={{display: 'flex', alignItems: 'center', gap: 5, height: 120, marginTop: 48, width: 610}}>
          {bars.map((height, index) => (
            <div
              key={index}
              style={{
                width: 5,
                height,
                borderRadius: 3,
                background: index % 7 === 0 ? COLORS.success : COLORS.brand,
                opacity: 0.42 + height / 160,
              }}
            />
          ))}
        </div>
      </div>
      <div
        style={{
          position: 'absolute',
          right: 220,
          top: 62,
          opacity: enter,
          transform: `perspective(1600px) scale(${0.95 + enter * 0.06}) rotateY(${-4 + enter * 3}deg)`,
        }}
      >
        <PhoneFrame source={{kind: 'video', startSeconds: 18.15, playbackRate: 0.18}} />
      </div>
      <div
        style={{
          position: 'absolute',
          left: interpolate(collapse, [0, 1], [165, 0], clamp),
          right: interpolate(collapse, [0, 1], [1145, 0], clamp),
          bottom: 150,
          height: 2,
          background: COLORS.brand,
          opacity: collapse,
        }}
      />
    </Stage>
  );
};

export const AnalysisTitleCard: React.FC = () => {
  const frame = useCurrentFrame();
  const line = tween(frame, 0, 18);
  const text = tween(frame, 10, 22);
  return (
    <Stage>
      <div style={{position: 'absolute', left: 0, right: 0, top: 539, height: 2, background: COLORS.brand, transform: `scaleX(${line})`}} />
      <div
        style={{
          position: 'absolute',
          inset: 0,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          opacity: text,
          transform: `translateY(${(1 - text) * 14}px)`,
        }}
      >
        <div style={{background: COLORS.background, padding: '28px 56px', fontSize: 48, fontWeight: 650, letterSpacing: -1.5}}>
          After the speech, the work gets specific.
        </div>
      </div>
    </Stage>
  );
};
