import { NitroModules } from 'react-native-nitro-modules';
import type { Cache } from './Cache.nitro';

const Cache = NitroModules.createHybridObject<Cache>('Cache');

export async function write(key: string, value: string): Promise<void> {
  await Cache.write(key, value);
}

export async function read(key: string): Promise<string | undefined> {
  return await Cache.read(key);
}

export async function remove(key: string): Promise<void> {
  await Cache.remove(key);
}

export async function clear(): Promise<void> {
  await Cache.clear();
}
