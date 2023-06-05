import React, { useEffect } from 'react';
import { NativeModules, requireNativeComponent } from 'react-native';

type PropsType = {
  onClick?: any;
  onDrawEnd?: any;
  onDrawStart?: any;
  style?: any;
  status?: boolean;
};

type DigitalInkType = {
  multiply(a: number, b: number): Promise<number>;
  show(message: string, duration: number): void;
  clear(): void;
  getLanguages(): void;
  setModel(languageTag: string): void;
  getDownloadedModelLanguages(): void;
  downloadModel(languageTag: string): void;
  recognize(): Promise<string | {text: string; score?: number}>;
  loadLocalModels(): void;
  deleteDownloadedModel(): void;
  LONG: number;
  SHORT: number;
};

export type TouchEvent = {
  nativeEvent: {
      event: string;
      target: number;
      x: number;
      y: number;
  }
};

const { DigitalInk } = NativeModules;
const RCTDigitalInkView = requireNativeComponent<PropsType>('RCTDigitalInkView');

export const DigitalInkView = (props: PropsType) => {
  
  useEffect(() => {
    setTimeout(() => {
      console.log('here');
    }, 1000);
  }, []);

  const _onClick = (event: any) => {
    console.log('_onClick', event.nativeEvent);
    if (props.onClick) {
      return;
    }
    // process raw event
    props.onClick(event.nativeEvent);
  };

  // const _onLoad = (event: any) => {
  //   console.log('_onLoad', event.nativeEvent.nativeID);
  // };

  const _onDrawStart = (event: any) => {
    if (props.onDrawStart) {
      return;
    }
    // process raw event
    props.onDrawStart(event.nativeEvent);
  };

  const _onDrawEnd = (event: any) => {
    if (!props.onDrawEnd) {
      return;
    }
    // process raw event
    props.onDrawEnd(event.nativeEvent);
  };

  return (
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    <RCTDigitalInkView
      onClick={_onClick}
      onDrawStart={_onDrawStart}
      onDrawEnd={_onDrawEnd}
      {...props}
    />
  );
};

export default DigitalInk as DigitalInkType;
