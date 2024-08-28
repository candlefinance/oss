import { NitroModules } from 'react-native-nitro-modules'
import type { Request, Response, Send } from './Send.nitro'
export * from './Send.nitro'

const Send = NitroModules.createHybridObject<Send>('Send')

export async function send(request: Request): Promise<Response> {
  return Send.send(request)
}
