import React from 'react';
import {Composition} from 'remotion';
import {RhetorixDemo} from './RhetorixDemo';

export const Root: React.FC = () => (
  <Composition
    id="RhetorixDemo"
    component={RhetorixDemo}
    durationInFrames={1620}
    fps={30}
    width={1920}
    height={1080}
  />
);
