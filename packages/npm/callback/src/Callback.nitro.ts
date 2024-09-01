import type { AnyMap, HybridObject } from 'react-native-nitro-modules';

export interface Callback
  extends HybridObject<{ ios: 'swift'; android: 'kotlin' }> {
  onEvent(eventName: string, data: (data: AnyMap) => void): void;
}
