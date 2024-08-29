import { Platform } from 'react-native'
import { NitroModules } from 'react-native-nitro-modules'
import { Code, type Request, type Send, type SendResult } from './Send.nitro'
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
  if (Platform.OS === 'ios') {
    return Send.send(request)
  } else {
    return {
      error: {
        code: Code.NO_RESPONSE,
        message: 'Platform is not supported',
      },
      response: undefined,
    }
  }
}
