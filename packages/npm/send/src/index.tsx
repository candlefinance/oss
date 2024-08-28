import { NitroModules } from 'react-native-nitro-modules'
import type { Send } from './Send.nitro'
export * from './Send.nitro'

export const send = NitroModules.createHybridObject<Send>('Send').send
