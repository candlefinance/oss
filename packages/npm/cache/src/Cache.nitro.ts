import { type HybridObject } from 'react-native-nitro-modules';

export interface Cache extends HybridObject<{ ios: 'swift' }> {
  write(key: string, value: string): Promise<void>;
  read(key: string): Promise<string | undefined>;
  remove(key: string): Promise<void>;
  clear(): Promise<void>;
}
