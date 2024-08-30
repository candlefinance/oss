import { Platform } from 'react-native'
import { NitroModules } from 'react-native-nitro-modules'
import {
  Code,
  type Request as _Request,
  type Response as _Response,
  type SendError as _SendError,
  type Send,
} from './Send.nitro'

export type SendRequest = _Request & { method: Method }
export type SendResponse = _Response
export type SendError = _SendError
export type SendResult =
  | (_Response & { result: 'success' })
  | (SendError & { result: 'error' })

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
            code: Code.UNEXPECTED,
            message: 'Unexpected error was thrown.',
          }
        }
      } catch (error) {
        return {
          result: 'error',
          code: Code.NO_RESPONSE,
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
        code: Code.NO_RESPONSE,
        message: 'Platform is not supported',
      }
  }
}
