import { NitroModules, type AnyMap } from 'react-native-nitro-modules';
import type { Callback } from './Callback.nitro';

const Callback = NitroModules.createHybridObject<Callback>('Callback');

export function onEvent(data: (data: AnyMap) => void) {
  Callback.onEvent(data);
}

export default Callback;
