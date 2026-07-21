import {Easing, interpolate} from 'remotion';

export const clamp = {
  extrapolateLeft: 'clamp' as const,
  extrapolateRight: 'clamp' as const,
};

export const easeOut = Easing.bezier(0, 0, 0.2, 1);
export const easeInOut = Easing.bezier(0.65, 0, 0.35, 1);

export const tween = (
  frame: number,
  start: number,
  duration: number,
  from = 0,
  to = 1,
  easing = easeOut,
) => interpolate(frame, [start, start + duration], [from, to], {...clamp, easing});

export const deterministic = (index: number, seed = 1) => {
  const value = Math.sin(index * 12.9898 + seed * 78.233) * 43758.5453;
  return value - Math.floor(value);
};
