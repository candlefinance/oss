import { Platform } from 'react-native'
import { NitroModules } from 'react-native-nitro-modules'
import type { Send, SendError, SendRequest, SendResponse } from './Send.nitro'
import { SendErrorCode } from './Send.nitro'

export { SendErrorCode } from './Send.nitro'
export type {
  SendError,
  SendMethod,
  SendParameters,
  SendRequest,
  SendResponse,
} from './Send.nitro'

export type SendResult =
  | (SendResponse & { result: 'success' })
  | (SendError & { result: 'error' })

const Send = NitroModules.createHybridObject<Send>('Send')

export async function send(request: SendRequest): Promise<SendResult> {
  switch (Platform.OS) {
    case 'ios':
    case 'macos':
      try {
        const result = await Send.send(request)
        if (result.error !== undefined && result.response === undefined) {
          return {
            result: 'error',
            code: result.error.code,
            message: result.error.message,
          }
        } else if (
          result.response !== undefined &&
          result.error === undefined
        ) {
          return {
            result: 'success',
            body: result.response.body,
            header: result.response.header,
            statusCode: result.response.statusCode,
          }
        } else {
          return {
            result: 'error',
            code: SendErrorCode.UNEXPECTED,
            message: 'Unexpected response from native runtime.',
          }
        }
      } catch (error) {
        return {
          result: 'error',
          code: SendErrorCode.NO_RESPONSE,
          message:
            error instanceof Error
              ? error.message
              : 'Unexpected error was thrown.',
        }
      }
    case 'android':
    case 'web':
    case 'windows':
      return {
        result: 'error',
        code: SendErrorCode.NO_RESPONSE,
        message: 'Platform is not supported',
      }
  }
}
