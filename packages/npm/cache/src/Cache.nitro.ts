import { type HybridObject } from 'react-native-nitro-modules';

export interface Cache extends HybridObject<{ ios: 'swift' }> {
  write(key: string, object: string): void;
  writeAsync(key: string, object: string): Promise<void>;
  readAsync(key: string): Promise<string | undefined>;
  read(key: string): string | undefined;
  removeAsync(key: string): Promise<void>;
  remove(key: string): void;
  clearAsync(): Promise<void>;
  clear(): void;
}
