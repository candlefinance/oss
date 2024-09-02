import { type HybridObject } from 'react-native-nitro-modules'

export interface SendParameters {
  parameters: Record<string, string>
}

export type SendMethod =
  | 'GET'
  | 'POST'
  | 'PUT'
  | 'DELETE'
  | 'PATCH'
  | 'HEAD'
  | 'OPTIONS'
  | 'CONNECT'
  | 'TRACE'

export interface SendRequest {
  baseURL: string
  path: string
  query: SendParameters
  header: SendParameters
  method: SendMethod
  body?: string
  utf8ContentTypes: string[]
}

export interface SendResponse {
  statusCode: number
  header: SendParameters
  body: string | undefined
}

export enum SendErrorCode {
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
  code: SendErrorCode
  message: string
}

export interface SendResult {
  response: SendResponse | undefined
  error: SendError | undefined
}

export interface Send
  extends HybridObject<{ ios: 'swift'; android: 'kotlin' }> {
  send(request: SendRequest): Promise<SendResult>
}
