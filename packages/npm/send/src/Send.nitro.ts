import { type HybridObject } from 'react-native-nitro-modules'

interface Parameters {
  parameters: Record<string, string>
}

export interface Request {
  baseURL: string
  path: string
  query: Parameters
  header: Parameters
  method: string
  body: string | null
  utf8ContentTypes: string[]
}

export interface Response {
  statusCode: number
  header: Parameters
  body: string | null
}

enum Code {
  RESPONSE_INVALID,
  REQUEST_INVALID,
  NETWORK_ERROR,
  NO_RESPONSE,
  NON_UTF8_RESPONSE_BODY,
  NON_UTF8_REQUEST_BODY,
  INVALID_REQUEST_PATH_OR_QUERY_PARAMETERS,
  IVNALID_REQUEST_BASE_URL,
  NON_BASE64_REQUEST_BODY,
  INVALID_RESPONSE_HEADER_PARAMETERS,
  UNEXPECTED,
}

export interface SendError {
  code: Code
  message: string
}

export interface SendResult {
  response?: Response
  error?: SendError
}

export interface Send extends HybridObject<{ ios: 'swift' }> {
  send(request: Request): Promise<SendResult>
}
