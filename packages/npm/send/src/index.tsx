import { NitroModules } from 'react-native-nitro-modules'
import type { Request, Send, SendResult } from './Send.nitro'
export * from './Send.nitro'

export type Method =
  | 'GET'
  | 'POST'
  | 'PUT'
  | 'DELETE'
  | 'PATCH'
  | 'HEAD'
  | 'OPTIONS'
  | 'CONNECT'
  | 'TRACE'

const Send = NitroModules.createHybridObject<Send>('Send')

export async function send(
  request: Request & { method: Method }
): Promise<SendResult> {
  return Send.send(request)
}
