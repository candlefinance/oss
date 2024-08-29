import { NitroModules } from 'react-native-nitro-modules'
import type { Request, Response, Send } from './Send.nitro'
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
): Promise<Response> {
  try {
    return Send.send(request)
  } catch (error) {
    if (error instanceof Error) {
      console.log('SEND ERROR', error.message, error.stack)
      throw error
    }
    throw new Error('Unknown error')
  }
}
