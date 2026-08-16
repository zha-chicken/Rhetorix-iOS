import React from 'react';
import {Img, OffthreadVideo, staticFile} from 'remotion';
import {COLORS} from '../theme';

const SOURCE_WIDTH = 594;
const SOURCE_LEFT = -87;
const SOURCE_TOP = -126;

export type PhoneSource =
  | {kind: 'still'; file: string}
  | {kind: 'video'; startSeconds: number; playbackRate?: number};

export const PhoneFrame: React.FC<{
  source: PhoneSource;
  width?: number;
  focusRect?: {left: number; top: number; width: number; height: number; opacity?: number};
  screenOverlay?: React.ReactNode;
  screenTransform?: string;
  style?: React.CSSProperties;
}> = ({source, width = 458, focusRect, screenOverlay, screenTransform, style}) => {
  const ratio = width / 458;
  const screenWidth = 420;
  const screenHeight = 902;

  const sourceStyle: React.CSSProperties = {
    position: 'absolute',
    width: SOURCE_WIDTH,
    height: 'auto',
    left: SOURCE_LEFT,
    top: SOURCE_TOP,
    transform: screenTransform,
    transformOrigin: 'center center',
  };

  return (
    <div
      style={{
        width,
        height: 940 * ratio,
        position: 'relative',
        borderRadius: 65 * ratio,
        padding: 10 * ratio,
        background: 'linear-gradient(145deg,#6c7078 0%,#24262b 25%,#060709 72%,#62666d 100%)',
        boxShadow: '0 46px 100px rgba(0,0,0,.56), inset 0 0 0 1px rgba(255,255,255,.34)',
        ...style,
      }}
    >
      <div
        style={{
          width: screenWidth * ratio,
          height: screenHeight * ratio,
          position: 'absolute',
          left: 19 * ratio,
          top: 19 * ratio,
          borderRadius: 55 * ratio,
          overflow: 'hidden',
          background: COLORS.deep,
          boxShadow: 'inset 0 0 0 2px rgba(255,255,255,.035)',
        }}
      >
        <div
          style={{
            position: 'absolute',
            width: screenWidth,
            height: screenHeight,
            left: 0,
            top: 0,
            transform: `scale(${ratio})`,
            transformOrigin: 'top left',
          }}
        >
          {source.kind === 'still' ? (
            <Img src={staticFile(`stills/${source.file}`)} style={sourceStyle} />
          ) : (
            <OffthreadVideo
              muted
              src={staticFile('source/rhetorix.mov')}
              startFrom={Math.round(source.startSeconds * 30)}
              playbackRate={source.playbackRate ?? 1}
              style={sourceStyle}
            />
          )}
          {focusRect ? (
            <div
              style={{
                position: 'absolute',
                left: focusRect.left,
                top: focusRect.top,
                width: focusRect.width,
                height: focusRect.height,
                borderRadius: 24,
                border: `2px solid rgba(84,194,207,${focusRect.opacity ?? 0.9})`,
                boxShadow: '0 0 0 999px rgba(2,4,6,.30), 0 0 30px rgba(84,194,207,.20)',
                pointerEvents: 'none',
              }}
            />
          ) : null}
          {screenOverlay}
        </div>
      </div>
    </div>
  );
};

export const StillPatch: React.FC<{
  file: string;
  left: number;
  top: number;
  width: number;
  height: number;
  sampleOffsetX?: number;
  sampleOffsetY?: number;
  borderRadius?: number;
}> = ({file, left, top, width, height, sampleOffsetX = 0, sampleOffsetY = 0, borderRadius = 10}) => (
  <div style={{position: 'absolute', left, top, width, height, overflow: 'hidden', borderRadius}}>
    <Img
      src={staticFile(`stills/${file}`)}
      style={{
        position: 'absolute',
        width: SOURCE_WIDTH,
        height: 'auto',
        left: SOURCE_LEFT - left - sampleOffsetX,
        top: SOURCE_TOP - top - sampleOffsetY,
      }}
    />
  </div>
);

export const ScreenCrop: React.FC<{
  file: string;
  width: number;
  height: number;
  imageLeft?: number;
  imageTop?: number;
  imageScale?: number;
  style?: React.CSSProperties;
}> = ({file, width, height, imageLeft, imageTop, imageScale = 1.42, style}) => (
  <div
    style={{
      width,
      height,
      position: 'relative',
      overflow: 'hidden',
      borderRadius: 36,
      background: COLORS.surface,
      border: `1px solid ${COLORS.hairline}`,
      boxShadow: '0 28px 72px rgba(0,0,0,.36)',
      ...style,
    }}
  >
    <Img
      src={staticFile(`stills/${file}`)}
      style={{
        position: 'absolute',
        width: width * imageScale,
        height: 'auto',
        left: imageLeft ?? width * -0.21,
        top: imageTop ?? height * -0.44,
      }}
    />
  </div>
);
