import React from 'react';
import {Easing, interpolate, useCurrentFrame} from 'remotion';
import {TargetMark} from '../components/Brand';
import {ScreenCrop} from '../components/PhoneFrame';
import {Stage} from '../components/Stage';
import {clamp, deterministic, tween} from '../lib/motion';
import {COLORS} from '../theme';

const cards = [
  {file: 'home-approved.png', x: 95, y: 90, rotate: -5, fromX: -650, fromY: -160},
  {file: 'guided-approved.png', x: 1290, y: 94, rotate: 5, fromX: 690, fromY: -170, imageTop: -420},
  {file: 'coach-approved.png', x: 112, y: 680, rotate: 4, fromX: -680, fromY: 210},
  {file: 'rebuttal-result.png', x: 1310, y: 690, rotate: -4, fromX: 700, fromY: 230},
];

export const Outro: React.FC = () => {
  const frame = useCurrentFrame();
  const crane = tween(frame, 0, 66);
  const brand = tween(frame, 52, 18);
  const impact = tween(frame, 66, 6, 0, 1, Easing.in(Easing.quad));
  const sparkle = tween(frame, 91, 18);

  return (
    <Stage glow rings>
      <div
        style={{
          position: 'absolute',
          inset: 0,
          transform: `perspective(1800px) rotateX(${4 - crane * 4}deg) scale(${0.96 + crane * 0.04})`,
          transformOrigin: 'center 62%',
        }}
      >
        {cards.map((card, index) => {
          const start = 6 + index * 3;
          const arrive = tween(frame, start, 12, 0, 1, Easing.bezier(0.18, 1.22, 0.32, 1));
          const settle = Math.min(1.02, arrive);
          return (
            <div
              key={card.file}
              style={{
                position: 'absolute',
                left: card.x,
                top: card.y,
                transform: `translate(${(1 - settle) * card.fromX}px, ${(1 - settle) * card.fromY}px) rotate(${card.rotate}deg) scale(${0.92 + settle * 0.08})`,
                opacity: Math.min(1, arrive),
              }}
            >
              <ScreenCrop file={card.file} width={500} height={302} imageTop={card.imageTop} />
            </div>
          );
        })}
        <div
          style={{
            position: 'absolute',
            left: '50%',
            top: '50%',
            width: 650,
            transform: `translate(-50%,-50%) scale(${0.97 + impact * 0.03})`,
            opacity: brand,
            textAlign: 'center',
          }}
        >
          <div style={{display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 26}}>
            <TargetMark size={76} progress={brand} />
            <div style={{fontSize: 78, fontWeight: 780, letterSpacing: 8}}>RHETORIX</div>
          </div>
          <div style={{marginTop: 28, color: COLORS.secondary, fontSize: 29, letterSpacing: 0.8}}>One round sharper.</div>
        </div>
        {Array.from({length: 20}, (_, index) => {
          const angle = deterministic(index, 31) * Math.PI * 2;
          const radius = 90 + deterministic(index, 71) * 290;
          const life = sparkle * (1 - tween(frame, 92 + (index % 4) * 2, 22));
          return (
            <div
              key={index}
              style={{
                position: 'absolute',
                left: 960 + Math.cos(angle) * radius * sparkle,
                top: 540 + Math.sin(angle) * radius * sparkle,
                width: 3 + deterministic(index, 13) * 4,
                height: 3 + deterministic(index, 13) * 4,
                borderRadius: '50%',
                background: index % 4 === 0 ? COLORS.success : COLORS.brand,
                opacity: life * 0.78,
                boxShadow: '0 0 12px currentColor',
              }}
            />
          );
        })}
        <div
          style={{
            position: 'absolute',
            left: 960 - 170 - sparkle * 100,
            top: 540 - 170 - sparkle * 100,
            width: 340 + sparkle * 200,
            height: 340 + sparkle * 200,
            borderRadius: '50%',
            border: '1px solid rgba(84,194,207,.5)',
            opacity: impact * (1 - sparkle),
          }}
        />
      </div>
    </Stage>
  );
};
