import type { TurboModule } from 'react-native'
import { TurboModuleRegistry } from 'react-native'

export interface Spec extends TurboModule {
  send(request: string): Promise<string>
}

export default TurboModuleRegistry.getEnforcing<Spec>('Send')
