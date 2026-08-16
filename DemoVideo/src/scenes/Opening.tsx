import React from 'react';
import {interpolate, useCurrentFrame} from 'remotion';
import {TargetMark} from '../components/Brand';
import {Stage} from '../components/Stage';
import {tween} from '../lib/motion';
import {COLORS} from '../theme';

const word = 'RHETORIX';

export const Opening: React.FC = () => {
  const frame = useCurrentFrame();
  const trace = tween(frame, 5, 50);
  const reveal = tween(frame, 14, 50);
  const subtitle = tween(frame, 58, 18);
  const exit = tween(frame, 94, 14);

  return (
    <Stage rings>
      <div
        style={{
          position: 'absolute',
          inset: 0,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          transform: `scale(${1 + exit * 0.05})`,
          opacity: 1 - exit * 0.14,
        }}
      >
        <div style={{display: 'flex', alignItems: 'center', gap: 42}}>
          <TargetMark size={112} progress={trace} />
          <div>
            <div style={{display: 'flex', fontSize: 86, fontWeight: 760, lineHeight: 1}}>
              {word.split('').map((letter, index) => (
                <span
                  key={`${letter}-${index}`}
                  style={{
                    opacity: reveal,
                    transform: `translateX(${interpolate(reveal, [0, 1], [index * 12 - 42, 0])}px)`,
                    letterSpacing: interpolate(reveal, [0, 1], [42, 13]),
                  }}
                >
                  {letter}
                </span>
              ))}
            </div>
            <div
              style={{
                color: COLORS.secondary,
                fontSize: 26,
                marginTop: 24,
                letterSpacing: 1.2,
                opacity: subtitle,
                transform: `translateY(${(1 - subtitle) * 10}px)`,
              }}
            >
              Practice the point. Prove the case.
            </div>
          </div>
        </div>
      </div>
      <div
        style={{
          position: 'absolute',
          left: 910,
          top: 540,
          width: interpolate(exit, [0, 1], [0, 2520]),
          height: interpolate(exit, [0, 1], [0, 2520]),
          transform: 'translate(-50%,-50%)',
          borderRadius: '50%',
          border: `2px solid ${COLORS.brand}`,
          opacity: exit,
        }}
      />
    </Stage>
  );
};
