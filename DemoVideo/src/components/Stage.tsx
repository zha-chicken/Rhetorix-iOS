import React from 'react';
import {AbsoluteFill} from 'remotion';
import {COLORS, FONT} from '../theme';

export const Stage: React.FC<{
  children: React.ReactNode;
  glow?: boolean;
  rings?: boolean;
  style?: React.CSSProperties;
}> = ({children, glow = false, rings = false, style}) => (
  <AbsoluteFill
    style={{
      background: glow
        ? `radial-gradient(circle at 67% 52%, rgba(84,194,207,.15), transparent 34%), ${COLORS.background}`
        : COLORS.background,
      color: COLORS.text,
      fontFamily: FONT,
      overflow: 'hidden',
      ...style,
    }}
  >
    {rings ? (
      <div style={{position: 'absolute', inset: 0, pointerEvents: 'none'}}>
        {[390, 620, 850].map((size) => (
          <div
            key={size}
            style={{
              position: 'absolute',
              width: size,
              height: size,
              borderRadius: '50%',
              border: `1px solid rgba(84,194,207,${size === 390 ? 0.13 : 0.065})`,
              right: 230 - size / 8,
              top: 540 - size / 2,
            }}
          />
        ))}
      </div>
    ) : null}
    {children}
  </AbsoluteFill>
);

export const Eyebrow: React.FC<{children: React.ReactNode}> = ({children}) => (
  <div
    style={{
      color: COLORS.brand,
      fontSize: 21,
      fontWeight: 760,
      letterSpacing: 3.2,
      textTransform: 'uppercase',
      marginBottom: 22,
    }}
  >
    {children}
  </div>
);

export const CopyBlock: React.FC<{
  eyebrow?: string;
  title: React.ReactNode;
  body?: React.ReactNode;
  align?: 'left' | 'center';
  width?: number;
}> = ({eyebrow, title, body, align = 'left', width = 650}) => (
  <div style={{width, textAlign: align}}>
    {eyebrow ? <Eyebrow>{eyebrow}</Eyebrow> : null}
    <div style={{fontSize: 68, lineHeight: 1.02, letterSpacing: -3.3, fontWeight: 760}}>{title}</div>
    {body ? (
      <div style={{marginTop: 28, color: COLORS.secondary, fontSize: 27, lineHeight: 1.42, maxWidth: 590}}>
        {body}
      </div>
    ) : null}
  </div>
);
