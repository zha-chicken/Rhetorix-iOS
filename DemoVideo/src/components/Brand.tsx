import React from 'react';
import {COLORS} from '../theme';

export const TargetMark: React.FC<{size?: number; progress?: number}> = ({size = 86, progress = 1}) => (
  <div style={{position: 'relative', width: size, height: size}}>
    {[1, 0.68, 0.34].map((scale, index) => (
      <div
        key={scale}
        style={{
          position: 'absolute',
          width: size * scale,
          height: size * scale,
          left: (size - size * scale) / 2,
          top: (size - size * scale) / 2,
          borderRadius: '50%',
          border: `${Math.max(2, size * 0.04)}px solid ${COLORS.brand}`,
          opacity: Math.max(0, Math.min(1, progress * 1.6 - index * 0.22)),
          transform: `scale(${0.84 + 0.16 * progress})`,
        }}
      />
    ))}
  </div>
);
