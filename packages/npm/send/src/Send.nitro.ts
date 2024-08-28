import { type HybridObject } from 'react-native-nitro-modules'

export interface Send extends HybridObject<{ ios: 'swift' }> {
  send(request: string): Promise<string>
}
