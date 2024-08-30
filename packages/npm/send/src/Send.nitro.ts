import { type HybridObject } from 'react-native-nitro-modules'

export interface Parameters {
  parameters: Record<string, string>
}

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

export interface Request {
  baseURL: string
  path: string
  query: Parameters
  header: Parameters
  method: Method
  body?: string
  utf8ContentTypes: string[]
}

export interface Response {
  statusCode: number
  header: Parameters
  body: string | undefined
}

export enum Code {
  RESPONSE_INVALID,
  REQUEST_INVALID,
  NETWORK_ERROR,
  NO_RESPONSE,
  NON_UTF8_RESPONSE_BODY,
  NON_UTF8_REQUEST_BODY,
  INVALID_REQUEST_PATH_OR_QUERY_PARAMETERS,
  INVALID_REQUEST_BASE_URL,
  NON_BASE64_REQUEST_BODY,
  INVALID_RESPONSE_HEADER_PARAMETERS,
  UNEXPECTED,
}

export interface SendError {
  code: Code
  message: string
}

export interface SendResult {
  response: Response | undefined
  error: SendError | undefined
}

export interface Send
  extends HybridObject<{ ios: 'swift'; android: 'kotlin' }> {
  send(request: Request): Promise<SendResult>
}
