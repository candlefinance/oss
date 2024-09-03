import { NitroModules } from 'react-native-nitro-modules';
import type { Cache } from './Cache.nitro';

const Cache = NitroModules.createHybridObject<Cache>('Cache');

export function write(key: string, object: string) {
  Cache.write(key, object);
}

export function read(key: string): string | undefined {
  return Cache.read(key);
}

export function remove(key: string) {
  Cache.remove(key);
}
1;

export async function clear() {
  Cache.clear();
}

export async function writeAsync(key: string, object: string): Promise<void> {
  await Cache.writeAsync(key, object);
}

export async function readAsync(key: string): Promise<string | undefined> {
  return await Cache.readAsync(key);
}

export async function removeAsync(key: string): Promise<void> {
  await Cache.removeAsync(key);
}

export async function clearAsync(): Promise<void> {
  await Cache.clearAsync();
}
